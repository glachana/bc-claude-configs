---
description: Create detailed hours-based estimation using interview, expert consultation, and planning
argument-hint: "[project description]"
allowed-tools: ["Task", "Read", "Write", "AskUserQuestion", "Bash"]
---

# Estimation Workflow

Create comprehensive hours-based estimation for BC/AL projects through structured phases with user approval.

## Usage

```
/estimate "Add customer credit limit validation"
/estimate --quick "Simple field addition"  # Skip interview
```

## What It Does

Runs 4-phase estimation workflow with approval gates:
1. **Requirements Gathering** - Interview OR quick requirements
2. **Expert Consultation** - BC specialist validation (if needed)
3. **Planning** - Requirements → Design → Implementation
4. **Hours Estimation** - Component breakdown with testing & buffers

**Output:** `.dev/estimation.md` with complete hours breakdown

---

## Phase 1: Requirements Gathering

### Check for --quick flag or existing spec

**If `--quick` flag OR user provides file path:**
- Skip interview
- Proceed to Phase 2

**Otherwise:**

### Ask User: How clear are requirements?

Use `AskUserQuestion`:

```json
{
  "questions": [{
    "question": "How clear are the project requirements?",
    "header": "Requirements",
    "multiSelect": false,
    "options": [
      {
        "label": "Run full interview (Recommended)",
        "description": "40+ questions to gather complete requirements - takes 15-20 min, prevents scope issues"
      },
      {
        "label": "Requirements are clear",
        "description": "Skip interview - I can describe requirements in detail right now"
      },
      {
        "label": "Have existing spec",
        "description": "Already have detailed spec document to work from"
      }
    ]
  }]
}
```

**Based on answer:**

- **Run full interview:** Use `Task` tool to spawn `interview` agent
  - Output: `.dev/00-interview.md`
  - After completion: Show 3-5 key requirements, continue to Phase 2

- **Requirements are clear:** Ask user to describe requirements
  - User provides description
  - Write to `.dev/00-requirements-brief.md`
  - Continue to Phase 2

- **Have existing spec:** Ask for file path
  - Read the spec file
  - Continue to Phase 2

---

## Phase 2: Expert Consultation

### Analyze project complexity

Based on requirements, identify if expert consultation needed.

**Check for these signals:**
- Architecture decisions ("how to integrate", "best approach")
- Performance concerns ("large volume", "scale", "10k+ records")
- Security requirements ("permissions", "field-level security")
- Integration complexity ("base app events", "posting routines")
- Unfamiliar patterns ("first time with...", "not sure how...")

### Ask User: Which technical areas need expert input?

Use `AskUserQuestion`:

```json
{
  "questions": [{
    "question": "Which technical areas should BC experts review before estimation?",
    "header": "Expert Review",
    "multiSelect": true,
    "options": [
      {
        "label": "Architecture & Extension Strategy",
        "description": "How to integrate with base app, table vs extension decisions"
      },
      {
        "label": "Performance & Scalability",
        "description": "Will handle expected data volumes efficiently"
      },
      {
        "label": "Security & Permissions",
        "description": "Permission sets, field-level security, audit requirements"
      },
      {
        "label": "Integration Patterns",
        "description": "API integration, event subscribers, base app hooks"
      },
      {
        "label": "None - straightforward work",
        "description": "Skip expert consultation, standard BC patterns only"
      }
    ]
  }]
}
```

**For each selected area:**

1. Use `Task` tool to spawn `bc-expert` agent with specific question
   - Example: "Best approach for integrating credit limit validation with sales order posting in BC? Need to handle real-time validation and approval workflow."
2. Output: `.dev/expert-[topic].md`
3. After all consultations: Show 2-3 key recommendations

**If "None" selected:**
- Skip to Phase 3

---

## Phase 3: Structured Planning

### Run planning workflow

Use `Task` tool to spawn agents in sequence with approval gates:

### Step 1: Requirements Engineering

1. Spawn `requirements-engineer` agent
2. **Wait for completion**
3. Read `.dev/01-requirements.md`
4. Show summary (3-5 bullets)
5. **🛑 APPROVAL GATE** - Use `AskUserQuestion`:

