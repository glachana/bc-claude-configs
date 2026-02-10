# AL Development Agents

This directory contains specialized agents for the AL development workflow.

## Agent Workflow Sequence

```
User Request
     │
     ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 1: PLANNING                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐      ┌──────────────────────┐        │
│  │ requirements-engineer │ ──▶  │   solution-planner   │        │
│  │                      │      │                      │        │
│  │ Output:              │      │ Output:              │        │
│  │ 01-requirements.md   │      │ 02-solution-plan.md  │        │
│  └──────────────────────┘      └──────────────────────┘        │
│                                         │                       │
│  [Optional: /interview before planning] │                       │
│                                         ▼                       │
│                              ┌──────────────────────┐           │
│                              │   USER APPROVAL      │           │
│                              │   (Approval Gate)    │           │
│                              └──────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
                                          │
                                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 2: DEVELOPMENT (Iterative)             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐      ┌──────────────────────┐        │
│  │    al-developer      │ ──▶  │    code-reviewer     │        │
│  │                      │      │                      │        │
│  │ Output:              │      │ Output:              │        │
│  │ AL source files      │      │ 03-code-review.md    │        │
│  └──────────────────────┘      └──────────────────────┘        │
│           ▲                             │                       │
│           │                             ▼                       │
│           │                    ┌────────────────┐               │
│           │ ITERATE if        │ Critical/High  │               │
│           └───────────────────│ issues found?  │               │
│                               └────────────────┘               │
│                                        │ No                    │
│                                        ▼                       │
│                          ┌──────────────────────┐              │
│                          │  diagnostics-fixer   │              │
│                          │                      │              │
│                          │  Output:             │              │
│                          │  05-diagnostics.md   │              │
│                          │  + auto-fixes        │              │
│                          └──────────────────────┘              │
│                                        │                       │
│                                        ▼                       │
│                               ┌────────────────┐               │
│       ITERATE if complex ◀────│ Errors remain? │               │
│       errors (3+)             └────────────────┘               │
│                                        │ No                    │
└────────────────────────────────────────│────────────────────────┘
                                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 3: TESTING                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐      ┌──────────────────────┐        │
│  │    test-engineer     │ ──▶  │    test-reviewer     │        │
│  │                      │      │                      │        │
│  │ Output:              │      │ Output:              │        │
│  │ 05-test-plan.md      │      │ 06-test-review.md    │        │
│  │ + test codeunits     │      │                      │        │
│  └──────────────────────┘      └──────────────────────┘        │
│                                         │                       │
│                                         ▼                       │
│                                    ✓ COMPLETE                   │
└─────────────────────────────────────────────────────────────────┘
```

## Support Agents (On-Demand)

```
┌─────────────────────────────────────────────────────────────────┐
│                    SUPPORT AGENTS                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  bc-expert   │  │  docs-lookup │  │ dependency-navigator │  │
│  │              │  │              │  │                      │  │
│  │ Command:     │  │ Command:     │  │ Command:             │  │
│  │ /bc-expert   │  │ /docs-lookup │  │ /nav-baseapp         │  │
│  │              │  │              │  │                      │  │
│  │ Uses:        │  │ Uses:        │  │ Uses:                │  │
│  │ BC Intel MCP │  │ MS Docs MCP  │  │ AL Dependency MCP    │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐                            │
│  │   interview  │  │  docs-writer │                            │
│  │              │  │              │                            │
│  │ Command:     │  │ Command:     │                            │
│  │ /interview   │  │ (internal)   │                            │
│  │              │  │              │                            │
│  │ Deep reqs    │  │ Generate     │                            │
│  │ gathering    │  │ documentation│                            │
│  └──────────────┘  └──────────────┘                            │
└─────────────────────────────────────────────────────────────────┘
```

## Agent Dependency Matrix

| Agent | Depends On | Blocks | Iteration Target |
|-------|------------|--------|------------------|
| `requirements-engineer` | User request | `solution-planner` | - |
| `solution-planner` | `requirements-engineer` | `al-developer` | - |
| `al-developer` | `solution-planner` | `code-reviewer` | ⬅️ `code-reviewer`, `diagnostics-fixer` |
| `code-reviewer` | `al-developer` | `diagnostics-fixer` | - |
| `diagnostics-fixer` | `code-reviewer` | `test-engineer` | - |
| `test-engineer` | `diagnostics-fixer` | `test-reviewer` | ⬅️ `test-reviewer` |
| `test-reviewer` | `test-engineer` | - (final) | - |

## Tool Access by Agent

