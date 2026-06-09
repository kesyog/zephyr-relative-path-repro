# Zephyr linker snippet path traversal reproducer

A minimal reproducer for a path traversal bug in the Zephyr RTOS build system.

## The Bug

Zephyr's `zephyr_linker_sources` CMake function registers linker script fragments and generates
`#include` directives with relative paths calculated from `${ZEPHYR_BASE}/include`.

If the Zephyr directory is deeply nested relative to the workspace root, the generated relative path contains multiple `..` segments (e.g. `../../../../../app/custom.ld`).

When compiling, the preprocessor evaluates the double-quoted include starting relative to the
generated snippet file (`build/zephyr/include/generated/snippets-*.ld`). Because of the extra `..`
segments, the preprocessor ends up looking outside of the workspace build folder and mistakenly
including a file of the same relative path on the host system (`/app/custom.ld`).

## Repository Structure

* `my_workspace/app/`: Workspace application registering a custom linker script.
* `my_workspace/app/custom.ld`: Intended custom linker script.
* `app/custom.ld`: Colliding file outside the workspace that is mistakenly picked up.
* `my_workspace/deep/deep/deep/zephyr/`: Deeply-nested Zephyr RTOS repository.

## Reproduction Steps

```bash
west init my_workspace
cd my_workspace
west build -p -b native_sim app -DZEPHYR_TOOLCHAIN_VARIANT=host
```

The preprocessor's first include search check escapes the workspace and evaluates the host file. The build fails with the `#error` triggered from outside the workspace:

```ld
In file included from .../my_workspace/build/zephyr/include/generated/snippets-data-sections.ld:1,
                 ...
.../my_workspace/build/zephyr/include/generated/../../../../../app/custom.ld:2:2: error: #error "Bug triggered: included file from outside the workspace!"
    2 | #error "Bug triggered: included file from outside the workspace!"
      |  ^~~~~
```

## Fix

https://github.com/kesyog/zephyr/tree/linker-relative-path
