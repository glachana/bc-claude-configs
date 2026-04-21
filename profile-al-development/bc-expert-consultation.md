# BC Expert Consultation Protocol (MANDATORY for subagents)

This document defines the BC expert consultation workflow via the `mcp__bc-code-intelligence-mcp` MCP server.

> Source of experts: https://github.com/JeremyVyska/bc-code-intelligence-mcp

---

## Scope

- **Mandatory** for every spawned teammate (subagent) in this plugin: developer, reviewers, test engineers, solution-architect, interview, docs-writer.
- **Discretionary** for the lead (main Claude session acting as Engineering Manager). The lead chooses when to consult directly — typically for quick sanity checks, arbitrating teammate disagreements, or confirming tactical decisions. Subagents spawned by the lead still carry the mandatory obligation on their own work.

---

## Why Mandatory (for subagents)

Every subagent — developer, reviewer, test engineer, architect, interviewer, documenter — owns a slice of the BC problem space. The BC Code Intelligence MCP exposes 17 specialist personas (Alex Architect, Dean Debug, Seth Security, Quinn Tester, Roger Reviewer, Sam Coder, Taylor Docs, Eva Errors, Jordan Bridge, Maya Mentor, Logan Legacy, Morgan Market, Victor Versioning, Uma UX, Lena Pipe, Chris Config, Parker Pragmatic) backed by a curated BC knowledge base.

Subagents run in isolated contexts with limited view of the project; grounding their output in specialist guidance prevents hallucinated patterns and keeps deliverables consistent.

---

## Required Workflow (subagents — mandatory; lead — optional)

### Step 1 — Initialize the workspace (once per session)

Before calling any other `bc-code-intelligence-mcp` tool, call:

```
mcp__bc-code-intelligence-mcp__set_workspace_info
  workspace_root: <absolute path of the current project>
  available_mcps: ["bc-code-intelligence-mcp", "al-mcp-server", "microsoft_docs_mcp"]
```

If the server answers `"Server Not Yet Initialized"` on any later call, retry this step. It is idempotent.

### Step 2 — Ask the preferred specialist

For every significant decision or output, call:

```
mcp__bc-code-intelligence-mcp__ask_bc_expert
  question: "<concrete, specific question tied to the work you are about to produce>"
  preferred_specialist: "<specialist-id from the table below>"
```

Good questions are specific: *"What is the idiomatic BC pattern for validating a credit limit on OnBeforePostSalesDoc without blocking credit-memo posting?"*
Bad questions are vague: *"How do I do this?"*

### Step 3 — Integrate the guidance

- Quote or summarize the relevant advice in your output file (e.g. `.dev/02-solution-plan.md`, `.dev/03-code-review.md`, etc.).
- If the expert disagrees with your initial approach, **adjust** before finalizing. Do not silently ignore.
- If several specialists apply, consult each in turn.

### Step 4 — Complementary knowledge tools (optional but encouraged)

- `find_bc_knowledge` — keyword search across the BC knowledge base.
- `get_bc_topic` — fetch a full topic by id.
- `analyze_al_code` — static analysis of an AL snippet against BC best practices.
- `list_specialists` — re-list specialists if you are unsure whom to ask.

---

## Specialist Map (Who to Ask For What)

| Agent | Primary specialist(s) | Secondary / situational |
|---|---|---|
| `interview` | `alex-architect` (requirements, solution shape) | `jordan-bridge` (integration), `morgan-market` (AppSource impact) |
| `solution-architect` | `alex-architect`, `jordan-bridge` | `logan-legacy` (existing code), `victor-versioning` (upgrade paths) |
| `al-developer` | `sam-coder` (patterns, code generation) | `eva-errors` (error handling), `maya-mentor` (AL language), `roger-reviewer` (self-check) |
| `al-expert-reviewer` | `roger-reviewer` (code quality) | `maya-mentor` (AL idioms), `sam-coder` (pattern validation) |
| `performance-reviewer` | `dean-debug` (performance, query optimization) | `sam-coder` (pattern-level performance) |
| `security-reviewer` | `seth-security` (permissions, data access) | `eva-errors` (defensive programming), `jordan-bridge` (API surface) |
| `test-coverage-reviewer` | `quinn-tester` (coverage, strategy) | `parker-pragmatic` (validation, trust) |
| `unit-test-engineer` | `quinn-tester` (test design) | `sam-coder` (testable patterns) |
| `integration-test-engineer` | `quinn-tester` | `jordan-bridge` (events, cross-object) |
| `scenario-test-engineer` | `quinn-tester` | `uma-ux` (realistic user workflows) |
| `edge-case-test-engineer` | `quinn-tester` | `eva-errors` (boundary and error paths) |
| `docs-writer` | `taylor-docs` (technical writing) | `maya-mentor` (explanation quality) |

If a request clearly lands in another specialist's territory (e.g., CI/CD → `lena-pipe`, versioning → `victor-versioning`, MCP/layer config → `chris-config`), route there instead.

---

## Failure Mode

If `mcp__bc-code-intelligence-mcp` is unreachable or returns an error after a retried `set_workspace_info`, the agent must:

1. **Record the failure explicitly** in its output file (e.g., "BC expert consultation unavailable this session — proceeded on general AL knowledge").
2. **Proceed conservatively** — prefer standard BC patterns and avoid speculative architecture choices.
3. **Flag the work** for re-review when the MCP is available again.

Never silently skip the consultation.
