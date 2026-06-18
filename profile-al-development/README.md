# AL Development Profile

**Version:** 5.2.2

Claude Code plugin for Microsoft Dynamics 365 Business Central (AL) development. Document-driven workflow, complexity-based routing, a 4-specialist review team, and a BCQuality citation gate that grounds every recommendation in a traceable rule.

> This is the DynInter fork of Stefan Maron's `bc-claude-configs`, with additions:
> BCQuality citation protocol, mandatory BC-expert consultation, DynInter naming
> convention (prefix-only), French translation skill, and Azure DevOps PR review.

## Architecture (v5.x)

The plugin is **skills-based**. There is no standalone agent roster anymore — the lead
session orchestrates and spawns specialist *personas* from prompt files inside each skill.

```
User Request
    ↓ (lead classifies complexity → workflow-routing skill)
/interview (optional)  → deep requirements gathering
    ↓
/plan      → 2-3 solution-architect personas debate, synthesize winning plan
    ↓  [approval gate]
/develop   → parallel al-developer personas, then 4-specialist review team
    ↓  [approval gate]
/test      → 4 parallel test-engineer personas (unit / integration / scenario / edge)
    ↓
/document  → docs-writer persona
```

All output goes to `.dev/<task-slug>/` (per-task), with `.dev/project-context.md` shared
across tasks. Personas write detailed files and return concise summaries — the main
conversation stays clean.

## Getting Started

1. **Enable the plugin** in your AL project's `.claude/settings.json`
   (`extraKnownMarketplaces` + `enabledPlugins`).
2. **One-time setup:** run `/init-context` to generate `.dev/project-context.md`
   (indexes objects, patterns, integration points → 40-60% faster workflows).
3. **Then describe your task** and let the lead route it, or invoke a workflow directly.

## Skills

### Workflow skills (invoke with `/`)
| Skill | Purpose |
|-------|---------|
| `/init-context` | One-time project context indexing |
| `/interview` | Deep requirements gathering |
| `/plan` | Competitive solution design (2-3 architects debate) |
| `/develop` | Parallel implementation + 4-specialist review |
| `/fix` | Lightweight bug fix (no planning/testing) |
| `/test` | Parallel test development (4 engineers) |
| `/document` | Technical documentation generation |

### Build / CLI skills (invoke with `/`)
| Skill | Purpose |
|-------|---------|
| `/compile` | Run al-compile with analyzers |
| `/publish` | Deploy `.app` to a BC server |
| `/run-tests` | Execute AL test codeunits (al-runner / bc-test) |
| `/translate` | Translate XLIFF localization (default fr-FR) via NAB AL Tools |
| `/al-symbols` | Download dependency symbol packages |
| `/al-mutate` | Mutation testing |
| `/verify-tests` | Adversarial test verification |

### Knowledge / plumbing skills (auto-loaded when relevant — not invoked manually)
`workflow-routing`, `proportional-planning`, `feedback-resolution`, `task-coordination`,
`tdd-workflow`, `management-patterns`, `build-tools`, `review-checklists`,
`bc-cli-tools`, `bcquality-citation`, `bc-expert-consultation`, `local-bc`, `bc-source`.

### Commands
| Command | Purpose |
|---------|---------|
| `/review-pr <id>` | Review an incoming Azure DevOps PR (4 specialist reviewers → ADO comments) |

## Complexity Routing

| Complexity | Criteria | Route |
|------------|----------|-------|
| TRIVIAL | Single file, obvious fix | `/fix` |
| SIMPLE | 2-3 files, pattern exists | `/fix` or `/plan` → `/develop` |
| MEDIUM | 4-8 files, design decisions | `/plan` → `/develop` |
| COMPLEX | New architecture, unclear reqs | `/interview` → `/plan` → `/develop` → `/test` |

## BCQuality Citation Gate

The plugin vendors Microsoft's **BCQuality** corpus at `bcquality/` (microsoft + community
layers) plus a `custom/` layer of DynInter rules. Specialist personas back findings with a
`[BCQuality: path]` citation instead of paraphrasing from memory. The MCP
`bc-code-intelligence-mcp` remains the reasoning *judge*; BCQuality is the *cited jurisprudence*.

- Indexes per domain: `bcquality/_index/{performance,privacy,security,style,testing,ui,upgrade}.md`
- Protocol & modes (DESIGN/GENERATE/CHECK): `skills/bcquality-citation/SKILL.md`
- Re-vendor the corpus: `scripts/revendor-bcquality.ps1`
- A turn-end hook verifies citations: `hooks/al-hook-verify-citations.sh`

**Lead enforcement (hard gate):** a deliverable touching a covered domain must cite a
`[BCQuality: path]`, or justify a `house:` exception, or state "no rule applies".

## DynInter Customizations

- **Naming convention** (`rules/al-naming.md` + `bcquality/custom/style/...`): affix used as
  **prefix only**, never suffix. Table-extension fields prefixed; fields on a dedicated
  custom table are not.
- **Mandatory BC-expert consultation** before finalizing any AL/BC deliverable
  (`skills/bc-expert-consultation/SKILL.md`).
- The local specialist knowledge layer (`bc-code-intel-knowledge/`) was removed in favor of
  the BCQuality corpus + the MCP's bundled knowledge.

## MCP Servers

| Server | Use |
|--------|-----|
| `bc-code-intelligence-mcp` | BC specialist consultations (the reasoning judge) |
| `microsoft_docs_mcp` | Official AL/BC documentation lookup |
| `al-mcp-server` | Base app object navigation, event discovery |
| `alcops` | AL code analysis / fixes |
| `nab-al-tools` | XLIFF translation tooling |

**Rule:** the main conversation never calls MCP tools directly — only spawned personas do.

## Auto-loaded Rules

`rules/` provides standing AL guardrails without skill invocation: `al-engineering.md`
(always), plus `al-architecture.md`, `al-naming.md`, `al-data-access.md`, `al-conventions.md`
when an `*.al` file is in context.

## Directory Structure

```
profile-al-development/
├── .claude-plugin/        # plugin.json, settings.json
├── CLAUDE.md              # Orchestration, routing, BCQuality gate
├── skills/                # Workflow + build + knowledge skills (each a SKILL.md)
├── agents/                # al-repo-summarizer (only remaining standalone agent)
├── commands/              # review-pr (ADO PR review)
├── rules/                 # Auto-loaded AL guardrails
├── hooks/                 # Turn-end auto-compile + citation verification
├── bcquality/             # microsoft / community / custom / _index
├── scripts/               # build-bcquality-index, verify-citations, revendor
├── .mcp.json  .lsp.json
└── README.md              # This file
```

## Contributing

```bash
cd ~/path/to/bc-claude-configs
git add profile-al-development/
git commit -m "Improve [aspect]"
git push
```

## Resources

- [AL Language Documentation](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-programming-in-al)
- [BC Best Practices](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-dev-best-practices)
</content>
