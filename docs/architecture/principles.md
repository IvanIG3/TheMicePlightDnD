# Principles

The architecture is built on a small number of explicit principles. Every design decision in this folder should be traceable back to one of them.

## 1. Composition over inheritance

An entity's identity is the **set of components it composes**, not its position in a class hierarchy.

- A mouse and a predator share the same `Character` scene root. They differ by which components they include and which `Brain` script is attached.
- A predator with a "venomous" characteristic is not `VenomousPredator extends Predator`. It is a `ReactionCharacteristic` `Resource` holding an `EffectData` triggered on hit.
- A status that grants `+2 STR` is not `BuffedStatus extends Status`. It is a `StatusData` whose `modifiers` array contains one `AttributeModifier`.

The only inheritance in the project is:
- `Resource` for data types, where it gives us editor integration, save/load, and cheap reference passing.
- A few small `Resource` base classes (`EffectData`, `Characteristic`, `Mechanic`, `LevelUpOption`) used to give related data types a shared field set. The polymorphism is resolved by a `type_id` string looked up in a `Registry`, not by `is`-checks on types.
- `Node` and `RefCounted` from Godot, where unavoidable.

No gameplay entity subclasses another gameplay entity.

## 2. Data in `Resource`, behavior in `Node` and `RefCounted`

- **Resources** (`CardData`, `EffectData`, `PredatorData`, `MouseClassData`, ...) hold *what* something is. They are inert, serializable, and editable in the Godot inspector.
- **Nodes** (components, autoloads, scenes) hold behavior and runtime state. They reference `Resource`s for configuration.
- **RefCounted** (executors, contexts, plans) are short-lived, throwaway helpers that operate on data.

A resource's `.tres` files live next to the theme's `.gd` scripts — `attribute/attribute_data.gd` paired with `attribute/strength.tres`, and so on. There is no top-level `data/` folder. The `Registry` autoload walks each theme folder to index resources at boot.

This split makes content authoring independent of code: a new predator is a new `PredatorData.tres`, not a new script.

## 3. Signals for decoupling, `EventBus` for cross-cutting

- Components never call methods on sibling components directly. They emit signals and listen to signals.
- The `EventBus` autoload carries cross-cutting signals (`card_played`, `damage_applied`, `entity_died`, ...) that need to reach unrelated systems (UI, AI, analytics).
- Local signals (`hand_changed`, `hp_changed`, ...) stay on the component that owns the data.

The result: a component can be added to or removed from an entity without breaking the entity's other components.

## 4. Registry pattern for extensible polymorphism

Adding a new effect, action, status, or characteristic type must not require modifying existing code.

The pattern:

1. Define a new `Resource` subclass (e.g. `TeleportEffectData`) extending the base (`EffectData`).
2. Implement a matching executor (`TeleportExecutor`).
3. Register the pair in `Registry` (one line).
4. The system picks it up automatically; no `if`/`elif` chains, no `match` blocks scattered across the codebase.

The same pattern applies to `ActionExecutor`, `Characteristic` subclasses, `Mechanic` subclasses, and `LevelUpOption` subclasses.

## 5. Single-responsibility services, no God-object

There is no `GameManager`. Each autoload owns exactly one concern:

| Autoload | Concern |
| --- | --- |
| `RngService` | All randomness, seedable and injectable. |
| `EventBus` | A hub of global signals; no logic. |
| `Registry` | Lookups of executors and indexed data. |
| `InputService` | Maps Godot input actions to logical intents. |
| `RunService` | State of the current run and persistent unlocks. |
| `GridSystem` | Grid occupancy, blocking, and pathing queries. |

Other "manager"-shaped responsibilities (turns, biome generation, run flow) are owned by named systems, not by a generic manager.

## 6. Centralized, deterministic randomness

All randomness goes through `RngService`. Direct calls to `randi()` or `randf()` in gameplay code are forbidden.

`RngService` is seedable. The same seed must produce the same biome, the same enemy placements, the same card draws, the same damage rolls. This is non-negotiable for:
- Replayability and bug reports ("send me your seed").
- Testing (snapshot tests of generated biomes).
- The future possibility of run replays.

## 7. No `Card` entity, no `CardInstance` wrapper

A `Card` is data (`CardData`). It has no autonomous behavior and no per-instance state worth wrapping. The state of cards-in-play is owned by `DeckComponent`. The visual representation of a card is a `CardView` Control scene, which is a **view**, not an entity.

This avoids the temptation to introduce `class AttackCard extends Card` style hierarchies and keeps the deck representation as a plain `Array[CardData]` with reference-counted `Resource` duplicates.

## 8. Polymorphism by `type_id`, not by class

`EffectData`, `Characteristic`, `Mechanic`, and `LevelUpOption` all define a `get_type_id() -> StringName` method (or expose an `id` field). The `Registry` uses this string as a dictionary key. Code that needs to act on the data asks the `Registry` for an executor (or helper) and uses it.

This decouples the data class from the logic that processes it. A new data type can ship without any existing code knowing its concrete class.

## 9. Tests are first-class, not optional

Pure functions (dice, damage math, deck operations, modifier stacking) are unit-tested. Integration tests cover a full turn end-to-end. Determinism tests assert that the same seed produces the same biome.

The architecture is shaped to be testable: components receive collaborators via setters, executors receive their inputs through a `Context` object, and the RNG is injectable.

## 10. Composition examples (anti-patterns to avoid)

| Tempting (rejected) | Correct |
| --- | --- |
| `class AttackCard extends Card` | `CardData` with `type = "attack"`, effects describe what it does. |
| `class VenomousPredator extends Predator` | `PredatorData` with a `ReactionCharacteristic` that injects poison on hit. |
| `class VeteranMouse extends Mouse` | `Mouse` with `TrophyComponent` configured to expose 5 slots based on its level. |
| `class DamageAction extends Action` | `BasicAttackExecutor` reading the actor's `BasicAttackData` and applying its `EffectData[]`. |
| `class StunnedStatus extends Status` | `StatusData` with `id = "stunned"`, modifiers, and hooks; one `Status` Node instance per active application. |
| `if effect is DamageEffect: ...` | `Registry.create_executor(effect_data).execute(ctx)`. |