```json
{
  "questions": [{
    "question": "Review requirements document. Ready to proceed to solution design?",
    "header": "Approve",
    "multiSelect": false,
    "options": [
      {
        "label": "Approve - Continue",
        "description": "Requirements look good, proceed to design phase"
      },
      {
        "label": "Refine requirements",
        "description": "I'll provide feedback to improve"
      },
      {
        "label": "Stop here",
        "description": "Just wanted requirements analysis"
      }
    ]
  }]
}
```

**If "Refine":** Get feedback, re-run requirements-engineer
**If "Stop":** End workflow
**If "Approve":** Continue

### Step 2: BC Solution Design

1. Spawn `bc-solution-designer` agent (reads requirements + expert consultations)
2. **Wait for completion**
3. Read `.dev/02-design.md`
4. Show summary (3-5 bullets: tables, pages, codeunits, integration approach)
5. **🛑 APPROVAL GATE** - Use `AskUserQuestion`:

```json
{
  "questions": [{
    "question": "Review technical design. Ready to proceed to implementation planning?",
    "header": "Approve",
    "multiSelect": false,
    "options": [
      {
        "label": "Approve - Continue",
        "description": "Design approach looks good, proceed to implementation plan"
      },
      {
        "label": "Revise design",
        "description": "I'll provide feedback for different approach"
      },
      {
        "label": "Stop here",
        "description": "Just wanted design, will estimate manually"
      }
    ]
  }]
}
```

**If "Revise":** Get feedback, re-run bc-solution-designer
**If "Stop":** End workflow
**If "Approve":** Continue

### Step 3: Implementation Planning

1. Spawn `solution-planner` agent (reads requirements + design)
2. **Wait for completion**
3. Read `.dev/02-solution-plan.md`
4. Show summary (file count, phases, key components)
5. **No approval gate** - proceed to Phase 4

---

## Phase 4: Hours Estimation

### Extract components from implementation plan

Read `.dev/02-solution-plan.md` and identify all deliverables:

**Component types:**
- Table extensions
- New tables
- Page extensions
- New pages
- Codeunits
- Event subscribers
- API integrations
- Reports
- Enums/Interfaces

### Apply hours estimation guidelines

**Base hours by complexity:**

| Component | Simple | Moderate | Complex |
|-----------|--------|----------|---------|
| Table Extension | 1-2h | 2-3h | 3-5h |
| New Table | 2-3h | 3-5h | 5-8h |
| Page Extension | 1-2h | 2-3h | 3-4h |
| New Page | 3-4h | 4-6h | 6-10h |
| Codeunit | 2-3h | 3-5h | 5-10h |
| Event Subscriber | 1-2h | 2-3h | 3-4h |
| API Integration | 4-6h | 6-10h | 10-15h |
| Report | 3-5h | 5-8h | 8-12h |

**Complexity classification:**
- **Simple:** Single responsibility, straightforward logic, no base app hooks
- **Moderate:** Business logic, event integration, error handling
- **Complex:** Multiple integration points, advanced logic, performance optimization

### Calculate testing overhead

**Mandatory additions:**
- Unit tests: +30% of implementation hours
- Integration tests: +20% of implementation hours
- Code review & polish: +15% of implementation hours

**Total testing: +65% of implementation**

### Apply buffer

**Ask user about uncertainty:**

Use `AskUserQuestion`:

```json
{
  "questions": [{
    "question": "How familiar are you with this type of BC work?",
    "header": "Experience",
    "multiSelect": false,
    "options": [
      {
        "label": "Very familiar - done similar before",
        "description": "Add 10-15% buffer for minor unknowns"
      },
      {
        "label": "Moderately familiar - standard BC patterns",
        "description": "Add 20-25% buffer for moderate unknowns"
      },
      {
        "label": "New territory - unfamiliar domain",
        "description": "Add 30-40% buffer for significant unknowns"
      },
      {
        "label": "High risk - many major unknowns",
        "description": "Add 50%+ buffer for major uncertainties"
      }
    ]
  }]
}
```

**Apply selected buffer percentage to subtotal**

### Generate estimation document

Write `.dev/estimation.md`:

