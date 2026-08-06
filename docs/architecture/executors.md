# Executors

The executor pattern is how the game stays extensible. A new effect or action type ships as one `Resource` subclass, one executor class, and one `Registry` line. No existing code is modified.

## The two executor families

There are two parallel hierarchies. They look alike but operate on different scales.

| Family | Inputs | Effect | Operates on |
| --- | --- | --- | --- |
| `EffectExecutor` | An `EffectData` | A discrete in-world change | A character, a tile, or an area |
| `ActionExecutor` | A player or AI action | Resolves the entire player turn step | One actor's turn slot |

Actions often delegate to effects. A "play card" action iterates the card's `effects` array and asks the registry to run each one.

## Common base

Both bases are `RefCounted`. They are throwaway helpers constructed for a single resolution and discarded.

### `EffectExecutor` (RefCounted, base)

| Field | Type | Notes |
| --- | --- | --- |
| `data` | `EffectData` | Configuration to apply. |

| Method | Returns | Notes |
| --- | --- | --- |
| `execute(ctx)` | `void` | Apply the effect. The base does nothing; subclasses override. |

### `ActionExecutor` (RefCounted, base)

| Field | Type | Notes |
| --- | --- | --- |
| `data` | `ActionData` | Configuration, or a `CardData` / `BasicAttackData` reference. |

| Method | Returns | Notes |
| --- | --- | --- |
| `validate(ctx)` | `bool` | Energy, range, line of sight, area validity, action budget. |
| `execute(ctx)` | `bool` | True if the action resolved. |
| `get_affected_tiles(ctx)` | `Array[Vector2i]` | For the targeting UI. |

## Contexts

Contexts are passed into executors so executors never reach outside themselves for collaborators.

### `EffectContext` (RefCounted)

| Field | Type | Notes |
| --- | --- | --- |
| `source` | `Character` | The originator. May be null for environmental effects. |
| `target` | `Character` or `Vector2i` | The recipient. |
| `rng` | `RngService` | The injected randomness source. |
| `bus` | `EventBus` | The signal hub. |
| `metadata` | `Dictionary` | Free-form pass-through between composable effects. |

### `ActionContext` (RefCounted)

| Field | Type | Notes |
| --- | --- | --- |
| `actor` | `Character` | Who is acting. |
| `grid` | `GridSystem` | World query helper. |
| `rng` | `RngService` | |
| `bus` | `EventBus` | |

## Plans and candidates

### `ActionPlan` (RefCounted)

A concrete plan to execute on a future turn slot.

| Field | Type | Notes |
| --- | --- | --- |
| `action` | `StringName` | `move`, `basic_attack`, `play_card`, `draw_cards`, `collect`, `loot`, `wait`. |
| `target` | `Character` or `Vector2i` | The target tile or character. |
| `card` | `CardData` | Set when `action == "play_card"`. |
| `predicted_affected_tiles` | `Array[Vector2i]` | Cached at plan time for intent overlay. |

### `ActionCandidate` (RefCounted)

Used by `PredatorAIBrain` during scoring.

| Field | Type | Notes |
| --- | --- | --- |
| `plan` | `ActionPlan` | The candidate plan. |
| `score` | `float` | Utility score. |
| `reason` | `StringName` | For debugging and explainability. |

## Effect executors

Each is a `RefCounted` subclass of `EffectExecutor`. The data column points to the `EffectData` subclass the executor consumes.

| Executor | Data | Behavior summary |
| --- | --- | --- |
| `DamageExecutor` | `DamageEffectData` | Rolls `dice` (or `max_roll()` on a Nat 20), applies scaling attribute, subtracts defender's `Hardiness` or runs the resistance check (Nat 1 auto-fails). Emits `damage_applied` on `EventBus`. |
| `HealExecutor` | `HealEffectData` | Rolls `dice`, calls `HealthComponent.apply_heal`. Emits `heal_applied`. |
| `GrantTempHpExecutor` | `GrantTempHpEffectData` | Calls `HealthComponent.grant_temp_hp`. |
| `ApplyStatusExecutor` | `ApplyStatusEffectData` | Rolls `chance`; on success, calls `StatusComponent.apply_status`. |
| `PushExecutor` | `PushEffectData` | Computes a push vector and calls `GridPositionComponent.set_cell` once per step. |
| `JumpExecutor` | `JumpEffectData` | Computes destination, validates landing tile, calls `set_cell`. |
| `DrawCardsExecutor` | `DrawCardsEffectData` | Calls `DeckComponent.draw`. |
| `ModifyAttributeExecutor` | `ModifyAttributeEffectData` | Adds an `AttributeModifier` with the given `source`; the status system will remove it on expire. |
| `CompositeExecutor` | `CompositeEffectData` | Iterates `effects` in `mode` order (`sequence` or `all`), threading the same context. |
| `AreaExecutor` | `AreaEffectData` | Expands `inner` over `area_tiles(center, shape, size)`, executing once per tile. |

