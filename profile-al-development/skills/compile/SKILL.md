---
name: compile
description: Compile the AL project using al-compile. Runs analyzers, reports errors, and writes diagnostics to the task folder.
---

# /compile — AL Compilation

## Tool Reference

```
!al-compile --help
```

## Behavior

1. Parse `$ARGUMENTS` and pass them through (e.g., `/compile --clean --analyzers all`)
2. Run `al-compile` with the resolved options
3. If there's an active task folder (`.dev/<task-slug>/`), write full output to `.dev/<task-slug>/compile-errors.log`

## Handling Results

- **Success (0 errors):** Report clean compile. Suggest `/publish` as next step.
- **Warnings only:** List top 5 warnings. Note they're non-blocking.
- **Errors:** List ALL errors with file:line. Classify as trivial (typo, missing semicolon) vs complex (logic, missing dependency). For trivial fixes, offer to spawn a quick-fix agent.
