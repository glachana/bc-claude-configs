---
name: bcquality-citation
description: Mandatory protocol for subagents to ground AL/BC work in Microsoft's BCQuality knowledge corpus (served by the bcquality-mcp server) and cite it by path. Use when a subagent designs, generates, reviews, or tests AL code and must back its decisions with traceable BCQuality references. Defines the MCP tools, layer precedence, the three usage modes (DESIGN/GENERATE/CHECK), targeted retrieval, the references[] citation contract, and the agent-to-domain-to-mode mapping.
---

# BCQuality Citation Protocol (MANDATORY for subagents)

This defines how every subagent consumes Microsoft's **BCQuality** corpus — served by the
**`bcquality-mcp`** MCP server — and cites it.

> Source: https://github.com/microsoft/BCQuality (MIT), via the Dynamics International fork
> https://github.com/DynamicsInternational/BCQuality (adds the `custom/` layer). The plugin
> points `bcquality-mcp` at the fork through `BCQUALITY_REPO_URL` in `.mcp.json`.
> The corpus is no longer vendored in the plugin — the MCP clones + indexes it.

---

## The principle: additive, not authoritative

BCQuality **sharpens** your judgment; it does not replace it. Roles are distinct and
must not be confused:

- **MCP specialists** (`bc-code-intelligence-mcp`) = the **judge**. They reason and set
  severity. See the `bc-expert-consultation` skill.
- **BCQuality** (`bcquality-mcp`) = the **cited jurisprudence**. A figured rule you point
  to by path instead of paraphrasing from memory.

These run side by side. They are never stacked into one engine and never arbitrated
against each other on equal footing — see *Conflict handling* below.

---

## The MCP tools

All tools are prefixed `bcquality_`. The corpus has three layers with **increasing
precedence: `microsoft` < `community` < `custom`** — when two layers cover the same slug,
the higher one wins and the others appear in `suppressed[]`. The path returned always shows
the authority level, so a community- or DynInter-backed finding stays visibly sourced.

Domains: `performance`, `security`, `privacy`, `style`, `ui`, `testing`, `upgrade`.

| When you need… | Tool |
|---|---|
| Applicable rules **with sections inlined**, given a goal + BC context (the workhorse 🌟) | `bcquality_get_applicable_for_context` |
| Full-text search with frontmatter filters | `bcquality_search_knowledge` |
| One rule, parsed (frontmatter + sections + sample paths) | `bcquality_get_knowledge` |
| The `.good.al` / `.bad.al` samples for a rule | `bcquality_get_examples` |
| Browse domains / list rules with filters | `bcquality_list_domains`, `bcquality_list_knowledge` |
| Meta-skills and action skills | `bcquality_list_skills`, `bcquality_get_skill` |

Each rule has YAML frontmatter (`bc-version`, `domain`, `keywords`, `technologies`,
`countries`, `application-area`), `## Description`, optional `## Best Practice` /
`## Anti Pattern`, and often sibling `.good.al` / `.bad.al` samples.

---

## The three usage modes

Your spawn role determines how you use the corpus.

### DESIGN — solution-architect
Call `bcquality_get_applicable_for_context` with your design goal **before** proposing an
approach. Design *within* the rules. In your plan, name the rules that shape the
architecture (e.g. "batch is chunked to honor `avoid-commit-inside-loops`"). Prevent issues
at design time.

### GENERATE — al-developer
Before writing AL, call `bcquality_get_applicable_for_context` for what you are about to
build. Write **conforming** code. Pull `bcquality_get_examples` to follow `.good.al`
patterns and avoid `.bad.al` ones. In code comments or your hand-off note, cite the rule a
non-obvious choice satisfies. Prevent issues at write time.

### CHECK — reviewers and test engineers
Evaluate the code **against** the rules and emit findings with citations. Reviewers cite the
rule a violation breaks (`bcquality_search_knowledge` / `get_applicable_for_context` to find
it, `bcquality_get_knowledge` to quote it). Test engineers turn `.bad.al` samples
(`bcquality_get_examples`) into negative test scenarios — a `.bad.al` is literally "code
that should fail".

---

## Targeted retrieval (let the MCP do the filtering — do NOT dump the whole corpus)

