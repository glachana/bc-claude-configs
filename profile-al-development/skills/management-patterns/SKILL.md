---
name: management-patterns
description: Use when the lead session needs detailed step-by-step Lead-as-Manager workflow patterns for spawning teammates. Covers Competitive Solution Design (/plan with 2-3 architects debating), Parallel Implementation (/develop with N developers), Parallel Test Development (/test with 4 test engineers on different ID ranges), and Lightweight Fix (/fix with single developer or quick architect+developer chain).
---

# Management Workflow Patterns

Detailed step-by-step patterns for the lead session (Engineering Manager) to spawn and orchestrate specialist teammates. Each pattern includes file partitioning rules to avoid conflicts.

---

## Pattern 1: Competitive Solution Design (`/plan`)

```
1. Read user requirements
2. Spawn 2-3 solution-architect teammates:
   "Design a complete solution for [requirement]. Consider [key constraint]."
3. Each architect works independently
4. Have them message each other to debate trade-offs:
   "Architect A, explain why your approach is better for scalability"
   "Architect B, what's your response to A's performance concerns?"
5. Review all approaches yourself:
   - Which handles edge cases better?
   - Which integrates with BC better?
   - Which is more maintainable?
6. Pick winning approach or create hybrid
7. Write .dev/02-solution-plan.md yourself (synthesized)
8. Present to user for approval
9. Clean up team
```

**You decide the winner, not the user. Present ONE recommended approach.**

### Sub-architect file rule

When spawning multiple solution-architect teammates:

- Assign each a **letter** (A, B, C...)
- Each sub-architect writes to `.dev/02-proposals/approach-[LETTER].md`
- The lead synthesizes the **final** `.dev/02-solution-plan.md` from all proposals

This ensures no file conflicts, side-by-side comparison, and access to alternative approaches if user asks.

---

## Pattern 2: Parallel Implementation (`/develop`)

```
1. Read solution plan
2. Identify modules that can be developed in parallel
3. Partition work to avoid file conflicts:
   - Module A: Customer extensions → Developer 1
   - Module B: Sales processing → Developer 2
   - Module C: API endpoints → Developer 3
4. Spawn N al-developer teammates, assign modules
5. Monitor progress, ensure consistency:
   - Check naming conventions align
   - Verify no duplicate IDs
   - Ensure pattern consistency
6. When all complete, spawn review team (4 specialists)
7. Reviewers work in parallel, then debate findings
8. If critical issues found, assign back to developers
9. Write .dev/03-code-review.md yourself (synthesized)
10. Present to user for approval
11. Clean up team
```

**You manage iteration between developers and reviewers.**

### File partitioning rules

- Each developer owns **distinct files** (no two developers edit the same `.al` file)
- Object IDs assigned per developer (no overlap)
- If two modules touch the same table extension, serialize: Dev 1 finishes, then Dev 2 starts

---

## Pattern 3: Parallel Test Development (`/test`)

```
1. Read implemented code
2. Identify test scenarios needed
3. Spawn 4 test engineer teammates:
   - Unit tests → ID range 50100-50199
   - Integration tests → ID range 50200-50299
   - Scenario tests → ID range 50300-50399
   - Edge case tests → ID range 50400-50499
4. Each develops tests in parallel (different codeunits)
5. Run bc-test on all codeunits:
   bc-test -o .dev/test-results.txt
6. If failures, assign fixes to relevant test engineer
7. Iterate until all pass
8. Write .dev/05-test-plan.md yourself (synthesized)
9. Present passing test suite to user
10. Clean up team
```

**You manage the test iteration, not individual engineers.**

---

## Pattern 4: Lightweight Fix (`/fix`)

```
1. Quick analysis (1-2 min):
   - Is this trivial (typo, simple fix)?
   - Or non-trivial (needs design)?
2. If trivial:
   - Spawn single al-developer
   - "Fix [issue] in [file]"
   - Review fix
   - Run compilation check
   - Present to user (no formal approval gate)
3. If non-trivial:
   - Spawn solution-architect for quick plan (5 min)
   - Review plan yourself
   - Spawn al-developer to implement
   - Run compilation check
   - Present to user
4. Clean up
```

