# BCQuality (vendored)

Vendored subset of Microsoft's [BCQuality](https://github.com/microsoft/BCQuality)
knowledge corpus — the Microsoft-endorsed, machine-readable Business Central
quality rules that our reviewer agents **cite** when reporting findings.

This is a **read-only reference library**, not a second brain. The MCP specialists
(`bc-code-intelligence-mcp`) remain the *judge*; BCQuality is the *cited
jurisprudence*. Agents back findings with a `references[]` path into this folder
instead of paraphrasing rules from memory.

## What is vendored

- `microsoft/knowledge/` — the Microsoft-endorsed layer (7 domains: performance,
  privacy, security, style, testing, ui, upgrade). Authoritative, client-defensible.
- `community/knowledge/` — the community-contributed layer (performance, security).
  Real, useful rules with lower authority (not yet graduated to Microsoft-endorsed).
- `LICENSE` — upstream MIT license (attribution required).

Each rule is a `*.md` file plus optional `*.good.al` / `*.bad.al` sibling samples.

**Authority is encoded in the path.** A finding citing `bcquality/microsoft/...` is
Microsoft-endorsed; one citing `bcquality/community/...` is community-sourced — both
auditable, the layer visible in the citation.

The `skills/` layer and the `entry.md` dispatch contract are **not** vendored: our
agents read the knowledge files directly (short-circuit, like the EquerraNZ reference
integration) rather than running the full dispatch pipeline, which is meant for
anonymous orchestrators (AL-Go / CI).

`custom/` is **not** vendored from upstream (it is empty there). It is reserved for
our own DynInter rules, authored locally at `bcquality/custom/knowledge/<domain>/`.
The re-vendor script never touches `custom/` — those files are ours, not Microsoft's.

## Why vendored, not a git submodule

Installed Claude Code plugins copy their files into the plugin cache and **cannot
reference files outside the plugin directory**. A git submodule is a pointer, not a
file — an uninitialized submodule would deploy as an empty folder and break every
agent that cites it. Vendoring keeps the corpus as plain files, guaranteed present
via `${CLAUDE_PLUGIN_ROOT}/bcquality/...`.

## Provenance

- Source: https://github.com/microsoft/BCQuality
- Vendored commit: `822cae1b2771ac25f665f73369f69093bd4fd630`
- Vendored date (upstream commit date): 2026-06-04

## Re-vendoring (pull Microsoft updates)

Use the script at `scripts/revendor-bcquality.ps1`:

```powershell
# Drift check — is Microsoft ahead of our vendored copy? (modifies nothing)
./scripts/revendor-bcquality.ps1 -Check

# Re-vendor — overwrite microsoft/ + community/, refresh LICENSE, update the
# recorded commit/date below. Leaves the change in your working tree for review.
./scripts/revendor-bcquality.ps1
git diff --stat profile-al-development/bcquality   # review before committing
```

The script overwrites `microsoft/` and `community/` only. It **never touches
`custom/`** — those are our own DynInter rules. Never edit vendored files in place
(changes are lost on the next re-vendor); edit upstream or use the `custom/` layer.
