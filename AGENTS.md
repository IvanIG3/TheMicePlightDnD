# AGENTS.md

- **Unit testing**: GUT 9.7.1 (Godot 4). Read `addons/gut/docs/AGENTS.md` for the file map and quick links to `Quick-Start.md`, `Creating-Tests.md`, `Doubles.md`, `Stubbing.md`, `Spies.md`, `Awaiting.md`, and `class_ref/class_guttest.rst`.
- **GDD**: design docs live in `docs/gdd/` (see `docs/gdd/index.md`).
- **Architecture**: software design lives in `docs/architecture/` — start with `docs/architecture/README.md`, then `principles.md`, `data-model.md`, `components.md`, `executors.md`, `systems.md`.
- **Directory layout**: theme-organized at the project root, no top-level `scripts/` or `tests/`. Each theme dir (e.g. `attribute/`, `stats/`, `health/`, `dice/`, `global/`, `utils/`) holds the theme's `.gd` files directly and a `tests/` subdir for the theme's tests. Autoloads go in `global/`. Support code with no specific theme goes in `utils/`. When adding a new theme, update `.gutconfig.json` `dirs` to include `res://<theme>/tests/`.
- **Content lives with its theme**: `.tres` / `.res` files for a `Resource` type live in the same directory as the `.gd` script that defines the type. Example: `attribute/attribute_data.gd` is paired with `attribute/strength.tres`, `attribute/dexterity.tres`, etc. There is no top-level `data/` folder. The `Registry` autoload walks each theme folder (skipping `*/tests/*` and `*.gd`) to index resources at boot.
- **Code style (Godot 4 / GDScript)** — apply these on every new or modified `.gd` file:
  - **Minimal comments.** Strip narrative documentation, "why we did this" prose, and `TODO[phase-N]` markers. The code is the documentation. Keep only what the code itself cannot say (e.g., a one-line spec reference for a non-obvious decision).
  - **Full names over abbreviations, for every identifier.** `strength` not `str`, `dexterity` not `dex`, `constitution` not `con`, `intelligence` not `int`, `wisdom` not `wis`, `charisma` not `cha`, `modifier` not `mod`. Readability over brevity, with no exceptions for class names, method names, parameter names, local variables, or `Resource` fields.
  - **Named constants, no magic numbers.** Pull numeric and enum-like literals into module-level `const` (e.g., `AttributeBonus.SCORE_BASELINE = 10`) and reference them by name.
  - **Use the StringName constants everywhere.** `AttributeIds.ATTR_STR` not `&"str"`. `AttributeBonus.MODE_ADD` not `&"add"`. `AttributeIds.ALL` for the full list. Never hardcode attribute or mode names.
  - **Type everything explicitly.** `@export var strength: int = 10` not `@export var strength = 10`. Parameters and locals carry their types. `const FOO: int = 10` not `const FOO := 10`. Use the concrete class type (`AttributeSet`, `DiceFormula`, `AttributeComponent`) instead of `Resource` / `Node` when known.
  - **No defensive code.** Trust the architecture: autoloads are registered, `_ready()` ran, callers passed valid arguments. No "is the autoload there?" checks, no `_ensure_*` helpers, no fallback empty returns. Fail fast with `assert` or `push_error` at the contract boundary, not in every method.
  - **Explicit `floori(...)` for division where rounding matters.** `floori(max_hp / 2.0)` not `max_hp / 2`, even when they're equivalent for positive ints — the intent ("round down") must be visible.
  - **Visual separation: double blank line between top-level declarations and between functions.** No trailing blank line inside a function.
  - **Signals are part of the public surface.** Declare them after `@export` / `var` so the field block is contiguous, or at the top so the signal contract is the first thing the reader sees — pick one per file and stay consistent within the file.
  - **Tests**: helpers prefixed with `_` (`_make_set`, `_make_attr`, `_make_bonus`). Use `add_child_autofree(_node)` for every Node-spawning test. Type-annotate every local. When the impl renames a field, update every test that referenced the old name in the same change.

## Running the tests

The Godot binary is at `C:\Users\ivan_\Desktop\Godot 4.7.1.exe`. From WSL, invoke it through `cmd.exe /c` because the path contains spaces and the binary is a Windows `.exe`. Use **Windows-style paths** (`D:\…`), not WSL paths (`/mnt/d/…`) — Godot is a Windows process and rejects POSIX-style arguments.

**Run the full suite:**

```bash
cmd.exe /c "C:\\Users\\ivan_\\Desktop\\Godot 4.7.1.exe" --headless --path "D:\\OneDrive\\MyProjects\\Godot\\TheMicePlightDnD" -s addons/gut/gut_cmdln.gd -gexit
```

The backslash-doubling is bash's: `"\\"` inside a double-quoted string becomes `\` after bash unescapes, which is what `cmd.exe` then sees.

**Run a single test (or a substring):**

```bash
cmd.exe /c "C:\\Users\\ivan_\\Desktop\\Godot 4.7.1.exe" --headless --path "D:\\OneDrive\\MyProjects\\Godot\\TheMicePlightDnD" -s addons/gut/gut_cmdln.gd -gunit_test_name=test_walker_skips_tests_subdir -gexit
```

`-gunit_test_name` is a substring match, not a regex. Use `-gselect` — **there is no such flag**; the only filter is `-gunit_test_name`.

**Import pass (mandatory after creating a new `class_name` script or a new `.gd` file under any `*/tests/`):**

```bash
cmd.exe /c "C:\\Users\\ivan_\\Desktop\\Godot 4.7.1.exe" --headless --path "D:\\OneDrive\\MyProjects\\Godot\\TheMicePlightDnD" --import
```

Without this, Godot has not registered the new script/class yet, and GUT will silently skip the test file with no failure report. When in doubt, re-run `--import` — it is cheap and idempotent.

**Gotchas that have bitten this project before:**

- **Always pass `-gexit`.** Without it, GUT can hang on an interactive debug prompt and never return.
- **GUT silently ignores test files with parse errors.** A `const X := preload("res://missing.gd")` makes the entire test file disappear from the run with the warning `Ignoring script … because it does not extend GutTest` — no failure, no count change. For TDD-red tests where the SUT does not exist yet, do **not** preload the SUT script. Use `get_node_or_null("/root/Name")` and `assert_not_null(…)` instead.
- **Autoload state persists across tests in the same run.** A test that calls `Registry.index_data(x)` leaves `x` in `data_index` for every later test. Tests that assert on global state must either (a) clear the state first (`registry.data_index.clear(); registry._scan_themes()`), or (b) scope their assertions to specific ids.
- **`Object.set("foo", value)` does NOT make `obj.foo` readable in Godot 4.** It writes to the metadata store, not the script property table. To fake a Resource with a typed field (e.g. `type_id: StringName` for `Registry.create_effect_executor`), write a tiny test fixture Script with a real `@export var` field under `global/tests/fixtures/` and preload it. The `data.set("type_id", x)` pattern fails with `Invalid access to property or key 'type_id'` at runtime.
- **Use absolute Windows paths and double the backslashes in the bash heredoc.** Single backslashes break under bash's escape rules before `cmd.exe` ever sees the command.
