# Vertical Slice

The first deliverable is a runnable vertical slice that exercises the full architecture end-to-end with deliberately limited content. The slice is the validation step for the design: it should confirm that composition, signals, the executor pattern, and the state machines behave as expected before content scales up.

## In scope

### Content

- One mouse class (the most representative one, chosen during implementation: a class with a clear unique mechanic).
- One predator: the ground squirrel, danger level `alto`, with a fixed three-card deck, one basic attack, and one simple characteristic.
- One biome: the Forest, generated deterministically.
- The final-boss room, reusing the same predator with scaled HP.
- One trap type (e.g., spike trap).
- 4–5 mouse cards, 3 predator cards, 2–3 effect types, 2 statuses (e.g., `weakened` reduces STR, `accelerated` grants +1 reload charge on apply).

### Systems

- All core services (autoloads): `RngService`, `EventBus`, `Registry`, `InputService`, `RunService`. `GridSystem` is scene-level and injected per biome (see [`systems.md`](./systems.md) §`GridSystem`).
- All components: `Attribute`, `Stats`, `Health`, `Faction`, `GridPosition`, `ActionBudget`, `Targeting`, `Status`, `Deck`, `Memorization`, `Trophy`, `Intent`, `Corpse`.
- `TurnManager` and the full turn cycle.
- `RunStateMachine` with all five `RunState`s.
- `BiomeGenerator` with deterministic seeded output, plus the per-biome `EntityFactory` for spawning predators and corpses.
- `EffectExecutor` family: `Damage`, `Heal`, `ApplyStatus`, `Composite`, `Area`.
- `ActionExecutor` family: `Move`, `BasicAttack`, `PlayCard`, `DrawCards`, `Wait`, `Collect`, `Loot`.
- Critical/fumble rules for damage.
- Predator intent overlay.
- Mouse memorization/learning/imbue at rest zones.
- XP, level-up, and rest-zone actions (heal, pick level reward, learn card, add/remove card from deck, imbue trophy, level up).

### UI (minimal)

- HUD: HP, energy, level, XP, essence, hand.
- Card hand with click-to-play and target selection.
- Targeting reticle for moves and ranged attacks.
- Intent overlay for predators.
- Rest zone menu.
- Burrow class selection.
- Run-end screen (victory or death).

### Tests

- Unit tests for `RngService.dice_roll` (Nat 20 max-roll, Nat 1 fumble, advantage/disadvantage if implemented).
- Unit tests for `DeckComponent` (draw, reshuffle when empty, memorize/learn roundtrip).
- Unit tests for `AttributeComponent` (modifier stacking, removal by `source`).
- Unit tests for `DamageExecutor` (toughness, resistance, crit, fumble).
- Integration test: one full turn with one static predator.
- Determinism test: same seed produces the same biome layout (snapshot).

## Out of scope (deferred)

- The other four mouse classes.
- The remaining predators beyond the ground squirrel.
- The other four biomes (Swamp, Tundra, Wasteland, Canyon).
- Hazards (`HazardData` and the `Hazard` scene).
- Events (`EventData`, `AttributeTest`, `EventOutcome`).
- Recollectables beyond a single placeholder used for the `CollectExecutor` test.
- Environmental cards (e.g., Throw Stone, Throw Mud, Consume Plant) are deferred. The `DeckComponent.environmental_hand` field exists but is unused.
- Persistent unlocks / save-load between runs.
- Audio.
- Polished animations and transitions (functional tweens only).
- Accessibility features (subtitles, colorblind modes, remapping).
- Localisation.
- The remaining `EffectData` subclasses not listed in scope (`Push`, `Jump`, `GrantTempHp`, `DrawCards`, `ModifyAttribute`). These are easy to add once the executor family is proven.
- The remaining `Characteristic` subclasses beyond the single one used by the ground squirrel.
- `Mechanic` subclasses beyond the one used by the chosen mouse class.

## Success criteria

The slice is "done" when **all** of the following hold:

- A run can be started at the Burrow, a class chosen, and the full loop Burrow → first Rest → Forest → second Rest → Boss → RunEnd completed without crashes.
- The mouse's death at any point correctly ends the run and returns to the Burrow (permadeath).
- A rolled Nat 20 produces max damage; a rolled Nat 1 misses automatically. Both are demonstrable in a test.
- A predator's intent, as shown in the UI overlay, matches the action it actually executes on its turn.
- The same seed produces the same Forest layout. Verified with at least three seeds.
- All listed unit and integration tests pass.
- A played card spends energy, resolves its effects, and goes to the discard pile (or is exhausted when the card's `exhaust` flag is set).
- The `weakened` status reduces STR by 1 and removes itself after its duration expires.
- Imbuing a trophy adds the predator's characteristic to the mouse.
- No `print` statements remain in non-test code at the end of the slice.

## Phasing (suggested order)

1. **Foundation** — `project.godot`, autoloads, `AttributeSet`, `DiceFormula`, `RngService`, `AttributeComponent`, `StatsComponent`, `HealthComponent`. Tests for each.
2. **Character on a grid** — `Character.tscn`, `Mouse.tscn`, one grid scene, `Move` action, manual turn.
3. **Effects** — `EffectExecutor` family, `Registry`, the first three effect types. Tests.
4. **Decks and cards** — `DeckComponent`, `CardData` instances, `PlayCard` action, basic hand UI.
5. **Turn manager** — full `PLAYER` → `ENEMY_PLANNING` → `ENEMY_RESOLVING` → `POST_TURN` cycle with one static predator.
6. **Predator AI and intent** — `PredatorAIBrain`, `IntentComponent`, `Predator.tscn`, intent overlay.
7. **Statuses** — `StatusComponent`, `Status` node, the two slice statuses.
8. **First playable biome** — `BiomeGenerator`, `EntityFactory`, `BiomeData`, Forest, traps, exit portal.
9. **Run flow** — `RunStateMachine`, all five `RunState`s, rest zone actions, XP, level-up, trophies, memorization/learning.
10. **Final boss and run end** — boss room, victory/death, return to Burrow.
11. **Polish within scope** — functional UI, basic tweens, balancing against the success criteria.

## Risks to watch during the slice

- **Component coupling drift**: if a component starts reading or writing a sibling's private state directly, the design rule is being broken. Catch this in code review.
- **Registry incompleteness at runtime**: forgetting to register an executor causes a silent null-return. Add a startup self-check that asserts every `EffectData` in `data_index` has a registered executor.
- **RNG leakage**: if any system uses `randi()` directly, determinism is lost. Add a lint rule or a startup audit.
- **Intent/execution mismatch**: if the brain re-plans during `ENEMY_RESOLVING`, intent and execution diverge. The brain must read only the cached plan in that state.
- **State explosion in `RunState`**: if a state starts to grow past ~150 lines, it is probably doing two jobs and should be split (e.g., a `RestZoneMenu` state separated from `RestZoneWorld` state if the slice adds an interactive camp scene).
