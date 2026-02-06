---
description: Generate comprehensive technical documentation
allowed-tools: ["Task", "Read", "Glob", "Grep"]
---


**Generate comprehensive technical documentation using single docs-writer teammate.**

---

## Purpose

Create complete documentation for implemented features:
- Spawn single docs-writer specialist
- You review for completeness and accuracy
- Present final documentation to user

---

## Usage

```bash
/document
```

**Prerequisites:**
- Implementation must be complete (AL code exists)
- Optionally: Test results available

---

## How This Command Works (v3.0)

**Your Role:** Engineering Manager
**Teammate:** docs-writer specialist (single agent)
**You:** Review documentation quality, verify technical accuracy, present

### ❌ DON'T
- Write documentation yourself
- Accept incomplete documentation
- Skip technical accuracy verification

### ✅ DO
- Spawn docs-writer with clear scope
- Review for completeness
- Verify code references are accurate
- Present polished documentation

---

## Implementation Steps

### Step 1: Identify Documentation Scope (1-2 min)

```
Determine what needs documenting:

1. Find implemented AL files
2. Read .dev/02-solution-plan.md if available (for context)
3. Check for test results (.dev/05-test-plan.md)
4. Identify target audience (developers, users, admins)
```

### Step 2: Spawn Docs-Writer Teammate (10-30 min)

```
Spawn single docs-writer teammate:

"Write comprehensive technical documentation for [feature].

Implemented files to document:
- [List AL files created]

Context available:
- Solution plan: .dev/02-solution-plan.md
- Test plan: .dev/05-test-plan.md (if exists)
- Code review: .dev/03-code-review.md (if exists)

Documentation structure:

## [Feature Name] - Technical Documentation

### Overview
[What this feature does, business purpose, 2-3 paragraphs]

### Architecture

**Objects Created:**
[Table of objects with IDs, names, types, purposes]

**BC Integration:**
- Extends: [Base tables/pages]
- Events: [Subscribed events]
- Dependencies: [Base BC functionality used]

### Data Model

**Tables / Table Extensions:**
[For each table/extension: fields added, purposes, constraints]

**Key Relationships:**
[How tables relate to each other and BC base tables]

### Business Logic

**Codeunits:**
[For each codeunit: purpose, key methods, interfaces]

**Validation Rules:**
[List all validation rules, where implemented, error messages]

**Event Handlers:**
[Event subscriptions, what they do, why]

### User Interface

**Pages / Page Extensions:**
[For each page: what's added, where accessed, user actions]

**User Workflows:**
[Step-by-step workflows for key scenarios]

### API / Integration (if applicable)
[API endpoints, integration points, external dependencies]

### Testing
[If test results available: test coverage summary, how to run tests]

### Configuration
[Any setup required: permissions, configuration tables, etc.]

### Maintenance Notes
[For developers: where to find key logic, how to extend, common modifications]

### Known Limitations
[Any constraints, edge cases not handled, future enhancements]

Output to: docs/[FeatureName].md"
```

### Step 3: Review Documentation (3-5 min)

```
When docs-writer completes:

1. Read the documentation yourself

2. Verify technical accuracy:
   - Are object IDs correct?
   - Are code references accurate?
   - Are workflow descriptions correct?
   - Do validation rules match implementation?

3. Check completeness:
   - All objects documented?
   - Key methods explained?
   - User workflows clear?
   - Edge cases noted?

4. Verify clarity:
   - Can a new developer understand this?
   - Are examples helpful?
   - Is jargon explained?
```

### Step 4: Request Refinements (if needed)

```
If gaps found:

"Docs-writer, refinements needed:

1. [Gap 1]: Missing documentation for [method/object X]
   → Add section explaining [specific aspect]

2. [Gap 2]: Workflow description for [scenario Y] is unclear
   → Add step-by-step with screenshots or code examples

3. [Gap 3]: No mention of [integration point Z]
   → Document how this integrates with [base BC functionality]

Update docs/[FeatureName].md"

Iterate until documentation is comprehensive.
```

### Step 5: Clean Up

```
Shut down docs-writer teammate:
"Docs-writer, shut down"

(No team cleanup needed - single agent)
```

### Step 6: Present to User

```
"Documentation complete → docs/[FeatureName].md

Documented:
- [N] objects (tables, pages, codeunits)
- [N] user workflows
- [N] integration points with BC
- Testing and configuration guidance

Documentation includes:
- Architecture overview
- Data model
- Business logic
- User workflows
- Maintenance notes

Ready for review?"

(No formal approval needed - documentation is reference material)
```

---

## Documentation Best Practices

### For Technical Audiences (Developers)
```
Include:
- Object structure and relationships
- Key methods and interfaces
- Extension points (events, procedures)
- How to modify or extend
- Testing approach
```

### For Business Audiences (Users/Admins)
```
Include:
- What the feature does (business value)
- How to access and use it
- Step-by-step workflows
- Configuration requirements
- Troubleshooting common issues
```

### Code Examples
```
Show actual AL code snippets for:
- Complex validation logic
- Event usage
- API integration patterns
- Test examples
```

### Visual Aids
```
Consider including:
- Object relationship diagrams
- Workflow flowcharts
- UI screenshots (if available)
- Data flow diagrams
```

---

## Output Files

**Docs-writer creates:**
- `docs/[FeatureName].md` - Main documentation

**Optional additional outputs:**
- `docs/diagrams/` - Architecture diagrams
- `docs/api/` - API documentation
- `docs/users/` - User guides

---

## Success Criteria

✅ Single docs-writer teammate created comprehensive documentation
✅ You verified technical accuracy against implementation
✅ All objects, workflows, and integrations documented
✅ Documentation is clear and complete
✅ Maintenance notes help future developers

---

## When to Use /document

**✅ Use /document when:**
- Feature implementation is complete
- You want technical reference documentation
- Onboarding new developers
- Preparing for handoff

**❌ Don't use /document when:**
- Implementation is incomplete (document after coding)
- Quick prototype (not worth documentation overhead)

**Timing:** Usually run after `/develop` and optionally after `/test`.

---

## Tips

**Document While Fresh:**
Run `/document` right after implementation while context is fresh.

**Include Examples:**
Code snippets and workflow examples make documentation much more useful.

**Think About Maintenance:**
Future developers will read this - explain WHY not just WHAT.

**Link to Code:**
Reference specific files and line numbers for key logic.

---

**Remember:** Spawn docs-writer, review for accuracy and completeness, present polished documentation.
