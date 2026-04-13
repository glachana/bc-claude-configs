---
description: Rationalize AL codebase — cartography, analysis, pattern-aligned refactoring. Modes: scan (full project) | deep <Object> | pattern <Object> "description"
allowed-tools: ["Task", "Read", "AskUserQuestion"]
---

# /rationalize

Survey, analyze, and refactor AL code along five axes: readability, duplication, consistency with BC standard patterns, coupling, and source organization (file naming, folder structure, logic placement, procedure ownership). Produces a batch-ordered plan and implements approved batches through al-developer.

Three modes are available:

- **scan** — full codebase survey, parallel multi-axis analysis, consolidated suspect list, plan, implement
- **deep** — targeted deep analysis of one or more named objects, skip cartography, go straight to plan
- **pattern** — single-object mini-cycle: user describes the problem, pattern-matcher identifies the BC pattern, refactor-planner produces a one-batch plan

---

## Constraints — No Over-Engineering

These rules apply to every agent and every decision in this workflow. Enforce them actively.

**Keep** if:
- Complexity serves a documented requirement (spec, comment, explicit business rule)
- Removing it would break an observable business behaviour
- The abstraction is used in 3 or more places in the codebase

**Simplify** if:
- An abstraction has only one caller
- A pattern exists for a hypothetical future not documented anywhere
- Delegation adds a layer with no testable benefit

**Never**:
- Extract a helper for fewer than 3 usages
- Add configuration parameters for a single known case
- Create interfaces when no mock is planned

**Rule in one sentence:** Three similar usages justify an abstraction — two do not. Do not create helpers for one-shot operations. Do not remove code that serves an explicit business need, even when it looks verbose.

---

## Mode Detection

Parse the user's invocation before doing anything else.

```
/rationalize scan                                    → MODE: SCAN
/rationalize deep "Codeunit 50210"                   → MODE: DEEP, targets = ["Codeunit 50210"]
/rationalize deep "CU A" "CU B"                      → MODE: DEEP, targets = ["CU A", "CU B"]
/rationalize pattern "CU50210" "description here"    → MODE: PATTERN, object = "CU50210", description = "description here"
```

If the invocation has no mode keyword or an unrecognized keyword, use AskUserQuestion:

```
question: "Which rationalize mode do you want to use?"
options:
  - label: "scan — survey entire codebase"
    description: "Cartography + parallel analysis + suspect list + plan + implement"
  - label: "deep <ObjectName> — targeted analysis"
    description: "Skip cartography. Analyze one or more named objects directly."
  - label: "pattern <ObjectName> \"description\" — single-object mini-cycle"
    description: "Describe the problem. Pattern-matcher identifies BC pattern. One-batch plan."
```

---

## Mode SCAN — Full 4-Phase Workflow

### Phase 1 — Cartography

Spawn `code-cartographer`:

```
Survey the entire codebase and produce .dev/rationalize/00-cartography.md.
Use ONLY al-mcp-server tools. Never read source files directly.
Follow the output contract in your agent instructions exactly.
```

Wait for completion. Read `.dev/rationalize/00-cartography.md` to understand the scope before proceeding.

**Empty project guard:** If the cartography file contains `Total: 0 objects`, stop and inform the user: "No AL objects found. Verify al-mcp-server is connected to the correct workspace." Do not proceed to Phase 2.

**Large project warning:** If total object count exceeds 100, inform the user before Phase 2: "Large project detected ([N] objects). Analysis may be extensive. Consider using `/rationalize deep` for targeted analysis of specific objects." Continue unless user cancels.

### Phase 2 — Parallel Analysis

Spawn the following four agents simultaneously:

