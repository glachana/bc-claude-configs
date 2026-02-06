---
description: Design complete solution using competitive solution design (2-3 architects debate approaches)
allowed-tools: ["Task", "Read", "Glob", "Grep", "AskUserQuestion"]
---


**Design a complete AL/BC solution using competitive solution design with agent teams.**

---

## Purpose

Create a comprehensive solution plan by spawning 2-3 solution architect teammates who:
- Design competing approaches independently
- Debate trade-offs with each other
- Challenge each other's assumptions

You (the lead) review all approaches, pick the winner, and synthesize the final plan.

---

## Usage

```bash
/plan "Add customer credit limit validation feature"
```

---

## How This Command Works (v3.0)

**Your Role:** Engineering Manager
**Teammates:** solution-architect specialists (spawn 2-3)
**You:** Review, challenge, synthesize, present

### ❌ DON'T

- Write the solution plan yourself
- Accept first architect's proposal unchallenged
- Skip the competitive design debate

### ✅ DO

- Spawn 2-3 architects for competing approaches
- Have them debate trade-offs
- Challenge weak points yourself
- Pick winning approach (or create hybrid)
- Write final .dev/02-solution-plan.md yourself

---

## Implementation Steps

### Step 1: Clarify Requirements (1-3 min)

```
1. Read user's request
2. Check for .dev/01-requirements.md (from /interview)
3. If requirements are clear:
   → Proceed to Step 2
4. If requirements are unclear/complex:
   → Suggest /interview first
   → Or ask clarifying questions directly
```

**Simple requests don't need formal requirements phase.**

### Step 2: Read Project Context (30 sec)

```
1. Check for .dev/project-context.md
2. If exists, read it:
   - Object ID ranges
   - Naming conventions
   - Architectural patterns
   - Base app integration points
3. If not exists:
   - Suggest /init-context (one-time setup)
   - Continue without (will be slower)
```

**Context sharing improves architect quality.**

### Step 3: Spawn Solution Architect Team (2-3 architects)

```
Create agent team with 2-3 solution-architect teammates:

Prompt template:
"Design a complete AL/BC solution for: [user requirement]

Project context:
- Object ID range: [from project-context.md or ask user]
- Naming prefix: [from project-context.md or ask user]
- Key patterns: [from project-context.md]

Design considerations:
1. BC base app integration (tables/events to extend)
2. Complete object design (tables, pages, codeunits, APIs)
3. Data model and validation rules
4. Testability (dependency injection, interfaces)
5. Performance implications
6. Upgrade considerations

Design approach: [Assign different starting points]
- Architect 1: Table extension approach
- Architect 2: Separate table approach
- Architect 3: Event-driven approach

Be prepared to debate trade-offs with other architects."
```

**Use `teammateMode: auto` (split panes if available, in-process otherwise).**

### Step 4: Monitor & Facilitate Debate (5-15 min)

```
1. Let architects work independently first (2-5 min)

2. When they're making progress, facilitate debate:
   "Architect A, explain why your table extension approach is better
    for maintainability."

   "Architect B, what's your response to A's concerns about upgrade
    complexity with separate tables?"

   "Architect C, compare event-driven overhead vs direct integration.
    Which scenarios justify the indirection?"

3. Challenge weak points yourself:
   "Architect A, your plan doesn't address [scenario X]. How would
    your approach handle it?"

   "Architect B, what happens when [edge case Y] occurs?"

4. Ask about BC integration:
   "Have you verified Event X exists in BC base app? Use MCP tools."

5. Verify they're using MCP tools:
   - BC Code Intelligence: Architecture patterns
   - MS Docs: BC API documentation
   - AL Dependency: Base app object exploration
```

**Your job: Push architects to think deeper, not accept superficial solutions.**

### Step 5: Review All Approaches (3-5 min)

```
Read all architect outputs (they may write to separate docs or message you).

Evaluate each approach on:

1. **Completeness:**
   - All requirements addressed?
   - Object design complete (tables, pages, codeunits)?
   - Data validation rules specified?
   - BC integration points identified?

2. **Technical Quality:**
   - Follows AL best practices?
   - Uses dependency injection for testability?
   - Performance considerations addressed?
   - Handles edge cases?

3. **BC Integration:**
   - Extends right base objects?
   - Uses appropriate events?
   - Compatible with BC upgrade path?

4. **Maintainability:**
   - Clear object responsibilities?
   - Extensible design?
   - Follows project patterns?

5. **Trade-offs:**
   - What are costs of this approach?
   - What scenarios does it handle poorly?
   - Is complexity justified?
```

**Don't rubber-stamp. If all approaches are weak, send them back.**

### Step 6: Pick Winning Approach or Create Hybrid (2-3 min)

