# BCQuality — custom layer (Dynamics International)

Our own house rules, authored in BCQuality format. This is the `custom/` layer the
upstream BCQuality repo reserves for partner/customer overrides — empty upstream, ours
here.

**Precedence: `custom` > `community` > `microsoft`.** When a custom rule covers the same
concern as a Microsoft/community rule, ours wins. Agents cite custom rules by path just
like any other, so a finding backed by a DynInter rule reads
`references: [bcquality/custom/knowledge/<domain>/<slug>.md]` — visibly our house position.

## Authoring

Same contract as `READ` upstream: YAML frontmatter (`bc-version`, `domain`, `keywords`,
`technologies`, `countries`, `application-area`), a required `## Description`, optional
`## Best Practice` / `## Anti Pattern`, **no fenced code in the `.md`** — sample code goes
in sibling `<slug>.good.al` / `<slug>.bad.al` files.

The re-vendor script (`scripts/revendor-bcquality.ps1`) **never touches this folder** —
it only overwrites `microsoft/` and `community/`. Our rules are safe across re-vendors.
