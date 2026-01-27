# Task System Improvement Idea

## Problem Identified

Current implementation creates tasks at the **workflow phase level** which adds no value:
- "Diagnostics - Batch 7"
- "Development - Batch 7"
- "Code Review - Batch 7"

These tasks just duplicate the existing phase orchestration (requirements-engineer → solution-planner → al-developer → code-reviewer → diagnostics-fixer → test-engineer). The document-driven workflow already tracks phases perfectly.

## Root Cause

Someone (likely in command definitions) is creating tasks at phase granularity instead of work unit granularity.

## The Right Granularity

Tasks should be at the **atomic AL object level**, not phase level.

### Good Example: Multi-Object Feature
Request: "Add customer credit limit functionality"

```
□ #1 Create CustCreditLimit table with fields
□ #2 Extend Customer table with CreditLimitCode field
□ #3 Create CreditLimitMgt codeunit with check logic
□ #4 Create Credit Limit List page
□ #5 Create Credit Limit Card page
□ #6 Subscribe to Customer OnAfterValidate events [blocked by #2, #3]
□ #7 Subscribe to Sales Order OnBeforePost event [blocked by #3]
□ #8 Write test codeunit for credit checks [blocked by #3]
```

Dependencies matter: Can't write event subscribers until table extension and codeunit exist.

### Good Example: Multiple Independent Fixes
```
□ #1 Fix AL0432 in SalesPostInvoice.Codeunit.al line 145
□ #2 Fix AL0118 in CustomerCard.Page.al line 89
□ #3 Fix AL0251 in ItemLedgerEntry.TableExt.al line 23
```

These are independent and could be fixed in parallel.

### Good Example: Complex Refactoring
Request: "Refactor posting routines to use new framework"

```
□ #1 Create PostingFramework codeunit interface
□ #2 Migrate SalesPost to use framework [blocked by #1]
□ #3 Migrate PurchasePost to use framework [blocked by #1]
□ #4 Migrate ItemJnlPost to use framework [blocked by #1]
□ #5 Update all event publishers [blocked by #2, #3, #4]
□ #6 Run regression tests [blocked by #5]
```

Tasks #2, #3, #4 could run in parallel.

## Proposed Solution

### When to Use Tasks

**DO use Tasks when:**
- Multiple AL objects need to be created with dependencies between them
- Multiple independent diagnostics need fixing (could parallelize)
- A feature naturally decomposes into 5+ discrete code changes
- Parts of the work could benefit from parallel agents

**DON'T use Tasks when:**
- Simple single-object feature (one table, one page, one codeunit)
- Straightforward bug fix
- The work is naturally sequential anyway
- Tracking phases (that's what the document workflow does)

### Implementation Approach

#### 1. Modify solution-planner.md

Add intelligence to decide when tasks are beneficial:

```markdown
## Task Creation Decision

After analyzing the solution, evaluate:
- Will this require 5+ AL objects?
- Are there dependencies between objects? (e.g., can't subscribe to events before codeunit exists)
- Could parts be developed independently in parallel?

**If YES**: Use TaskCreate to break down into granular tasks at AL object level.
- Each task = one concrete AL object or one specific code change
- Set dependencies with addBlockedBy where applicable
- Document the task graph in the solution plan

**If NO**: Skip tasks. The phase workflow is sufficient.
```

#### 2. Modify al-developer.md

Add task awareness:

```markdown
## Task-Aware Development

Before starting implementation:
1. Call TaskList to check if tasks exist
2. If tasks exist:
   - Work through them in dependency order
   - Call TaskUpdate to mark in_progress before starting each
   - Call TaskUpdate to mark completed after finishing each
3. If no tasks exist:
   - Proceed with normal implementation
```

#### 3. Remove Phase-Level Task Creation

Find and remove wherever tasks are being created for phases (Diagnostics, Development, Code Review). Check:
- `/commands/dev-cycle.md`
- `/commands/develop.md`
- `/commands/test.md`
- `/commands/fix.md`
- Any agent definitions

### User Experience

User sees tasks only when they add value:

**Simple request** (no tasks shown):
```
User: "Add a field to Customer table"
→ No tasks created
→ Normal phase workflow proceeds
→ User sees phase-level progress
```

**Complex request** (tasks shown):
```
User: "Add customer credit limit functionality"
→ solution-planner creates 8 tasks automatically
→ Shows dependency graph in plan
→ al-developer works through them in order
→ User sees: "✓ #1 Create table ✓ #2 Extend Customer ■ #3 Create codeunit □ #4 List page..."
```

### Benefits

1. **No noise**: Tasks only appear when they provide value
2. **Automatic**: solution-planner decides and creates them
3. **Dependency enforcement**: Can't start subscriber before codeunit exists
4. **Parallel opportunities**: Multiple agents could work on independent tasks
5. **Real progress**: See actual object-level progress, not vague phases

## Related Resources

- [Claude Code's Task System Guide](https://nummanali.com/claude-code-task-system-guide) - Full explainer article
- Task storage: `~/.claude/tasks/<list-id>/`
- Task persistence: Set `CLAUDE_CODE_TASK_LIST_ID` in `.claude/settings.json`

## Status

**Not yet implemented** - documented for future consideration.

## Notes

- The current document-driven workflow (phase-based) works well and shouldn't be replaced
- Tasks are a complementary system for within-phase complexity
- Don't force tasks everywhere - only where dependencies or parallelism add value