The corpus is ~250 rules. Retrieve only what the task needs:

1. **Context call** — `bcquality_get_applicable_for_context` with `goal`, `technologies`
   (default `["al"]`), `bcVersion`, optionally `countries` / `applicationArea` / `layers`.
   It runs Source → Relevance → Worklist scoring server-side and returns the top rules with
   their sections already inlined — usually all you need.
2. **Refine** — if you need a specific concern not surfaced, `bcquality_search_knowledge`
   with a focused query + `domain` filter.
3. **Deep-read** — `bcquality_get_knowledge` on a path for the full parsed rule;
   `bcquality_get_examples` when a sample clarifies the fix or seeds a test.
4. **Version filter** — the MCP filters on `bcVersion` when you pass it; otherwise drop
   rules whose `bc-version` does not cover the project's BC version.

---

## The citation contract

Every finding / decision that maps onto a BCQuality rule carries:

- `rule`: the slug (e.g. `avoid-get-inside-loop-on-large-table`).
- `references`: the repo-relative path(s) returned by the MCP, e.g.
  `[{ "path": "microsoft/knowledge/performance/avoid-get-inside-loop-on-large-table.md" }]`.
  A DynInter rule reads `custom/knowledge/style/<slug>.md` — visibly our house position.

**Do NOT paraphrase a rule from memory** — cite the path the MCP returned so the finding is
auditable (defensible in a PR or to a client). A cited path must be one the MCP actually
returned; it is re-checkable any time via `bcquality_get_knowledge`.

When your judgment fires but **no** BCQuality rule maps, prefix the slug with `house:`
(e.g. `house:dyninter-xyz`) and leave `references: []`. House findings are legitimate —
they mark where the corpus has a gap (candidate for the fork's `custom/` layer).

---

## Conflict handling

If a BCQuality rule and the MCP specialist disagree: the **specialist wins on severity**
(it is the judge). Cite the BCQuality rule anyway so the chain stays traceable, and note
the divergence. If a `custom/` (DynInter) rule conflicts with a `microsoft/` rule, the
custom layer wins (it is our deliberate house position — the MCP already reflects this in
precedence and `suppressed[]`).

---

## Prompt → domain → mode mapping (personas live in skill prompts, not `agents/`)

The lead injects these prompts into spawned agents. Each carries its BCQuality section.

| Prompt | Domains | Mode |
|---|---|---|
| `skills/plan/solution-architect-prompt.md` | performance, security, upgrade, ui | DESIGN |
| `skills/develop/al-developer-prompt.md` | all (scoped to what is being written) | GENERATE |
| `skills/develop/reviewer-prompts.md` → Security Reviewer | security, privacy | CHECK |
| `skills/develop/reviewer-prompts.md` → AL Expert Reviewer | style, ui (+ custom prefix rule) | CHECK |
| `skills/develop/reviewer-prompts.md` → Performance Reviewer | performance | CHECK |
| `skills/develop/reviewer-prompts.md` → Test Coverage Reviewer | testing | CHECK |
| `skills/test/test-engineer-prompts.md` (all 4 engineers) | testing (+ `.bad.al` as negative scenarios) | CHECK |
| `skills/document/docs-writer-prompt.md` | cite rules behind documented decisions | light |

Naming guardrails also live in the auto-loaded `rules/al-naming.md`, which defers to the
DynInter prefix rule `custom/knowledge/style/affix-as-prefix-on-custom-identifiers.md`
(retrievable via `bcquality_get_knowledge`).

---

## Lead enforcement (gate)

The lead (Engineering Manager) treats BCQuality citation as a **hard quality gate**,
parallel to the mandatory MCP consultation:

- Reject a reviewer's findings if a finding plainly maps a rule but carries no `references[]`.
- Reject an architect's plan or a developer's hand-off that touches a covered domain but
  cites no rule and offers no `house:` justification.
- Acceptable escape hatches: an explicit `house:` finding (corpus gap), or a stated
  "no rule applies in domain X for this change."

A subagent that cannot reach `bcquality-mcp` must say so explicitly and fall back to MCP
specialist guidance + its own judgment — never silently skip. Cited paths are re-verifiable
on demand with `bcquality_get_knowledge` (catches hallucinated or stale paths).