```
duplication-analyzer:
"Read .dev/rationalize/00-cartography.md. Identify duplication suspects across
the codebase (copy-paste logic, repeated calculations, parallel procedure trees).
Write findings to .dev/rationalize/scratch-duplication.md.
Report suspects only — no refactoring proposals.

CONSTRAINT: Only flag duplication that occurs 3 or more times. Two similar
code blocks do not justify an abstraction. Do not flag code that serves a
documented business rule, even if it looks repetitive."

readability-reviewer:
"Read .dev/rationalize/00-cartography.md. Identify readability suspects
(procedure length, naming violations, missing documentation, mixed responsibility).
Write findings to .dev/rationalize/scratch-readability.md.
Report suspects only — no refactoring proposals.

CONSTRAINT: Verbose code that implements an explicit business requirement is
not a readability suspect — it is justified complexity. Only flag complexity
with no traceable business reason."

coupling-analyzer:
"Read .dev/rationalize/00-cartography.md. Identify coupling suspects
(god objects, hidden dependencies, tight cross-module coupling, missing interfaces).
Write findings to .dev/rationalize/scratch-coupling.md.
Report suspects only — no refactoring proposals.

CONSTRAINT: Do not propose an interface unless at least 3 callers would
benefit or a mock is explicitly needed for testing. Tight coupling that is
stable and has no observable downside is not a suspect."

structure-analyzer:
"Read .dev/rationalize/00-cartography.md. Analyze source organization:
file naming conventions, folder structure consistency, logic placement
(business logic in the wrong layer), and procedure ownership (procedures in
the wrong codeunit or table). Write findings to .dev/rationalize/scratch-structure.md.
Report suspects only — no refactoring proposals.

Focus especially on Axis 5 (procedure ownership): flag any procedure whose
natural home is a different codeunit or table than where it currently lives."
```

Wait for ALL FOUR to complete before proceeding.

**Merge scratch files into `01-analysis.md`:**

Read `.dev/rationalize/scratch-duplication.md`, `.dev/rationalize/scratch-readability.md`, `.dev/rationalize/scratch-coupling.md`, and `.dev/rationalize/scratch-structure.md`.

Build a cross-analyzer score for each object: count how many analyzers flagged it (1 to 4). Objects flagged by 2 or more analyzers are high-priority suspects.

Write the merged result to `.dev/rationalize/01-analysis.md` with this structure:

```markdown
# Analysis Results
Generated: [timestamp]

## Cross-Analyzer Summary
| Object | Duplication | Readability | Coupling | Structure | Score |
|--------|-------------|-------------|----------|-----------|-------|
| [Name] | flagged     |             | flagged  | flagged   | 3/4   |

## Suspects by Category
### Duplication
[content from scratch-duplication.md]

### Readability
[content from scratch-readability.md]

### Coupling
[content from scratch-coupling.md]

### Structure & Organization
[content from scratch-structure.md]

## Validated Candidates
[filled in after Gate 1]
```

**Gate 1 — Present suspects to user:**

Summarize the top suspects (score 2/3 or 3/3 first, then 1/3) with one line per object.

Use AskUserQuestion:

```
question: "Analysis complete. [N] objects flagged. [M] flagged by 2+ analyzers (out of 4).
Which candidates should be included in the refactoring plan?"
header: "RATIONALIZE — Gate 1: Candidate Selection"
options:
  - label: "All suspects — proceed with full plan"
    description: "Include all flagged objects. Will produce the most complete plan."
  - label: "Critical and high severity only (score 2/3 or 3/3)"
    description: "Focus on objects flagged by multiple analyzers."
  - label: "Let me specify"
    description: "I will name the objects I want included."
  - label: "Stop"
    description: "Keep analysis files, do not proceed to planning."
```

If user selects "Let me specify", ask for the list of object names.
If user selects "Stop", end here and present: "Analysis saved to .dev/rationalize/01-analysis.md. Re-run /rationalize deep [object names] to plan specific objects."

**Zero suspects guard:** If total suspect count across all three scratch files is 0, skip Gate 1 and inform the user: "Analysis complete — no suspects identified. Codebase appears well-structured." Do not proceed to Phase 3.

Write the user's selection to `01-analysis.md` under `## Validated Candidates`.

