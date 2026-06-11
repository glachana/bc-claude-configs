---
bc-version: [all]
domain: style
keywords: [affix, prefix, naming, object-name, field-name, table-extension, collision, dyninter]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Apply the project affix as a prefix; never as a suffix

## Description

This is the Dynamics International house naming rule. The registered project affix
(shown here as `ABC` — replace with the actual project prefix) is always applied as a
**prefix**, at the front of the name. We never use suffixes. The affix exists to avoid
collisions with the base application and with other extensions, so it is required
wherever a custom identifier shares a namespace with code we do not own, and omitted
where it would be redundant. This rule overrides any general naming guidance in the
`microsoft/` layer (custom layer wins).

The scope is deliberate and not uniform across fields:

- **Custom objects** (specific objects and extension objects alike) are prefixed.
- **Fields in a table extension** are prefixed — they live inside a base-app table and
  must not collide.
- **Fields inside a fully custom table** are NOT prefixed — the table object already
  carries the affix and owns its own field namespace, so prefixing each field is
  redundant.

## Best Practice

Prefix every custom object: `"ABC Credit Validation"` (codeunit), `"ABC Loan Application"`
(table), `"ABC Customer Ext"` (table extension). Prefix the fields you add in a table
extension: `"ABC Credit Limit"`. Leave fields inside a fully custom table unprefixed:
`"Application No."`, `Amount`, `Status` inside `"ABC Loan Application"`. Use one affix per
project, consistently, always at the front.

## Anti Pattern

Using a suffix (`"Credit Limit ABC"`, `CustomerExtABC`) — we never suffix. Omitting the
prefix on a custom object or on a table-extension field (reintroduces the collision risk
the affix removes). Prefixing fields inside a fully custom table (`"ABC Application No."`
within `"ABC Loan Application"`) — unnecessary noise, since the owning object is already
affixed.
