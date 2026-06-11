---
description: AL naming conventions, namespaces, and affix rules
globs: ["**/*.al"]
---

# AL Naming Rules

## PascalCase Everywhere

PascalCase for ALL identifiers — objects, variables, fields, procedures, parameters, properties. No exceptions. No spaces or special characters in any identifier name.

## Namespaces

Always use a minimum two-level namespace. The registered AppSource affix forms the root, with at least one further segment beneath it — e.g. `namespace ABC.Sales;`, `namespace ABC.Core;`, `namespace ABC.Sales.Documents;`.

A two-level (or deeper) namespace provides organizational uniqueness. The registered affix is defined in `AppSourceCop.json`.

## Affix Rules (Dynamics International house convention)

**The affix is always a PREFIX, never a suffix.** This is the DynInter house rule; it overrides any suffix-based or namespace-only guidance. Authoritative source, with `.good.al` / `.bad.al` samples: `bcquality/custom/knowledge/style/affix-as-prefix-on-custom-identifiers.md`.

| Context | Object Name Affix | Field Name Affix |
|---|---|---|
| Custom table | **Prefix** | No |
| Table extension | **Prefix** | **Prefix** |
| Custom page / page extension | **Prefix** | N/A |
| Codeunit / Enum / Interface | **Prefix** | N/A |
| Enum extension | **Prefix** | **Prefix** |

- **Affix at the front.** `"ABC Loyalty Tier"` — correct. `"Loyalty Tier ABC"` (suffix) — wrong.
- Custom objects (specific and extension) carry the prefix. Fields **added in a table extension** carry the prefix (they live in a base-app table's namespace and must not collide). Fields **inside a fully custom table** do NOT carry it — the owning object already carries the affix.