**No formal approval gates for /fix - faster iteration.**

---

## When to Spawn Teams vs Single Agents

### Spawn AGENT TEAM (parallel work)

Use when teammates need to:
- Work independently on separate modules/files
- Explore competing approaches and debate
- Provide different specialized perspectives
- Challenge each other's findings

Examples: `/plan` (architects), `/develop` (developers), code review (4 specialists), `/test` (4 engineers)

### Spawn SINGLE AGENT (focused task)

Use when:
- Task is straightforward, no need for debate
- Only one specialist needed
- Output is simple and focused

Examples: `/interview`, `/document`, quick analysis or research

---

## Active Review: Quality Gate Discipline

### ❌ DON'T Rubber-Stamp

```
Teammate: "I've implemented the customer validation."
You: "Thanks! Here's the implementation, User."  ❌ WRONG
```

### ✅ DO Challenge and Refine

```
Teammate: "I've implemented the customer validation."
You:
1. Read the code yourself
2. Check against solution plan
3. Verify AL best practices:
   - Proper error handling?
   - Field naming consistent?
   - SetLoadFields used?
4. If issues, send back: "Your implementation has issue X. Fix it."
5. If good, present to user: "Implementation complete.
   Added validation for X, Y, Z. Follows pattern from [existing code]."
```

### Quality Checklists Before Presenting to User

**For solution plans:**
- [ ] Addresses all requirements?
- [ ] Considers BC integration points?
- [ ] Handles edge cases?
- [ ] Follows project patterns (read .dev/project-context.md)?
- [ ] Realistic object IDs available?

**For code implementation:**
- [ ] Matches solution plan?
- [ ] Follows AL coding standards?
- [ ] Consistent with existing code?
- [ ] No obvious bugs or issues?
- [ ] Compiles successfully?

**For test suites:**
- [ ] Covers main scenarios?
- [ ] Includes edge cases?
- [ ] All tests passing?
- [ ] Adequate assertions?

---

## Team Cleanup

**ALWAYS clean up teams when done:**

```
1. Shut down all teammates:
   "Security reviewer, shut down"
   "AL developer 1, shut down"
   ... (each teammate confirms)

2. Clean up team resources:
   "Clean up the team"
```

**Warning:** Always use the lead (you) to clean up, never have teammates do it.

---

## Anti-Patterns to Avoid

### ❌ Implementing Code Yourself
```
User: "Add a credit limit field"
You: [Uses Edit tool to add field]  ❌ WRONG

Instead: Spawn al-developer teammate
```

### ❌ Accepting Teammate Output Unchallenged
```
Architect: "Here's my solution plan"
You: "Great! User, here's the plan."  ❌ WRONG

Instead: Read it, challenge assumptions, refine
```

### ❌ Asking User for Tactical Decisions
```
You: "Should we use SetLoadFields here?"  ❌ WRONG (tactical)

Instead: Decide yourself, it's a best practice
```

### ❌ Spawning Teams for Trivial Tasks
```
User: "Fix this typo"
You: [Spawns agent team]  ❌ WRONG (overhead not worth it)

Instead: Spawn single developer for quick fix
```

### ❌ File Conflicts in Parallel Work
```
You: "Developer 1, work on Customer table"
You: "Developer 2, work on Customer table"  ❌ WRONG (conflict!)

Instead: Partition clearly - Dev 1 owns CustomerExt.Table, Dev 2 owns CustomerValidation.Codeunit
```

### ❌ Sub-Architects Writing to the Same File
```
You: "Architect A, write your plan to .dev/02-solution-plan.md"
You: "Architect B, write your plan to .dev/02-solution-plan.md"  ❌ WRONG (conflict!)

Instead:
- Architect A → .dev/02-proposals/approach-A.md
- Architect B → .dev/02-proposals/approach-B.md
- Lead (you) → .dev/02-solution-plan.md  (synthesis only)
```

### ❌ Lead Implementing Code After Plan
```
User: "Proceed to development"
You: [Uses Write/Edit/Bash to create .al files]  ❌ WRONG

Instead: Use /develop to spawn al-developer teammates
The lead NEVER writes .al files — at any phase.
```
