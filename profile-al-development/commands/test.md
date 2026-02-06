---
description: Develop comprehensive test suite with 4 parallel test engineers
allowed-tools: ["Task", "Read", "Glob", "Grep", "Bash", "AskUserQuestion"]
---


**Develop comprehensive test suite using parallel test engineering teams.**

---

## Purpose

Create complete test coverage by spawning 4 specialized test engineer teammates:
- Unit tests (individual functions/methods)
- Integration tests (cross-object interactions)
- Scenario tests (end-to-end workflows)
- Edge case tests (boundaries, errors, negatives)

---

## Usage

```bash
/test
```

**Prerequisites:**
- Implementation must be complete (AL code exists)
- Optionally: `.dev/02-solution-plan.md` for context

---

## How This Command Works (v3.0)

**Your Role:** Engineering Manager
**Teammates:** 4 test engineer specialists (parallel work)
**You:** Partition test scenarios, manage bc-test execution, iterate on failures, present passing suite

### ❌ DON'T
- Write tests yourself
- Accept failing tests
- Skip edge cases or error scenarios

### ✅ DO
- Spawn 4 test engineers for parallel development
- Assign clear ID ranges to avoid conflicts
- Run bc-test and manage iteration on failures
- Present only when ALL tests pass

---

## Implementation Steps

### Step 1: Read Implementation (2-3 min)

```
1. Find and read implemented AL files
2. Understand what needs testing:
   - Business logic to validate
   - Data validation rules
   - UI workflows
   - Integration points
3. Read .dev/02-solution-plan.md if available (for context)
```

### Step 2: Identify Test Scenarios (3-5 min)

```
Categorize test needs:

UNIT TESTS (isolated functions):
- Calculation methods
- Validation logic
- Data transformations
- Pure functions

INTEGRATION TESTS (object interactions):
- Table ↔ Codeunit interactions
- Event subscribers
- Multi-object workflows
- API integrations

SCENARIO TESTS (end-to-end):
- Complete user workflows
- UI → Business Logic → Database
- Real-world use cases

EDGE CASES (boundaries/errors):
- Null/empty inputs
- Boundary values (min/max)
- Error conditions
- Invalid data
```

### Step 3: Assign Object ID Ranges (1 min)

```
Partition test codeunit IDs to avoid conflicts:

- Unit tests: 50100-50199
- Integration tests: 50200-50299
- Scenario tests: 50300-50399
- Edge case tests: 50400-50499

Adjust ranges based on project's available IDs.
```

### Step 4: Spawn Test Engineering Team (10-30 min)

```
Create agent team with 4 test engineers:

"Unit Test Engineer: Develop unit tests for [feature].

 Test codeunit ID range: 50100-50199
 Focus: Individual methods and functions
 - [List key methods to test from implementation]

 Use AL Test Framework.
 Each test method should verify one behavior.
 Include assertions for expected outcomes."

"Integration Test Engineer: Develop integration tests for [feature].

 Test codeunit ID range: 50200-50299
 Focus: Cross-object interactions
 - [List integration points from implementation]

 Test event subscribers, table-codeunit flows, API integrations."

"Scenario Test Engineer: Develop end-to-end scenario tests for [feature].

 Test codeunit ID range: 50300-50399
 Focus: Complete user workflows
 - [List business scenarios from solution plan]

 Simulate real user actions from UI through to database."

"Edge Case Test Engineer: Develop edge case and error tests for [feature].

 Test codeunit ID range: 50400-50499
 Focus: Boundaries, nulls, errors, invalid data
 - [List edge cases to cover]

 Test error handling, validation failures, boundary conditions."
```

### Step 5: Monitor Test Development (Ongoing)

```
While test engineers work:

1. Check for ID conflicts
   - No two engineers using same test codeunit ID

2. Answer technical questions
   - How to mock dependencies?
   - Which test fixtures to use?

3. Verify test coverage alignment
   - Are all key scenarios covered?
   - Any gaps in coverage?
```

### Step 6: Run bc-test (2-5 min)

