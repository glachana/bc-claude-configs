---
name: al-coding-standards
description: AL coding conventions and personal standards for Business Central development. Auto-load when writing, reviewing, or discussing AL code quality.
user-invocable: false
---

# AL Coding Standards

Consolidated reference for AL coding conventions. See [personal-coding-standards.md](./personal-coding-standards.md) for detailed examples.

## Naming Conventions

- **PascalCase for ALL identifiers**: objects, variables, fields, procedures, parameters, properties. No exceptions.
- **No spaces or special characters** in any identifier name.
- Object names do NOT include the AppSource affix -- the namespace provides uniqueness.
- Extension object names do NOT include the affix.

## Namespace Strategy

- Use the AppSource registered affix as the base namespace segment.
- Build a hierarchy: `namespace ABC.Sales;`, `namespace ABC.Sales.Documents;`
- The namespace replaces the need for affixes on object names.

## Affix Rules (AppSource Cop Alignment)

- **Custom tables**: Fields do NOT need affixes. The object lives in your namespace.
- **Table extensions**: Fields MUST have a **suffix** affix (never a prefix). Example: `"My Field ABC"` not `"ABC My Field"`.
- Extension object names do NOT include the affix.

## Data Access Patterns

- Always call `SetLoadFields` before `Get`, `FindFirst`, `FindLast`, `FindSet` operations. Only load the fields you need.
- Use `CalcFields` explicitly for FlowFields rather than relying on AutoCalcFields.

## Error Handling

- Use `FieldCaption` (not hardcoded field names) in error messages so they respect translations.
- Provide actionable error messages that tell the user what went wrong and how to fix it.

## Design Patterns

- **Dependency injection**: Use interfaces to decouple implementations for testability.
- **Events for extensibility**: Follow the IntegrationEvent pattern. Raise events at meaningful extension points with `[IntegrationEvent(false, false)]`.
- **No empty triggers**: If a trigger has no code, remove it entirely.

## Field and Page Properties

- `DataClassification` must be set on every table field. Use `CustomerContent`, `EndUserIdentifiableInformation`, `SystemMetadata`, etc. as appropriate. Never leave it as `ToBeClassified` in production code.
- `ApplicationArea = All` on all page fields and actions (unless you have a specific reason to restrict).

## Documentation

- Add XML documentation comments (`/// <summary>`) on all public procedures.
- Document parameters, return values, and any non-obvious behavior.

## Quick Checklist

When writing or reviewing AL code, verify:

1. All identifiers are PascalCase with no spaces
2. Namespace matches the affix-based hierarchy
3. Object names exclude the affix
4. Table extension fields have suffix affixes
5. SetLoadFields used before record retrieval
6. FieldCaption used in error messages
7. DataClassification set on all fields
8. ApplicationArea = All on fields/actions
9. No empty triggers
10. Public procedures have XML documentation
11. Interfaces used where testability matters
12. Integration events raised at extension points
