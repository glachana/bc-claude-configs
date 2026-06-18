---
name: bc-source
description: Look up Business Central base application source code (tables, pages, codeunits, events) via the bc-source-mcp server. Use this to verify object structures, find event publishers, or check field/procedure definitions across BC versions and localizations.
---

# /bc-source — BC Base App Source Lookup

Authoritative, structured access to BC base application AL source — all versions (v23→v29),
all localizations (W1 + 47 countries) — through the **`bc-source-mcp`** MCP server. Use it to
verify object structures, find the exact event to subscribe to, or check a procedure
signature **instead of relying on training-data memory** (a major source of AL hallucinations).

> The old workflow (manual `git clone` of MSDyn365BC.Sandbox.Code.History + `grep`) is gone.
> The MCP does a partial clone + SQLite index once, then answers lookups in <100 ms.

## Pick the right branch

Branches are named `{country}-{major}`, e.g. `w1-28` (worldwide) or `fr-28` (France). Read the
customer's `app.json` runtime / target to choose the major version; use the country branch when
verifying localized objects, otherwise `w1`.

- `bc_list_versions` — available BC versions (with/without vNext)
- `bc_list_localizations` — 47 country codes + W1
- `bc_list_branches` — all upstream branches
- `bc_cache_status` — which branches are already indexed locally (fast); `bc_refresh` to add/update one

## Core lookups

| Need | Tool | Notes |
|------|------|-------|
| Full source + metadata of an object | `bc_get_object` | by type + name/ID on a branch |
| All fields on a table | `bc_get_object` | returns the full table AL |
| Event publishers of an object | `bc_get_event_publishers` | `IntegrationEvent`, `BusinessEvent`, `InternalEvent` |
| A specific procedure (signature + body) | `bc_get_procedure` | targeted, avoids pulling the whole object |
| Full-text / pattern search | `bc_search_code` | ripgrep-backed, scope by app/type |
| List objects (filtered) | `bc_list_objects` | by type / app / name pattern, paginated |
| Is an object present across versions? | `bc_find_object_across_branches` | compare presence/changes |
| Apps in a branch | `bc_list_apps` | top-level apps |

## Common use cases → tool

1. **Verify a field exists before extending a table** → `bc_get_object` (table) on the target branch.
2. **Find the right event to subscribe to** → `bc_get_event_publishers` on the relevant codeunit
   (e.g. `Approvals Mgmt.`), or `bc_search_code "IntegrationEvent"` scoped to an app.
3. **Check a procedure's exact signature** → `bc_get_procedure`.
4. **Compare an object W1 vs a localization** (e.g. `Customer` FR vs W1) → `bc_get_object` on each branch.
5. **Find all usages of a pattern** across the Base Application → `bc_search_code`.

## Admin

- `bc_refresh` — re-fetch + re-index one branch (or all). Run after a Microsoft cumulative update.
- `bc_cache_status` — disk usage + indexed branches.
- `bc_prune_cache` — drop worktrees you no longer need.

## Notes

- This is read-only reference. Spawned personas call these tools; the main conversation does not
  edit code based on them directly.
- If a needed branch isn't indexed yet, `bc_get_object`/`bc_search_code` will surface it — index it
  with `bc_refresh` (first index of a branch downloads + builds, subsequent lookups are instant).