Fall through to Phase 3.

---

## Mode DEEP — Targeted Analysis

For each named object in `targets`:
- Verify it exists. If uncertain, note it in the response and continue with the objects that can be confirmed.
- Do not spawn cartography or analysis agents — the user has already identified the targets.

Set VALIDATED_CANDIDATES = the list of user-supplied target objects.

Fall through to Phase 3.

---

## Phase 3 — Architecture (SCAN and DEEP converge here)

Spawn `refactor-planner`:

```
You are refactor-planner. Act as architect.

Validated candidates: [list from Gate 1 or deep mode targets — one per line]

Cartography file: .dev/rationalize/00-cartography.md [include this line only if the file exists]
Analysis file: .dev/rationalize/01-analysis.md [include this line only if the file exists]

For each validated candidate, invoke pattern-matcher as a sub-agent.
Synthesize all pattern match reports.
Order candidates into dependency-safe batches.
Produce .dev/rationalize/02-plan.md following your agent instructions exactly.

CONSTRAINTS — No Over-Engineering:
- Three usages justify an abstraction. Two do not. One never does.
- Do not propose helper procedures for one-shot operations.
- Do not add parameters or configuration for a single known case.
- Do not propose an interface unless a mock is planned or 3+ callers exist.
- Do not flag or simplify code that serves a documented business requirement,
  even if it looks verbose. Explicit business logic is not over-engineering.
- Each batch must justify its refactoring in one sentence. If the justification
  is "it might be useful later", drop the batch.
```

Wait for completion. Read `.dev/rationalize/02-plan.md`.

**Review the plan against these criteria:**
- Every validated candidate has a batch entry.
- Each batch contains: objective, BC pattern applied, objects to create, objects to modify, objects to delete, callers to update, implementation order, acceptance criteria.
- No batch depends on a later batch.
- No AL code appears in the plan — object names, procedure names, and descriptions only.

If the plan fails any criterion, send `refactor-planner` back with specific feedback identifying which batch or candidate is incomplete. Wait for the revised plan and re-check.

**Gate 2 — Present plan to user:**

Summarize: batch count, one-sentence objective per batch, total objects affected.

Use AskUserQuestion:

```
question: "Refactoring plan ready → .dev/rationalize/02-plan.md
[N] batches | [M] objects affected

[Batch 1: objective]
[Batch 2: objective]
...

Which batches should be implemented?"
header: "RATIONALIZE — Gate 2: Plan Approval"
options:
  - label: "Approve all batches — implement now"
    description: "Proceed to implementation for all batches in order."
  - label: "Approve batch 1 only"
    description: "Implement batch 1. Review before continuing."
  - label: "Revise plan"
    description: "Describe what needs to change. Will send refactor-planner back."
  - label: "Stop — keep plan, implement manually"
    description: "Plan is saved. No implementation will be triggered."
```

If user selects "Revise plan", ask what to change, send `refactor-planner` back with the feedback, then re-present at Gate 2.

If user selects "Stop", end here.

Fall through to Phase 4 with the approved batch set.

---

## Phase 4 — Iterative Development

Before spawning al-developer for batch 1, confirm with the user:

```
AskUserQuestion:
  question: "Plan approved. Ready to begin implementation. Batch 1 will modify
production AL files now. Proceed?"
  header: "RATIONALIZE — Begin Implementation"
  options:
    - label: "Proceed — start batch 1"
    - label: "Show me batch 1 spec again"
    - label: "Stop — implement manually"
```

For each approved batch (in order):

Spawn `al-developer`:

```
Implement Batch [N] from .dev/rationalize/02-plan.md.

Read the batch specification carefully before writing any code.

SCOPE CONSTRAINT: You may only create, modify, or delete files explicitly
named in Batch [N]. Do not touch any file not listed in the batch
specification. If you identify a necessary change not listed in the spec,
STOP and report back — do not implement it.

Run al-compile after each file.
Write an implementation summary to .dev/rationalize/03-batch-[N].md
covering: files created, files modified, files deleted, compilation result.
```

