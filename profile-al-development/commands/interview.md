---
description: Deep requirements gathering through structured interview
allowed-tools: ["Task", "Read", "AskUserQuestion"]
---


**Deep requirements gathering through structured interview with single interview teammate.**

---

## Purpose

When user requirements are unclear, ambiguous, or complex:
- Spawn single interview specialist teammate
- Conduct structured requirements gathering
- You review and identify gaps
- Present comprehensive requirements for approval

---

## Usage

```bash
/interview "I need something for managing customer creditlimits"
```

---

## How This Command Works (v3.0)

**Your Role:** Engineering Manager
**Teammate:** interview specialist (single agent)
**You:** Review interview findings, identify gaps, manage follow-ups, synthesize requirements

### ❌ DON'T
- Conduct the interview yourself
- Accept incomplete requirements
- Skip business context questions

### ✅ DO
- Spawn interview teammate with user's initial request
- Review their findings critically
- Identify gaps and have them ask follow-ups
- Synthesize final requirements yourself

---

## Implementation Steps

### Step 1: Spawn Interview Teammate (10-30 min)

```
Spawn single interview teammate:

"Interview the user to gather comprehensive requirements for: [user request]

Use structured interview approach:

1. BUSINESS CONTEXT:
   - What business problem are you solving?
   - Who will use this feature?
   - What triggers the need for this?

2. FUNCTIONAL REQUIREMENTS:
   - What exactly should the system do?
   - What are the main scenarios/workflows?
   - What validations or rules apply?

3. DATA REQUIREMENTS:
   - What data needs to be stored/tracked?
   - What are the data sources?
   - Any integration with base BC tables?

4. UI/UX REQUIREMENTS:
   - Where should users access this (which pages)?
   - What actions should be available?
   - Any specific UI patterns to follow?

5. CONSTRAINTS:
   - Performance requirements?
   - Security/permissions considerations?
   - BC version compatibility?
   - Existing patterns to follow?

6. SUCCESS CRITERIA:
   - How will we know this is working correctly?
   - What does 'done' look like?

Document findings in structured format.
Output to .dev/01-requirements.md"
```

### Step 2: Review Interview Findings (3-5 min)

```
When interview teammate completes:

1. Read .dev/01-requirements.md yourself

2. Check for completeness:
   - Is business context clear?
   - Are functional requirements specific?
   - Is data model sketched out?
   - Are constraints identified?
   - Are success criteria defined?

3. Identify gaps:
   - Missing scenarios?
   - Unclear validations?
   - Ambiguous requirements?
   - Conflicting statements?
```

### Step 3: Manage Follow-Up Questions (5-15 min)

```
If gaps found, have interview teammate ask follow-ups:

"Interview teammate, I reviewed your findings. Gaps identified:

1. [Gap 1]: Not clear how [scenario X] should work
   → Ask user to clarify [specific question]

2. [Gap 2]: Validation rule for [Y] is ambiguous
   → Ask user: [specific question about edge cases]

3. [Gap 3]: Integration with [base table] not specified
   → Ask user: [how should this integrate]

Update .dev/01-requirements.md with their answers."

Iterate until requirements are comprehensive.
```

### Step 4: Verify Business Logic (2-3 min)

```
Challenge assumptions with interview teammate:

"Interview teammate, verify these assumptions with user:

- You stated credit limit is per customer. Confirm: not per customer + company?
- You said limit is in LCY. Confirm: not per currency?
- Validation happens on posting. Confirm: not also on order creation?"

Update requirements with verification.
```

### Step 5: Clean Up

```
Shut down interview teammate:
"Interview teammate, shut down"

(No team cleanup needed - single agent, not agent team)
```

### Step 6: Write Final .dev/01-requirements.md (5-10 min)

```
YOU review and refine .dev/01-requirements.md:

(Interview teammate drafted it, but you ensure quality)

## Requirements: [Feature Name]

### Business Context
[Why this is needed, who uses it, business problem being solved]

### Functional Requirements

**Core Functionality:**
1. [Requirement 1 - specific, testable]
2. [Requirement 2 - specific, testable]
[...]

**Validation Rules:**
1. [Rule 1 - with edge cases specified]
2. [Rule 2 - with error conditions specified]
[...]

**User Workflows:**
1. [Workflow 1: step by step]
2. [Workflow 2: step by step]
[...]

### Data Requirements

**Data to Store:**
- [Field 1]: [Type, constraints, purpose]
- [Field 2]: [Type, constraints, purpose]
[...]

**BC Integration:**
- Extends: [Base BC table/page]
- Subscribes to: [Events if any]
- Depends on: [Base BC functionality]

### UI/UX Requirements
- Access point: [Which BC page]
- UI elements: [Fields, actions, factboxes]
- User permissions: [Who can access what]

### Constraints
- Performance: [Any performance requirements]
- Security: [Permission considerations]
- BC version: [Compatibility requirements]
- Existing patterns: [Must follow these project patterns]

### Success Criteria
[How we verify this works - specific, measurable]

1. [Criterion 1]
2. [Criterion 2]
[...]

### Out of Scope
[Explicitly state what this does NOT include]

### Open Questions
[Any remaining ambiguities to resolve during planning]
```

### Step 7: Present to User for Approval 🛑

```
"Requirements analysis complete → .dev/01-requirements.md

Key findings:
- Business goal: [1 sentence]
- Core functionality: [2-3 bullet points]
- BC integration: [What we're extending/integrating with]
- Key constraints: [Notable limitations or requirements]

[N] functional requirements documented
[N] validation rules specified
[N] user workflows defined

Ready to proceed to solution planning?"

Use AskUserQuestion:
- Approve - Requirements are comprehensive
- Refine - Adjust requirements (what needs changing?)
- Add Scenarios - Missing use cases to cover
- Stop - Cancel
```

---

## When to Use /interview

**✅ Use /interview when:**
- User request is vague ("I need something for customers")
- Requirements are complex/multi-faceted
- Business context is unclear
- Multiple stakeholders with different needs
- Ambiguous edge cases or validation rules

**❌ Don't use /interview when:**
- Requirements are already clear
- Simple fix or small feature
- User has detailed specification document (just read it)

**Rule of thumb:** If you're unsure what the user wants, run /interview. If you know exactly what to build, skip to /plan.

---

## Output Files

**Interview teammate drafts:**
- `.dev/01-requirements.md` (initial draft)

**YOU refine:**
- `.dev/01-requirements.md` (final, reviewed version)

---

## Success Criteria

✅ Interview teammate conducted structured requirements gathering
✅ You reviewed findings and identified gaps
✅ Follow-up questions resolved ambiguities
✅ Assumptions verified with user
✅ .dev/01-requirements.md is comprehensive and specific
✅ User approved requirements for planning phase

---

## Tips

**Push for Specifics:**
```
❌ "System should validate credit limits"
✅ "System should prevent sales order posting if order total + customer
    balance exceeds credit limit. Error message: 'Credit limit of [amount]
    exceeded by [difference]. Current balance: [balance], Order total: [total]'"
```

**Identify Edge Cases:**
- What if credit limit is 0? (No limit vs zero limit?)
- What if limit is in different currency?
- What if customer has multiple ship-to addresses?

**Verify Assumptions:**
- Don't assume - ask explicitly
- Challenge contradictions
- Clarify ambiguous terms ("limit" vs "available credit")

---

**Remember:** Spawn interview teammate, review findings critically, manage follow-ups, synthesize comprehensive requirements.
