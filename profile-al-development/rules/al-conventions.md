---
description: AL field, page, and documentation conventions
globs: ["**/*.al"]
---

# AL Conventions

## DataClassification

Every table field requires an active decision on `DataClassification` — do not leave it as `ToBeClassified` or omit it.

If the table sets a default via `DataClassification` at object level, individual fields that match the default do not need to repeat it. Fields that differ from the default must explicitly override it.

Use `CustomerContent`, `EndUserIdentifiableInformation`, `SystemMetadata`, `CompanyConfidential`, `AccountData`, `OrganizationIdentifiableInformation`, or `PublicPersonalData` as appropriate. When in doubt, `CustomerContent` is the safe default for business data.

## ApplicationArea

Set a page-level default where all fields share the same area (almost always `ApplicationArea = All` on the page). Fields that match the page default do not need to repeat it. Only set `ApplicationArea` on individual fields or actions when they differ from the page default.

## Caption

`Caption` must be set on every field, action, and page — they are user-facing.

## Triggers

- No empty triggers. If a trigger has no code, remove it entirely.

## XML Documentation

- All public procedures need `/// <summary>` XML doc comments.
- Document every parameter, return value, and any non-obvious behavior.
