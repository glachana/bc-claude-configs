---
name: al-coding-standards
description: Use when reviewing or writing AL/BC code to enforce naming conventions (ABC suffix, quoted names) and 7 core best practices (SetLoadFields, error handling with FieldCaption, OnValidate, IntegrationEvent, dependency injection via Interface, ToolTip on table fields not pages, DataClassification at object level). Includes common code smells to flag in review.
---

# AL Coding Standards

This skill defines AL/BC coding conventions and best practices to enforce during code review and implementation.

---

## Naming Conventions

**Tables:**
```al
table 50100 CustomerExtensionABC  // ABC suffix, quoted name
```

**Fields:**
```al
field(50100; CreditLimitABC; Decimal)  // ABC suffix, quoted name
```

**Codeunits:**
```al
codeunit 50100 CreditValidationABC  // ABC suffix, quoted name
```

The `ABC` suffix is the project's prefix (replace with actual project prefix). All custom objects, fields, and procedures use the project prefix to avoid collisions with base app and other extensions.

---

## Core Best Practices

### 1. Use SetLoadFields for performance

```al
Customer.SetLoadFields(Name, "Credit Limit");
if Customer.Get(CustNo) then
```

**Why:** Reduces SQL columns transferred from database. Critical for performance on tables with many fields.

### 2. Proper error handling

```al
// Good
Error('Credit limit %1 exceeded', Customer.FieldCaption("Credit Limit"));

// Bad
Error('Credit limit exceeded');  // No context
```

**Why:** `FieldCaption` provides translated, contextual messages. Hardcoded strings break in multilingual environments.

### 3. Field validation in OnValidate

```al
field(50100; "ABC Credit Limit"; Decimal)
{
    trigger OnValidate()
    begin
        if "ABC Credit Limit" < 0 then
            Error('Credit limit cannot be negative');
    end;
}
```

**Why:** Validation at the field level prevents invalid data from being persisted, regardless of UI.

### 4. Events for extensibility

```al
[IntegrationEvent(false, false)]
local procedure OnBeforeValidateCreditLimit(var Customer: Record Customer; var IsHandled: Boolean)
begin
end;
```

**Why:** Allows other extensions to hook into validation logic without modifying source code.

### 5. Dependency injection for testability

```al
// Good - injectable
procedure ValidateCredit(var Customer: Record Customer; Validator: Interface "Credit Validator")

// Bad - hard dependency
procedure ValidateCredit(var Customer: Record Customer)
begin
    CreditValidatorCodeunit.Validate(Customer);  // Can't mock
end;
```

**Why:** Enables unit testing with mock implementations. Hard dependencies make code untestable in isolation.

### 6. ToolTip on table field, not page field

```al
// ✅ Good — ToolTip on table/table extension field, inherited by all pages
tableextension 50100 "Customer Ext" extends Customer
{
    fields
    {
        field(50100; "ABC Credit Limit"; Decimal)
        {
            ToolTip = 'Specifies the maximum credit amount for this customer.';
        }
    }
}
// Page field: no ToolTip needed — inherited automatically
field("ABC Credit Limit"; Rec."ABC Credit Limit") { ApplicationArea = All; }

// ❌ Bad — ToolTip only on page, not inherited by other pages
tableextension 50100 "Customer Ext" extends Customer
{
    fields { field(50100; "ABC Credit Limit"; Decimal) { } }  // no ToolTip!
}
field("ABC Credit Limit"; Rec."ABC Credit Limit")
{
    ApplicationArea = All;
    ToolTip = 'Specifies the maximum credit amount.';  // only this page benefits
}
```

**Why:** ToolTip on the table field is inherited by every page that displays it. Defining it only on a page creates inconsistency across the UI.

### 7. DataClassification at object level, not repeated per field

```al
// ✅ Good — set once at object level, all fields inherit it
tableextension 50100 "Customer Ext" extends Customer
{
    DataClassification = CustomerContent;  // applies to all fields

    fields
    {
        field(50100; "ABC Credit Limit"; Decimal) { }      // inherits CustomerContent
        field(50101; "ABC Credit Warning"; Boolean) { }    // inherits CustomerContent
        field(50102; "ABC Audit Note"; Text[250])
        {
            DataClassification = AccountData;              // override — justified
        }
    }
}

// ❌ Bad — DataClassification duplicated on every field
tableextension 50100 "Customer Ext" extends Customer
{
    DataClassification = CustomerContent;
    fields
    {
        field(50100; "ABC Credit Limit"; Decimal)
        {
            DataClassification = CustomerContent;  // duplicate — remove
        }
    }
}
```

**Why:** Object-level setting reduces duplication and prevents inconsistencies. Override per field only when classification truly differs.

---

## Common Code Smells to Flag in Review

- Missing `SetLoadFields` on record retrieval
- Magic numbers (use constants/enums)
- Empty `OnValidate` triggers (remove them)
- No error handling on critical operations
- Direct database access without permissions check
- Inefficient loops (N+1 queries)
- ToolTip defined on page field instead of table field (or duplicated on both)
- DataClassification repeated on fields when already set at object level

**When reviewers flag these, have developers fix them before presenting to user.**

---

## Language in Code

**ALL code artifacts MUST be written in English only**, regardless of the conversation language:

- Comments (inline and block)
- Label values and strings (`Label 'Customer not found'`)
- Variable, field, and procedure names
- Error and message text
- Documentation comments (`///`)
- Tooltip and Caption properties

The conversation may be in French, but source code is always English. This rule applies to all teammates and generated code.
