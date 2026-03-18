---
description: Review an incoming Azure DevOps pull request - technical analysis with actionable ADO comments
allowed-tools: ["Task", "Read", "Glob", "Grep", "Bash", "AskUserQuestion", "mcp__azure-devops__*"]
---

**Analyze an incoming PR and generate detailed ADO comments on demand.**

---

## Usage

```bash
/review-pr <PR-ID>
/review-pr 142
```

**Prerequisites:** run from the project directory so that git and the local workspace are accessible.

---

## Your Role in This Command

You are the **senior architect** receiving a PR for review. You did not write it. Your job is to decide whether it is mergeable, identify real technical problems, and when needed draft clear comments to help the developer fix the issues.

### ❌ DON'T
- Approve blindly because it "looks fine"
- Comment on style with no functional impact
- Post ADO comments without explicit user approval

### ✅ DO
- Run a technical analysis using the 4 specialist reviewers
- Present a severity-sorted summary
- Draft detailed ADO comments **only when the user asks**
- Post a comment to ADO **only after user approval**

---

## Phase 1: Fetch & Analyze

### Step 1: Retrieve PR Data

Via ADO MCP, fetch:
- Title, description, author, source/target branch
- List of modified files (paths)
- Full diff of modified AL files

```
ADO MCP tools to use:
- azure_devops_get_pull_request        → PR metadata
- azure_devops_list_pull_request_files → modified files
- azure_devops_get_pull_request_diff   → change content
```

Build a review context header:
```
PR #[ID] — [Title]
Author: [name]
Branch: [source] → [target]
Modified files: [N] AL files
```

### Step 2: Access the Code

**Option A — Branch available locally (preferred):**
```bash
git fetch origin
git checkout [source-branch]
```
→ Reviewers use `Read`/`Glob`/`Grep` directly on the files.

**Option B — Work from the diff (if branch not available locally):**
→ Pass diff content directly in the reviewer prompts.

Auto-detect which option applies using `git branch -r`.

### Step 3: Classify PR Size

| Size   | AL Files   | Approach |
|--------|------------|----------|
| Small  | 1-3 files  | 4 reviewers, reduced scope |
| Medium | 4-8 files  | 4 reviewers, full scope |
| Large  | 9+ files   | 4 reviewers, flag complexity in summary |

### Step 4: Spawn 4 Reviewers in Parallel

**⚠️ CRITICAL CONTEXT NUANCE — Incoming PR:**

All reviewers receive this additional context in their prompt:

```
CONTEXT: You are reviewing a PR submitted by another developer.
You did not participate in its design. Your role is to determine whether
this code is mergeable as-is, and to identify real technical problems.

Focus on:
- Real problems (security, bugs, incorrect patterns)
- Anything that could cause production issues
- Clear violations of AL/BC standards

Do NOT flag:
- Stylistic preferences with no functional impact
- Things that are "different from what you would have done" without technical justification
- Unjustified optional suggestions

For each finding: File + Line + Problem + Why it is a risk + Concrete fix.
```

**Prompt for each reviewer:**

```
[INCOMING PR CONTEXT NUANCE above]

Files to review: [list of modified file paths]
[If Option B: diff content below]

Review the code from your specialist angle.
Return your findings formatted by severity (Critical / High / Medium / Low).
```

Spawn all 4 reviewers in parallel:
- `security-reviewer` — security, permissions, data exposure
- `al-expert-reviewer` — AL conventions, BC patterns, best practices
- `performance-reviewer` — queries, N+1, SetLoadFields, loops
- `test-coverage-reviewer` — testability, coverage, missing injections

### Step 5: Consolidate Findings

Collect outputs from all 4 reviewers and deduplicate:
- If 2+ reviewers flag the same problem → note the consensus (strengthens severity)
- If a reviewer flags something others contradict → note the disagreement, apply your own judgment

---

## Phase 2: Present Summary

Present to the user:

```
## PR #[ID] — [Title]
**Author:** [name] | **Branch:** [source] → [target] | **Files:** [N]

---

### Verdict
[APPROVE / REQUEST CHANGES / NEEDS DISCUSSION]
[1-2 sentence justification]

---

### Critical ([N])
1. `[File.al:line]` — [Short problem description]
   > [Risk: why this is critical]

### High ([N])
1. `[File.al:line]` — [Short problem description]
   > [Impact]

### Medium ([N])
1. `[File.al:line]` — [Short problem description]

### Low ([N])
1. `[File.al:line]` — [Suggestion]

---

**Reviewers:** security ✓ | AL expert ✓ | performance ✓ | test coverage ✓
```

Then ask:

```
AskUserQuestion:
"What do you want to do with these findings?"

Options:
- "Draft an ADO comment"      → select specific finding(s) to comment on
- "Comment all Critical+High" → generate all comments at once
- "Approve the PR"            → post an ADO approval
- "Done"                      → no ADO action
```

---

## Phase 3: Draft ADO Comments

For each finding selected by the user, draft a Markdown comment:

### ADO Comment Format

```markdown
**[Critical | High | Medium | Low] — [Short problem title]**

**Problème :**
[Clear description of the technical issue in French, 2-4 sentences. Explain WHAT is wrong, not just "this is bad".]

**Risque :**
[What can concretely happen if this is not fixed — bug, vulnerability, performance degradation, etc.]

**Correctif suggéré :**

Code actuel :
```al
[excerpt of the problematic code]
```

Code corrigé :
```al
[concrete AL fix example]
```

[Add any additional explanation in French if the fix requires context.]
```

### Comment Rules

- **Tone:** professional, constructive, factual — never condescending
- **Detail level:** enough for the developer to understand AND fix without looking elsewhere
- **AL code:** always provide a concrete example, never just "use SetLoadFields"
- **Language:** French by default. Code examples and AL identifiers remain in English. Only switch to English if the user explicitly requests it.

### Show Comment Before Posting

```
"Here is the comment I will post on [File.al:line]:

[full comment]

Shall I post this comment on the PR?"

Options:
- "Yes, post it"
- "Edit first"  → adjust then re-confirm
- "Cancel"
```

### Post via ADO MCP

```
azure_devops_create_pull_request_thread:
- pullRequestId: [PR-ID]
- filePath:      [file path]
- line:          [line number]
- content:       [Markdown comment]
- status:        "active"
```

Confirm after posting: `Comment posted on PR #[ID] — [file:line]`

---

## Edge Cases

### PR with no description
Note in the summary: *"This PR has no description — the developer's intent cannot be validated."*
Add as a Medium finding if no context is provided at all.

### Very large PR (9+ files)
Warn the user:
*"This PR contains [N] files. A PR of this size is hard to review effectively. Consider asking the author to split it."*
Continue the review normally.

### Non-AL files modified (JSON, XML, etc.)
Note them in the summary but do not submit them to the AL specialist reviewers.
Example: *"app.json modified — verify the version bump."*

### No critical findings
```
"No Critical or High issues identified.
[N] Medium/Low findings documented above.
The PR appears technically mergeable."
```

---

## Cleanup

After the session:
```
Shut down reviewers:
"Security reviewer, shut down"
"AL expert reviewer, shut down"
"Performance reviewer, shut down"
"Test coverage reviewer, shut down"
```

---

## Success Criteria

- PR fetched via ADO MCP
- 4 reviewers analyzed the code with the incoming PR context nuance
- Summary presented by severity with a clear verdict
- Comments drafted in French with concrete AL code examples
- No comment posted without explicit user approval
- Constructive tone — helps the developer fix, does not judge