### Critical and fumble rules

`DamageExecutor` enforces two game rules from the GDD:

- **Nat 20 (natural 20)**: the attack auto-hits. All damage dice are rolled at their maximum.
- **Nat 1 (natural 1)**: the attack auto-fails, regardless of modifiers, hardness, or resistance.

These checks run before damage math. The `RngService.dice_roll` API returns the **raw die** result separately from the modified roll so the executor can inspect it.

## Action executors

Each is a `RefCounted` subclass of `ActionExecutor`.

| Executor | Behavior summary |
| --- | --- |
| `MoveExecutor` | Validates one orthogonal step is unblocked; calls `GridPositionComponent.try_move`. |
| `BasicAttackExecutor` | Reads the actor's `BasicAttackData`; resolves its `effects` via the registry; ignores action budget exhaustion if the attack itself was somehow blocked. |
| `PlayCardExecutor` | Validates energy, range, line of sight, area, action budget; spends energy; resolves each `EffectData` in the card; routes the card to discard (or exhausts it). |
| `DrawCardsExecutor` | Confirms `reload_charges >= 1`; spends one charge; calls `DeckComponent.draw` to refill the hand. |
| `WaitExecutor` | No-op. Resolves immediately. |
| `CollectExecutor` | Requires a `Recolectable` on the actor's tile; applies `effects_on_pickup`; removes the collectable. |
| `LootExecutor` | Requires a `Corpse` on the actor's tile; calls `CorpseComponent.loot`; grants XP, essence, and trophy. |

## The `Registry`

`Registry` is an autoload (see `systems.md`) that owns four static dictionaries:

| Key | Value | Lookup pattern |
| --- | --- | --- |
| `effect_executors[type_id]` | `Script` of the executor | `Registry.create_effect_executor(data) -> EffectExecutor` |
| `action_executors[type_id]` | `Script` of the executor | `Registry.create_action_executor(data) -> ActionExecutor` |
| `status_classes[id]` | `Script` of the `Status` runtime class | Used if a `Status` needs custom tick logic beyond data hooks |
| `data_index[id]` | The `Resource` itself | Fast id → resource lookup at startup and from save data |

### Loading order

On startup, the `Registry` walks `res://data/` and indexes every `Resource` it finds into `data_index`. This means content authors only need to drop a `.tres` into the right folder; the system picks it up.

### Registration API

The registration step is a single line per pair, performed at module load time or by a tool script:

| Call | Effect |
| --- | --- |
| `Registry.register_effect_executor("damage", DamageExecutor)` | One-time, at boot. |
| `Registry.register_status_class("stunned", StunnedStatus)` | One-time, at boot, only when a `Status` has custom runtime logic. |

No new effect or action type should ever require editing existing code. The change set for adding a new type is:

1. Author the `XxxEffectData` `Resource` subclass.
2. Author the `XxxExecutor` `RefCounted` subclass.
3. Add a `register_effect_executor("xxx", XxxExecutor)` call.
4. Author one or more `.tres` instances in `res://data/effects/`.

That is the whole workflow.

## Why this pattern

- **Closed for modification, open for extension**: existing executor code is untouched when new types are added.
- **Polymorphism without `is`-checks**: callers never ask `if data is DamageEffectData`.
- **Testability**: each executor is a `RefCounted` that takes a context; tests construct the context, call `execute`, and assert on the resulting `HealthComponent` state and `EventBus` emissions.
- **Content-driven**: most new content is just a new `.tres` referencing existing data types.
