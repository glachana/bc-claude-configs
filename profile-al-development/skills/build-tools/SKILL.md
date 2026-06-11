---
name: build-tools
description: Quick reference for AL build pipeline. Auto-load when compilation, deployment, or testing is mentioned. For running commands, use /compile, /publish, or /run-tests.
user-invocable: false
---

# Build Tools Quick Reference

## Standard Cycles

**Unit test cycle (no BC required — fast):**
```
/compile → al-runner ./src ./test
```

**Full integration cycle (BC required):**
```
/compile → /publish → /run-tests (bc-test)
```

Or as shell commands:
```bash
# Unit tests only
al-compile && al-runner ./src ./test

# Full integration
al-compile && bc-publish && bc-test
```

## Tool Summary

| Tool | Purpose | Skill | BC Required? |
|------|---------|-------|-------------|
| `al-compile` | Compile AL project with analyzers | `/compile` | No |
| `al-runner` | Run pure-logic unit tests in milliseconds | `/run-tests` | No |
| `al-mutate` | Mutation testing to validate test quality | `/al-mutate` | No |
| `bc-publish` | Deploy .app to BC server | `/publish` | Yes |
| `bc-test` | Run full integration tests via BC OData API | `/run-tests` | Yes |

## Config

`bc-publish` and `bc-test` read from `.bcconfig.json` in project root. Create with `bc-publish --init`.

`al-runner` and `al-mutate` work directly from AL source directories — no config file needed.

See individual skills (`/compile`, `/publish`, `/run-tests`, `/al-mutate`) for full options and usage.