| Agent | Read | Write | Edit | Glob | Grep | Bash | MCP Tools |
|-------|:----:|:-----:|:----:|:----:|:----:|:----:|:---------:|
| `requirements-engineer` | ✓ | ✓ | - | ✓ | ✓ | - | - |
| `solution-planner` | ✓ | ✓ | - | ✓ | ✓ | - | ✓ All 3 |
| `al-developer` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| `code-reviewer` | ✓ | ✓ | - | ✓ | ✓ | - | - |
| `diagnostics-fixer` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| `test-engineer` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| `test-reviewer` | ✓ | ✓ | - | ✓ | ✓ | - | - |
| `interview` | ✓ | ✓ | - | - | - | - | - |
| `bc-expert` | ✓ | ✓ | - | - | - | - | ✓ BC Intel |
| `docs-lookup` | ✓ | ✓ | - | - | - | - | ✓ MS Docs |
| `dependency-navigator` | ✓ | ✓ | - | - | - | - | ✓ AL Dep |
| `docs-writer` | ✓ | ✓ | - | ✓ | ✓ | ✓ | - |

**Legend:**
- ✓ = Has access
- - = No access
- ✓ All 3 = BC Intelligence, MS Docs, AL Dependency MCPs

## MCP Access by Agent

| Agent | BC Intelligence | MS Docs | AL Dependency |
|-------|:---------------:|:-------:|:-------------:|
| `solution-planner` | ✓ | ✓ | ✓ |
| `bc-expert` | ✓ | - | - |
| `docs-lookup` | - | ✓ | - |
| `dependency-navigator` | - | - | ✓ |
| All others | - | - | - |

**Key Rule:** Main conversation NEVER calls MCP tools directly. Only agents use MCPs.

## Agent Models

| Agent | Model | Reason |
|-------|-------|--------|
| `solution-architect` | sonnet | Architecture decisions |
| `al-developer` | sonnet | Code implementation |
| `security-reviewer` | sonnet | Security analysis |
| `al-expert-reviewer` | sonnet | AL best practices |
| `performance-reviewer` | sonnet | Performance analysis |
| `test-coverage-reviewer` | sonnet | Test coverage analysis |
| `unit-test-engineer` | sonnet | Unit test generation |
| `integration-test-engineer` | sonnet | Integration test generation |
| `scenario-test-engineer` | sonnet | Scenario test generation |
| `edge-case-test-engineer` | sonnet | Edge case test generation |
| `interview` | sonnet | Question generation |
| `docs-writer` | sonnet | Documentation generation |

## Output Files by Agent

| Agent | Primary Output | Also Updates |
|-------|----------------|--------------|
| `requirements-engineer` | `.dev/01-requirements.md` | `session-log.md` |
| `solution-planner` | `.dev/02-solution-plan.md` | `project-context.md`, `session-log.md` |
| `al-developer` | AL source files in `src/` | `project-context.md`, `session-log.md` |
| `code-reviewer` | `.dev/03-code-review.md` | `session-log.md` |
| `diagnostics-fixer` | `.dev/05-diagnostics.md` | `compile-errors.log`, `session-log.md` |
| `test-engineer` | `.dev/05-test-plan.md` + test code | `session-log.md` |
| `test-reviewer` | `.dev/06-test-review.md` | `session-log.md` |
| `interview` | `.dev/00-interview.md` | `session-log.md` |
| `bc-expert` | `.dev/expert-[topic].md` | `session-log.md` |
| `docs-lookup` | `.dev/docs-[topic].md` | `session-log.md` |
| `dependency-navigator` | `.dev/nav-[topic].md` | `session-log.md` |
| `docs-writer` | `docs/` or `wiki/` files | `CHANGELOG.md`, `session-log.md` |

## Iteration Rules

### code-reviewer → al-developer

Iterate back if:
- Critical severity issues found
- High severity issues > 2
- Logic/architectural issues
- Breaking API changes

### diagnostics-fixer → al-developer

Iterate back if:
- 3+ complex compilation errors
- Logic errors in code
- Breaking changes detected
- Auto-fix caused new errors

### test-reviewer → test-engineer

Iterate back if:
- <80% requirement coverage
- Failing tests
- Major edge cases missing
- Test quality is Poor (1-2/5)

## Quick Reference

### Starting Development
```
/dev-cycle "Feature description"   # Full lifecycle
/plan "Feature description"        # Planning only
```

### During Development
```
/develop                           # Run development phase
/diagnostics                       # Fix compiler issues
```

### Support Commands
```
/bc-expert "Question"              # Expert consultation
/docs-lookup "Query"               # Microsoft docs
/nav-baseapp "Query"               # Base app exploration
/interview                         # Deep requirements
```

---

*For detailed agent documentation, see individual agent files in this directory.*