```
Decide which approach to use:

Option A: Pick one architect's approach
  "Architect B's separate table approach wins because:
   - Better upgrade isolation
   - Clearer ownership boundaries
   - Handles [edge case] better
   Though we'll incorporate A's validation pattern idea."

Option B: Create hybrid
  "We'll use Architect A's table extension for data model,
   combined with Architect C's event-driven validation pattern,
   because this gives us [benefit X] while avoiding [risk Y]."

Option C: Send back for refinement
  "All approaches have issue [X]. Revise to address:
   - Architect A: Fix [specific issue]
   - Architect B: Reconsider [assumption]
   Then we'll re-evaluate."
```

**This is a tactical decision - YOU decide, don't ask user.**

### Step 7: Write .dev/02-solution-plan.md (5-10 min)

```
YOU write the final synthesis yourself:

## Solution Plan: [Feature Name]

### Overview
[1-2 paragraphs: What we're building, why this approach]

### Object Design

**Tables / Table Extensions:**
- Object ID 50xxx: "[Name]"
  Purpose: [1 sentence]
  Fields: [list key fields with IDs and types]

**Pages / Page Extensions:**
- Object ID 51xxx: "[Name]"
  Purpose: [1 sentence]
  Modifications: [what's being added/changed]

**Codeunits:**
- Object ID 52xxx: "[Name]" (Interface: "[Interface Name]")
  Purpose: [1 sentence]
  Key Methods: [list with signatures]

**Enums** (if any):
- Object ID 53xxx: "[Name]"
  Values: [list]

### BC Base App Integration
- Extends Table: [Base Table Name] (ID: [Base ID])
- Subscribes to Events: [Event names]
- Calls Base App: [Procedures/APIs used]

### Data Validation Rules
[List all validation rules with triggers where implemented]

### Testability Design
[How dependency injection/interfaces enable testing]

### Implementation Notes
[Object ID assignments, naming conventions, special considerations]

### Winning Approach Rationale
This plan is based on [Architect X]'s [approach], incorporating [Y] from [Architect Z].

Chosen because:
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

Trade-offs accepted:
- [Limitation 1]: Acceptable because [reason]
- [Limitation 2]: Mitigated by [strategy]
```

**This is YOUR synthesis, not a copy of architect output.**

### Step 8: Clean Up Team

```
1. Shut down all architect teammates:
   "Architect 1, shut down"
   "Architect 2, shut down"
   "Architect 3, shut down"

2. Clean up team resources:
   "Clean up the team"
```

### Step 9: Present to User for Approval 🛑

```
Present your synthesized plan:

"Solution plan complete → .dev/02-solution-plan.md

Key decisions:
- [Table extension vs separate table decision with rationale]
- [Key objects: 3-5 most important ones]
- [BC integration approach]

Evaluated 3 competing approaches:
- Approach A: [1 sentence pro/con]
- Approach B: [1 sentence pro/con]  ← Selected
- Approach C: [1 sentence pro/con]

Selected Approach B because [key rationale].

Ready to proceed to development?"

Use AskUserQuestion with options:
- Approve - Proceed to development
- Refine - Adjust plan (what needs changing?)
- Review Alternatives - Show me other architect approaches
- Stop - Cancel planning
```

**If user selects "Refine", spawn architects again with feedback.**

---

## Output Files

**YOU create:**
- `.dev/02-solution-plan.md` - Your synthesized final plan

**Architects may create (temporary):**
- `.dev/02a-architect-proposals/` - Their individual designs (optional)

**Clean up temporary files after synthesis.**

---

## When to Use This Command

**✅ Good for:**
- New features (medium to complex)
- Architectural changes
- When multiple valid approaches exist
- Complex BC integration scenarios

**❌ Not good for:**
- Bug fixes (use `/fix` instead)
- Trivial changes (just do them)
- Requirements unclear (run `/interview` first)

---

## Success Criteria

✅ 2-3 architects designed competing approaches
✅ Architects debated trade-offs with each other
✅ You challenged weak points and verified assumptions
✅ You picked winning approach with clear rationale
✅ .dev/02-solution-plan.md is comprehensive and actionable
✅ User understands why this approach was chosen

---

## Tips for Better Results

### Assign Different Starting Points
```
Don't: "All architects design a solution" (they'll converge)
Do: "Architect A: table extension, Architect B: separate table,
     Architect C: event-driven"
```

### Facilitate Real Debate
```
Don't: Let architects work in silos, then pick one
Do: "Architect A says your approach has X problem. Respond."
```

### Challenge Assumptions
```
Don't: Accept "we'll extend Customer table" at face value
Do: "Have you verified Customer table is extensible? Check with MCP."
```

### Synthesize, Don't Copy
```
Don't: Copy Architect B's output to solution plan
Do: Write plan in your own words, incorporating best ideas from all
```

---

## Troubleshooting

**Architects converging on same approach?**
→ Assign more specific starting constraints to each

**Debate too shallow?**
→ Ask pointed questions: "What happens when [edge case]?"

**No clear winner?**
→ Create hybrid, or ask user to prioritize: performance vs maintainability

**Architects not using MCP tools?**
→ Remind them explicitly: "Use BC Code Intelligence to verify this pattern"

---

**Remember:** You're the architect-in-chief. Spawn specialists, facilitate debate, make the final call, synthesize the plan.