```
When all test engineers complete:

1. Run bc-test on all test codeunits:
   bc-test --output-file .dev/test-results.txt

2. Analyze results:
   ✅ All passing → Step 8 (present to user)
   ❌ Some failing → Step 7 (iterate)
```

### Step 7: Iterate on Failures (5-20 min per iteration)

```
For each failing test:

1. Identify which engineer owns it (by ID range)

2. Assign fix to that engineer:
   "Unit Test Engineer, test 'ValidateCreditLimit_NegativeValue'
    is failing with error: [error message].
    Fix the test or the test assumption."

3. Engineer fixes test

4. Re-run bc-test

5. Repeat until all tests pass
```

**Don't present to user until all tests pass.**

### Step 8: Write .dev/05-test-plan.md (3-5 min)

```
YOU write the synthesis:

## Test Plan: [Feature Name]

### Test Coverage Summary
- Unit tests: [N] tests covering [methods/functions]
- Integration tests: [N] tests covering [integrations]
- Scenario tests: [N] tests covering [workflows]
- Edge case tests: [N] tests covering [boundaries/errors]

**Total:** [N] tests, all passing ✅

### Test Codeunits Created
- Test Codeunit 50100: "[Name]" - Unit tests
- Test Codeunit 50200: "[Name]" - Integration tests
- Test Codeunit 50300: "[Name]" - Scenario tests
- Test Codeunit 50400: "[Name]" - Edge case tests

### Key Test Scenarios
[List 5-10 most important test scenarios with brief descriptions]

### Test Execution
Command: bc-test --output-file .dev/test-results.txt
Result: All [N] tests passing ✅

### Coverage Analysis
Covered:
- [Key functionality 1]
- [Key functionality 2]
- [Key functionality 3]

Not covered (if applicable):
- [Gap 1]: [Rationale for skipping]

### Test Maintenance Notes
[How to run tests, dependencies, special setup if needed]
```

### Step 9: Clean Up Team

```
Shut down all test engineers:
"Unit test engineer, shut down"
"Integration test engineer, shut down"
"Scenario test engineer, shut down"
"Edge case test engineer, shut down"

Clean up team resources:
"Clean up the team"
```

### Step 10: Present to User 🛑

```
"Test suite complete → [N] tests, all passing ✅

Test coverage:
- Unit: [N] tests (methods/functions)
- Integration: [N] tests (object interactions)
- Scenario: [N] tests (end-to-end workflows)
- Edge cases: [N] tests (boundaries/errors)

Test results → .dev/test-results.txt
Test plan → .dev/05-test-plan.md

All tests verified with bc-test.

Ready for deployment?"

Use AskUserQuestion:
- Approve - Tests are adequate
- Add More Tests - What scenarios should I add?
- Review Failures - Show me which tests are problematic
- Stop
```

---

## Output Files

**YOU create:**
- `.dev/05-test-plan.md` - Synthesized test plan
- `.dev/test-results.txt` - bc-test output

**Test engineers create:**
- Test codeunit files (one or more per engineer)

---

## Success Criteria

✅ 4 test engineers developed tests in parallel
✅ No ID conflicts (clear range assignments)
✅ All test categories covered (unit, integration, scenario, edge)
✅ bc-test executed successfully
✅ All tests passing before presentation
✅ .dev/05-test-plan.md documents comprehensive coverage

---

## Tips

**Assign Specific Scenarios:**
Don't just say "write tests" - list specific scenarios:
- "Test ValidateCredit with negative amount"
- "Test posting when credit limit is exactly at max"
- "Test UI validation triggers on field change"

**Use bc-test Features:**
```bash
# All tests
bc-test

# Specific codeunit
bc-test --codeunit-id 50100

# Output to file
bc-test --output-file .dev/test-results.txt

# Failures only
bc-test --failures-only
```

**Iterate Until All Pass:**
Never present failing tests. Manage iteration between engineers and test execution.

---

**Remember:** Spawn 4 specialized test engineers, assign clear ID ranges, run bc-test, iterate until all pass, then present.