Wait for completion. Read `.dev/rationalize/03-batch-[N].md` to verify the batch outcome.

If compilation result contains errors: do NOT present the "proceed to next batch" question. Instead:

```
AskUserQuestion:
  question: "Batch [N] has compilation errors. See .dev/rationalize/03-batch-[N].md."
  header: "RATIONALIZE — Compilation Error"
  options:
    - label: "Send back to al-developer with error log"
    - label: "Stop — fix manually"
```

If compilation succeeded, ask the user before continuing:

```
AskUserQuestion:
  question: "Batch [N] complete. Proceed to batch [N+1]?"
  header: "RATIONALIZE — Batch [N] Complete"
  options:
    - label: "Yes — implement batch [N+1]"
    - label: "Review first — show me what changed"
    - label: "Stop here"
```

If all batches are approved and complete, present the final summary (see below).

---

## Mode PATTERN — Mini Autonomous Cycle

Spawn `pattern-matcher`:

```
CANDIDATE: [object name from argument]
PROBLEM_SIGNAL: [description from argument]
CONTEXT: none (user-initiated, no prior analysis)
```

Collect the pattern match report from the response.

Spawn `refactor-planner`:

```
Single-candidate mode.
VALIDATED_CANDIDATES: [[object name]]
Pattern match report:
[paste the full pattern match report from pattern-matcher here]

No cartography or analysis files are available — work from the pattern match report only.
Produce .dev/rationalize/02-plan.md following your agent instructions exactly.

CONSTRAINTS — No Over-Engineering:
- Three usages justify an abstraction. Two do not. One never does.
- Do not propose helper procedures for one-shot operations.
- Do not introduce interfaces or configuration parameters without a clear,
  present need (not hypothetical).
- Do not simplify code that serves a documented business requirement.
- If you cannot justify a refactoring step in one concrete sentence, drop it.
```

Wait for completion. Read `.dev/rationalize/02-plan.md`.

Present the plan to the user:

```
AskUserQuestion:
  question: "Pattern identified and plan ready → .dev/rationalize/02-plan.md
  Pattern: [pattern name from plan]
  [Batch 1 objective]
  Approve to implement now, or keep the plan for manual implementation."
  header: "RATIONALIZE — Pattern Mode: Plan Review"
  options:
    - label: "Approve — implement now"
      description: "Spawn al-developer for batch 1 immediately."
    - label: "Revise"
      description: "Describe what needs to change."
    - label: "Stop — keep plan only"
      description: "Plan is saved. No implementation triggered."
```

If approved, spawn `al-developer` for batch 1 using the same prompt template as Phase 4.

---

## Output Files Reference

| File | Producer | Description |
|------|----------|-------------|
| `.dev/rationalize/00-cartography.md` | code-cartographer | Object inventory (scan mode only) |
| `.dev/rationalize/scratch-duplication.md` | duplication-analyzer | Raw duplication findings |
| `.dev/rationalize/scratch-readability.md` | readability-reviewer | Raw readability findings |
| `.dev/rationalize/scratch-coupling.md` | coupling-analyzer | Raw coupling findings |
| `.dev/rationalize/scratch-structure.md` | structure-analyzer | Raw structure & organization findings |
| `.dev/rationalize/01-analysis.md` | This command (merged) | Consolidated suspects + validated candidates |
| `.dev/rationalize/02-plan.md` | refactor-planner | Batch-ordered refactoring plan |
| `.dev/rationalize/03-batch-N.md` | al-developer | Per-batch implementation log |

---

## Final Response Format

When all approved batches are complete:

```
Rationalize complete.

Mode: [scan / deep / pattern]
Batches implemented: [N]
Objects created: [N] | modified: [N] | deleted: [N]

Plan: .dev/rationalize/02-plan.md
Implementation logs: .dev/rationalize/03-batch-*.md

All compilation checks passed.
```