```markdown
# Project Estimation: [Project Name]

**Generated:** [timestamp]
**Project Code:** [if known]
**Customer:** [if known]

---

## Executive Summary

[2-3 sentences from requirements]

**Total Estimate:** [X] hours
**Timeline:** [X] weeks (assuming [Y]h/week)
**Confidence Level:** [High/Medium/Low based on buffer]

---

## Requirements Summary

[Key points from .dev/01-requirements.md]

---

## Technical Approach

[Summary from .dev/02-design.md]

### Components
- [X] table extensions
- [Y] page extensions
- [Z] codeunits
[etc.]

---

## Hours Breakdown

### Implementation

| Deliverable | Description | Complexity | Hours |
|-------------|-------------|------------|-------|
| [Component 1] | [Description] | [S/M/C] | [X]h |
| [Component 2] | [Description] | [S/M/C] | [X]h |
| **Subtotal** | | | **[X]h** |

### Testing & Quality

| Activity | Calculation | Hours |
|----------|-------------|-------|
| Unit Tests | Implementation × 30% | [X]h |
| Integration Tests | Implementation × 20% | [X]h |
| Code Review & Polish | Implementation × 15% | [X]h |
| **Subtotal** | | **[X]h** |

### Contingency

| Factor | Reason | Hours |
|--------|--------|-------|
| Buffer ([X]%) | [User-selected uncertainty level] | [X]h |

---

## **TOTAL: [X] hours**

---

## Timeline

**Assumptions:**
- [Y] productive hours per week
- [Z] weeks total duration

| Phase | Duration |
|-------|----------|
| Development | [X] weeks |
| Testing | [X] weeks |
| **Total** | **[X] weeks** |

---

## Technical Risks

[From expert consultations if any]

| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk 1] | [H/M/L] | [Approach] |

---

## Assumptions

1. [Key assumption 1]
2. [Key assumption 2]
3. Test environment available immediately
4. Standard BC platform (no heavy customizations)

**If assumptions change, re-estimation required.**

---

## Exclusions

The following are NOT included:

- [Exclusion 1]
- [Exclusion 2]
- Historical data migration (separate scope)
- Production deployment support

---

## Prerequisites

Required before starting:

- [ ] Test environment access
- [ ] [Other prerequisites from requirements]

---

## Acceptance Criteria

[From .dev/01-requirements.md]

### Functional
- [ ] [Criterion 1]
- [ ] [Criterion 2]

### Technical
- [ ] All tests pass
- [ ] No critical security issues
- [ ] Code review approved

---

## Expert Consultations

[If Phase 2 ran]

- **[Specialist]** - [Topic] → See `.dev/expert-[topic].md`

**Key recommendations incorporated:**
- [Recommendation 1]
- [Recommendation 2]

---

## Confidence Assessment

**Overall Confidence:** [High/Medium/Low]

**Factors:**
- Requirements clarity: [Clear/Moderate/Unclear]
- Technical familiarity: [High/Medium/Low]
- Integration complexity: [Low/Medium/High]
- Expert validation: [Yes/No]

---

## Next Steps

1. Review this estimation with stakeholders
2. Confirm assumptions and timeline
3. Export to customer-specific template format (ABC, Banqr, etc.)
4. If approved: Run `/develop` to begin implementation

---

## Reference Documents

- Requirements: `.dev/01-requirements.md`
- Design: `.dev/02-design.md`
- Implementation Plan: `.dev/02-solution-plan.md`
- Expert Consultations: `.dev/expert-*.md` (if consulted)
- Interview Notes: `.dev/00-interview.md` (if conducted)

---

*Generated via AL Development Profile `/estimate` command*
```

### Show summary to user

After writing `.dev/estimation.md`, show:

```
✅ Estimation complete → .dev/estimation.md

📊 Summary:
- Total Hours: [X]h
- Timeline: [X] weeks
- Confidence: [High/Med/Low]

💡 Key Components:
- [Component type]: [X] × [hours each]
- Testing: +65% ([X]h)
- Buffer: +[X]% ([Y]h)

📁 Files Generated:
- .dev/estimation.md (detailed estimation)
- .dev/01-requirements.md
- .dev/02-design.md
- .dev/02-solution-plan.md
[- .dev/00-interview.md (if interview ran)]
[- .dev/expert-*.md (if experts consulted)]

🎯 Next Steps:
1. Review .dev/estimation.md
2. Export to customer template format (use Clawd to convert)
3. If approved: Run /develop to start implementation
```

---

## Critical Rules

### ALWAYS use AskUserQuestion

