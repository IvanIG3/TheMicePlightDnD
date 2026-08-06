# Architecture

This folder documents the software architecture of **The Mice Plight**, complementing the high-level design in [`../GDD.md`](../GDD.md).

The architecture prioritizes **composition over inheritance**, with content driven by data (`Resource`s) and behavior expressed as small, focused, signal-decoupled components.

## Layered architecture

```
+---------------------------------------------------------------+
|  PRESENTATION  (UI scenes, HUD, menus, animations)           |
+---------------------------------------------------------------+
|  GAMEPLAY      (Run state machine, turn manager, biome gen)   |
+---------------------------------------------------------------+
|  DOMAIN        (entities composed of components)              |
+---------------------------------------------------------------+
|  EXECUTION     (EffectExecutor, ActionExecutor, Registries)   |
+---------------------------------------------------------------+
|  CORE SERVICES (RngService, EventBus, InputService, ...)      |
+---------------------------------------------------------------+
|  DATA          (Resources: CardData, EffectData, etc.)        |
+---------------------------------------------------------------+
```

Each layer depends only on the layer below it. Higher layers never reach down to skip a layer.

## Index

| Document | Scope |
| --- | --- |
| [`principles.md`](./principles.md) | The "why" behind the design: composition, signals, data-driven content, registries, single-responsibility services. Read first. |
| [`data-model.md`](./data-model.md) | Every `Resource` type, its fields, and the data-level relationships. The most stable section. |
| [`components.md`](./components.md) | Every `Node` component, its signals, and the rules for how components compose into entities. |
| [`executors.md`](./executors.md) | The `EffectExecutor` / `ActionExecutor` pattern, the `Registry` lookup, and how to add new types without modifying existing code. |
| [`systems.md`](./systems.md) | The autoloads (`RngService`, `EventBus`, `Registry`, `InputService`, `RunService`, `GridSystem`) and the "no God-object" rule. |
| [`run-flow.md`](./run-flow.md) | The run state machine, the turn manager, and the cycle from `Burrow` to `RunEnd`. |
| [`entities.md`](./entities.md) | The `Character`, `Mouse`, `Predator`, and `Corpse` scenes and how they compose components without inheritance. |
| [`vertical-slice.md`](./vertical-slice.md) | Scope of the first deliverable, what is explicitly out, and success criteria. |

## How to read this folder

1. Start with `principles.md` to understand the design constraints.
2. Skim `data-model.md` to get a feel for the vocabulary.
3. Read `components.md`, `executors.md`, and `systems.md` in any order.
4. Use `run-flow.md` and `entities.md` to see how the parts integrate.
5. Use `vertical-slice.md` to decide what to build first.

## Conventions

- **Naming**: `PascalCase` for classes and `Resource` types, `snake_case` for variables and functions, `SCREAMING_SNAKE_CASE` for enum-like `StringName` values.
- **Identifiers** match the planned GDScript implementation exactly; no translation, no rephrasing.
- **Signals** appear as past-tense or present-progressive verbs: `card_played`, `damage_applied`, `entity_died`.
- **Tables** are preferred over prose for class fields, methods, and signals.
- **Diagrams** use Mermaid where helpful.
- This folder contains **design only**; no GDScript code blocks.
