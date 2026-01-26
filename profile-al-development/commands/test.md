---
description: Run testing phase only (create tests → review tests)
allowed-tools: ["Task", "TaskCreate", "TaskUpdate", "TaskList"]
---

# Testing Phase

Run only the testing phase: test creation and test review.

## Usage

```
/test
```

**Prerequisite:** Must have implemented code and `.dev/02-solution-plan.md`.

## Step 0: Check/Create Tasks

**Check for existing tasks:**

```
TaskList → Check if Testing task exists
  - If exists → Continue
  - If not exists → Create testing tasks
```

**Create testing tasks if needed:**

```
TaskCreate: "Testing"
  - description: "Create test codeunits"
  - activeForm: "Writing tests"

TaskCreate: "Test Review"
  - description: "Review test coverage and quality"
  - activeForm: "Reviewing tests"

TaskUpdate: "Test Review" → addBlockedBy: ["Testing"]
```

## What It Does

Runs testing agents in sequence with task tracking:

1. **TaskUpdate:** "Testing" → status: "in_progress"
2. **Spawn test-engineer** - Create comprehensive tests
3. **TaskUpdate:** "Testing" → status: "completed"
4. **TaskUpdate:** "Test Review" → status: "in_progress"
5. **Spawn test-reviewer** - Review test coverage
6. **TaskUpdate:** "Test Review" → status: "completed"

## Output

- `.dev/05-test-plan.md`
- `.dev/06-test-review.md`
- Test codeunits (in src/tests/)

## When to Use

- Code implementation complete
- Want comprehensive test coverage
- Need to verify requirements met

## Next Steps

After testing:
- Review test review report
- Run manual UI tests
- Deploy to test environment
