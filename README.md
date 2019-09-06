# LLVM/clang makefile project

This makefile project is tested with macOS 10.14.6 and clang version 8.0.1.
This project is configured to build within VS Code, too.

## Quick Start
Install LLVM/clang
```bash
$ brew install llvm
```

Build and run
```bash
$ make run
```

Print supported make targets
```bash
$ make help
```

## Generate auxilliary files (preprocessor, assembler, llvm-ir)
Add ```aux=y``` to the make target. E.g.:
```bash
$ make all aux=y
```

## VS Code

- Build the project with <kbd>Command</kbd>+<kbd>b</kbd>
- Run the project with <kbd>Command</kbd>+<kbd>r</kbd>
- Clean the project with <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>k</kbd>