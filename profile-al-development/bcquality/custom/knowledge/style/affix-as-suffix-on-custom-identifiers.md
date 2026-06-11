---
bc-version: [all]
domain: style
keywords: [affix, suffix, prefix, naming, object-name, field-name, collision, dyninter]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Apply the project affix as a suffix on every custom identifier

## Description

This is the Dynamics International house naming rule. Every custom object, field, and
procedure carries the registered project affix (shown here as `ABC` — replace with the
actual project prefix) appended as a **suffix**, never prepended as a prefix. The affix
exists to avoid collisions with the base application and with other extensions, and a
consistent suffix keeps the descriptive part of the name first, so members group and read
by what they do rather than by which app shipped them. This rule overrides any general
naming guidance in the `microsoft/` layer (custom layer wins).

## Best Practice

Append the project affix to the descriptive name: a credit-limit field becomes
`CreditLimitABC`, a customer table extension `CustomerExtABC`, a validation procedure
`ValidateCreditABC`. Apply the affix to table-extension fields too — those are the most
collision-prone. Use one affix per project, consistently, on objects, fields, and
public procedures alike.

## Anti Pattern

Prepending the affix as a prefix (`ABCCreditLimit`), omitting it on table-extension
fields (`CreditWarning` with no affix), or mixing affix styles within one project. Each
reintroduces the collision risk the affix is meant to remove and breaks alphabetical
grouping of custom members.
