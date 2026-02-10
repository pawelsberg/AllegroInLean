# Contributing to AllegroInLean

Thank you for your interest in contributing! This document covers the
conventions and process for adding new bindings or improving the library.

## Getting started

1. **Clone** the repo and make sure the build works (see [docs/Build.md](docs/Build.md)).
2. Run the test suite to confirm a green baseline:

   **Linux / macOS:**
   ```bash
   lake build allegroSmoke allegroFuncTest allegroErrorTest && \
     .lake/build/bin/allegroSmoke && \
     .lake/build/bin/allegroFuncTest && \
     .lake/build/bin/allegroErrorTest
   ```
   **Windows (PowerShell):**
   ```powershell
   lake build allegroSmoke allegroFuncTest allegroErrorTest
   .lake\build\bin\allegroSmoke.exe
   .lake\build\bin\allegroFuncTest.exe
   .lake\build\bin\allegroErrorTest.exe
   ```
3. Create a feature branch for your change.

## Adding a new binding

### 1. Choose the right module

| Allegro subsystem | Lean module | C shim file |
|---|---|---|
| Core (system, display, …) | `src/Allegro/Core/<Module>.lean` | `ffi/allegro_<module>.c` |
| Addon (image, font, …) | `src/Allegro/Addons/<Module>.lean` | `ffi/allegro_<module>.c` |

If the binding extends an existing module, add it there. If it's a new
addon, create a new pair of files and register the C file in
`lakefile.lean` (the `srcFiles` array inside `extern_lib allegroshim`).

### 2. Write the C shim

All C shims live in `ffi/` and share `ffi/allegro_ffi.h`.

```c
#include "allegro_ffi.h"

// Return Lean objects via lean_io_result_mk_ok / lean_io_result_mk_error.
// Pointer handles → UInt64, strings → lean_mk_string, booleans → lean_box.
LEAN_EXPORT lean_obj_res allegro_al_my_function(uint64_t handle, lean_obj_arg world) {
    ALLEGRO_FOO *foo = (ALLEGRO_FOO *)(uintptr_t)handle;
    int result = al_my_function(foo);
    return lean_io_result_mk_ok(lean_box(result));
}
```

Guidelines:
- One C function per Lean `@[extern]` declaration.
- Never allocate Lean objects that outlive the function call.
- Return `0` (as `UInt64` / `UInt32`) for null / failure.

### 3. Write the Lean declaration

```lean
@[extern "allegro_al_my_function"]
opaque myFunction : Foo → IO UInt32
```

- Use the module's opaque handle type (e.g. `Display`, `Bitmap`, `Font`).
- Add a doc comment describing the binding.
- If the call can fail, also add an `Option`-returning variant:
  ```lean
  def myFunction? (foo : Foo) : IO (Option UInt32) := liftOption (myFunction foo)
  ```

### 4. Add the re-export

If you created a new module, import it from the umbrella file:
- Core → `src/Allegro/Core.lean`
- Addon → `src/Allegro/Addons.lean`

### 5. Add a test

Add at least one functional test in `tests/Tests/Functional.lean` and,
if appropriate, an error-path test in `tests/Tests/ErrorPath.lean`.

### 6. Update the lakefile (if needed)

If you added a new `.c` file, append its name to the `srcFiles` array
in `lakefile.lean`.

## Coding conventions

### Lean
- All public API lives in the `Allegro` namespace.
- Use `UInt32` for flags / small integers, `UInt64` for opaque handles, `Float` for
  coordinates / timing.
- Tuple return types (`UInt32 × UInt32 × …`) for multi-value outputs.
- `?`-suffixed variants return `Option` for fallible calls.
- `with*` RAII wrappers in `src/Allegro/Resource.lean` for owned handles.

### C shims
- File naming: `allegro_<module>.c`.
- Function naming: `allegro_al_<snake_case_name>`.
- Always include `allegro_ffi.h`.
- Keep shims minimal — policy belongs in Lean.

### Commits
- Keep commits focused: one binding / feature per commit.
- Prefix commit messages with the module area, e.g. `font: add al_get_font_ranges`.

## Questions?

Open an issue or start a discussion on the repo. Thanks for contributing!