- After Phase 1 (requirements approach)
- Before Phase 2 (which experts to consult)
- After Step 1 of Phase 3 (requirements approval)
- After Step 2 of Phase 3 (design approval)
- In Phase 4 (buffer/uncertainty level)

### NEVER skip approval gates

- User must approve requirements before design
- User must approve design before implementation planning
- User decides which experts to consult

### READ the generated files

Before summarizing, always `Read` the actual output files to provide accurate summaries.

### Respect --quick flag

If `--quick` provided, skip interview and go straight to planning.

---

## Example Execution Flow

```
User: /estimate "Add customer credit limit validation"

Agent: I'll create a comprehensive estimation for this BC project.

Phase 1: Requirements Gathering
[AskUserQuestion: How clear are requirements?]

User: Run full interview

Agent: Spawning interview agent...
[Task tool spawns interview agent]
[Interview completes]

✓ Interview complete → .dev/00-interview.md

Key requirements identified:
- Validate on sales order save
- Block if exceeds limit with manager override
- Real-time balance calculation
- Audit trail required

Phase 2: Expert Consultation
[Analyzes requirements, identifies needs]

[AskUserQuestion: Which technical areas need expert input?]
Options: Architecture, Performance, Security, Integration, None

User: Architecture, Integration

Agent: Consulting BC experts...

1. Consulting Alex Architect on approval workflow patterns...
✓ Consultation complete → .dev/expert-approval-workflow.md

2. Consulting Isaac Integration on sales order integration...
✓ Consultation complete → .dev/expert-sales-integration.md

Key recommendations:
- Use notification + approval entries pattern (Alex)
- OnBeforeModify event subscribers on Sales Header (Isaac)

Phase 3: Structured Planning

Step 1: Requirements Engineering
Spawning requirements-engineer...
✓ Requirements documented → .dev/01-requirements.md

Summary:
- Sales order validation with credit limit check
- Manager approval workflow for overrides
- Real-time balance calculation
- Audit logging

[AskUserQuestion: Approve / Refine / Stop]

User: Approve

Step 2: BC Solution Design
Spawning bc-solution-designer...
✓ Design complete → .dev/02-design.md

Summary:
- Table extension: Customer (credit tracking fields)
- Codeunit: Credit validation logic
- Event subscribers: Sales Header (2x)
- Page extension: Sales Order (validation UI)
- Approval workflow integration

[AskUserQuestion: Approve / Revise / Stop]

User: Approve

Step 3: Implementation Planning
Spawning solution-planner...
✓ Implementation plan → .dev/02-solution-plan.md

Components identified:
- 1x Table Extension
- 1x Codeunit
- 2x Event Subscribers
- 1x Page Extension
- 1x Approval setup

Phase 4: Hours Estimation

Analyzing implementation plan...

Hours breakdown:
- Table Extension (Customer): 1.5h [Simple]
- Credit Check Codeunit: 4h [Moderate]
- Event Subscribers (2x): 2h [Simple each]
- Page Extension: 2h [Simple]
- Approval Workflow: 3h [Moderate]
Implementation subtotal: 12.5h

Testing & Quality:
- Unit tests (+30%): 3.75h
- Integration tests (+20%): 2.5h
- Code review (+15%): 1.875h
Testing subtotal: 8.125h

[AskUserQuestion: Experience level / buffer]
Options: Very familiar (10-15%), Moderate (20-25%), New (30-40%), High risk (50%+)

User: Moderately familiar

Agent: Applying 20% buffer...
Buffer: 4.125h

TOTAL: 24.75h (~25h)

Writing estimation document...
✓ Estimation complete → .dev/estimation.md

📊 Summary:
- Total Hours: 25h
- Timeline: 4 weeks (6h/week)
- Confidence: Medium (moderate complexity, approval workflow)

💡 Key Components:
- 1 table ext + 1 codeunit + 2 events + 1 page ext + approval
- Testing: +65% (8h)
- Buffer: +20% (4h)

🎯 Next Steps:
1. Review .dev/estimation.md for details
2. Export to ABC template format
3. If approved: /develop to begin
```

---

## Flags

### --quick

Skip interview, go straight to planning.

```
/estimate --quick "Add email field to Customer table"
```

Use when requirements are crystal clear and straightforward.

---

**Remember:** User approval and expert input make estimates accurate. Don't rush through phases.
