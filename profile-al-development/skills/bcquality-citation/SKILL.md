---
name: bcquality-citation
description: Mandatory protocol for subagents to ground AL/BC work in Microsoft's BCQuality knowledge corpus (vendored in the plugin) and cite it by file path. Use when a subagent designs, generates, reviews, or tests AL code and must back its decisions with traceable BCQuality references. Defines the corpus location, layer precedence, the three usage modes (DESIGN/GENERATE/CHECK), targeted retrieval, the references[] citation contract, and the agent-to-domain-to-mode mapping.
---

# BCQuality Citation Protocol (MANDATORY for subagents)

This defines how every subagent consumes Microsoft's **BCQuality** corpus — vendored
in the plugin at `${CLAUDE_PLUGIN_ROOT}/bcquality/` — and cites it.

> Source: https://github.com/microsoft/BCQuality (MIT). Vendored, read-only.
> Re-vendor with `scripts/revendor-bcquality.ps1`.

---

## The principle: additive, not authoritative

BCQuality **sharpens** your judgment; it does not replace it. Roles are distinct and
must not be confused:

- **MCP specialists** (`bc-code-intelligence-mcp`) = the **judge**. They reason and set
  severity. See the `bc-expert-consultation` skill.
- **BCQuality** = the **cited jurisprudence**. A figured rule you point to by file path
  instead of paraphrasing from memory.

These run side by side. They are never stacked into one engine and never arbitrated
against each other on equal footing — see *Conflict handling* below.

---

## Where the corpus lives

```
${CLAUDE_PLUGIN_ROOT}/bcquality/
├── custom/knowledge/<domain>/      # DynInter rules (our own; highest precedence; may be absent)
├── community/knowledge/<domain>/   # community-contributed (performance, security)
└── microsoft/knowledge/<domain>/   # Microsoft-endorsed (all 7 domains; authoritative)
```

Domains: `performance`, `security`, `privacy`, `style`, `ui`, `testing`, `upgrade`.

Each rule is `<slug>.md` (YAML frontmatter: `bc-version`, `domain`, `keywords`,
`technologies`, `countries`, `application-area`; sections `## Description`,
`## Best Practice`, `## Anti Pattern`), often with `<slug>.good.al` / `<slug>.bad.al`
sibling code samples.

**Layer precedence: `custom` > `community` > `microsoft`.** When the same concern
appears in two layers, the higher one wins. The cited path always shows the authority
level, so a community-backed finding stays visibly community-sourced.

---

## The three usage modes

Your spawn role determines how you use the corpus.

### DESIGN — solution-architect
Read the relevant domain rules **before** proposing an approach. Design *within* the
rules. In your plan, name the rules that shape the architecture (e.g. "batch is
chunked to honor `avoid-commit-inside-loops`"). Prevent issues at design time.

### GENERATE — al-developer
Before writing AL, pull the rules for what you are about to build. Write **conforming**
code. Lean on `<slug>.good.al` samples as patterns to follow and `<slug>.bad.al` as
patterns to avoid. In code comments or your hand-off note, cite the rule a non-obvious
choice satisfies. Prevent issues at write time.

### CHECK — reviewers and test engineers
Evaluate the code **against** the rules and emit findings with citations. Reviewers
cite the rule a violation breaks. Test engineers turn `<slug>.bad.al` samples into
negative test scenarios (a `.bad.al` is literally "code that should fail").

---

## Targeted retrieval (do NOT read the whole corpus)

The corpus is ~400 files. Retrieve only what the task needs:

1. **Source** — limit to your assigned domain folder(s), across all present layers:
   `${CLAUDE_PLUGIN_ROOT}/bcquality/{custom,community,microsoft}/knowledge/<domain>/`
2. **Relevance** — `Grep` the folder(s) by task vocabulary (the objects, triggers,
   patterns in scope). Match `keywords` frontmatter.
3. **Worklist** — `Read` only the 2–6 matching `<slug>.md` files. Read the sibling
   `.al` samples only when a sample clarifies the fix or seeds a test.
4. **Filter** — drop rules whose `bc-version` does not cover the project's BC version.

---

## The citation contract

Every finding / decision that maps onto a BCQuality rule carries:

- `rule`: the slug (e.g. `avoid-get-inside-loop-on-large-table`).
- `references`: the file path(s), e.g.
  `[{ "path": "bcquality/microsoft/knowledge/performance/avoid-get-inside-loop-on-large-table.md" }]`.

**Do NOT paraphrase a rule from memory** — cite the file so the finding is auditable
(defensible in a PR or to a client).

When your judgment fires but **no** BCQuality rule maps, prefix the slug with `house:`
(e.g. `house:dyninter-abc-prefix`) and leave `references: []`. House findings are
legitimate — they mark where the corpus has a gap (candidate for the `custom/` layer).

---

## Conflict handling

If a BCQuality rule and the MCP specialist disagree: the **specialist wins on severity**
(it is the judge). Cite the BCQuality rule anyway so the chain stays traceable, and note
the divergence. If a `custom/` (DynInter) rule conflicts with a `microsoft/` rule, the
custom layer wins (it is our deliberate house position).

---

## Agent → domain → mode mapping

| Agent | Domains | Mode |
|---|---|---|
| `solution-architect` | performance, security, upgrade, ui | DESIGN |
| `al-developer` | all (scoped to what is being written) | GENERATE |
| `security-reviewer` | security, privacy | CHECK |
| `al-expert-reviewer` | style, ui | CHECK |
| `performance-reviewer` | performance | CHECK |
| `test-coverage-reviewer` | testing | CHECK |
| `unit-test-engineer` | testing | CHECK |
| `integration-test-engineer` | testing | CHECK |
| `scenario-test-engineer` | testing | CHECK |
| `edge-case-test-engineer` | testing (+ `.bad.al` as negative scenarios) | CHECK |
| `docs-writer` | (cite rules behind documented decisions, when relevant) | light |
| `interview` | — (elicits requirements, not code) | n/a |

---

## Lead enforcement (gate)

The lead (Engineering Manager) treats BCQuality citation as a **hard quality gate**,
parallel to the mandatory MCP consultation:

- Reject a reviewer's findings if a finding plainly maps a vendored rule but carries no
  `references[]`.
- Reject an architect's plan or a developer's hand-off that touches a covered domain but
  cites no rule and offers no `house:` justification.
- Acceptable escape hatches: an explicit `house:` finding (corpus gap), or a stated
  "no rule applies in domain X for this change."

A subagent that cannot reach the corpus must say so explicitly and fall back to MCP
specialist guidance + its own judgment — never silently skip.
