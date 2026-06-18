# AL Development Agents

> **Architecture note (v5.x):** the multi-agent roster that used to live here was migrated.
> The development specialists (developer, reviewers, test engineers, architect, docs writer)
> are now **persona prompt files inside the skills**, spawned by the lead session — not
> standalone agent files. See:
> - `skills/plan/solution-architect-prompt.md`
> - `skills/develop/al-developer-prompt.md`, `skills/develop/reviewer-prompts.md`
> - `skills/test/test-engineer-prompts.md`
> - `skills/document/docs-writer-prompt.md`
>
> The full workflow (routing, phases, gates) is documented in the plugin `CLAUDE.md`
> and the `workflow-routing` skill.

## Remaining standalone agent

| Agent | Purpose |
|-------|---------|
| `al-repo-summarizer.md` | Read-only overview of an AL repository — structure, objects, relationships — for onboarding without reading every file. |

## Why the change

The plugin evolved from a fixed 11-agent sequence (v2) → "lead-as-manager" specialist teams
(v3.0) → skills with inline persona prompts (v5.x). Embedding personas in skills lets the
lead spawn N parallel instances (e.g. 4 reviewers, 4 test engineers) and keeps each
persona's BCQuality citation contract next to the workflow that uses it.
