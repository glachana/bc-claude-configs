---
title: "Personal AL Coding Standards"
domain: coding-standards
difficulty: beginner
tags:
  - naming-conventions
  - namespaces
  - appsource-cop
  - code-quality
  - personal-standards
related_topics: []
---

# Personal AL Coding Standards

## CRITICAL: These standards MUST be followed in ALL code generation and reviews

These are personal coding standards that must be strictly enforced across all Business Central AL development.

## Naming Conventions

### **PascalCase Requirement**
- **ALL identifiers** must use PascalCase (leading capital letter)
- This includes:
  - Object names (tables, pages, codeunits, etc.)
  - Variable names
  - Field names
  - Control names
  - Procedure names
  - Parameter names

**Examples:**
```al
// ✅ CORRECT
table 50100 CustomerData
{
    field(1; CustomerName; Text[100]) { }
}

procedure CalculateTotalAmount(SalesAmount: Decimal): Decimal
var
    TaxRate: Decimal;
    TotalAmount: Decimal;
begin
    // ...
end;

// ❌ INCORRECT
table 50100 customer_data  // Wrong: not PascalCase
{
    field(1; customer_name; Text[100]) { }  // Wrong: not PascalCase
}

table 50100 "Customer Data"  // Wrong: contains spaces

procedure calculateTotalAmount(salesAmount: Decimal): Decimal  // Wrong: not PascalCase
var
    tax_rate: Decimal;  // Wrong: not PascalCase
begin
    // ...
end;
```

### **No Special Characters**
- Names must NOT contain special characters
- Allowed: Letters (A-Z, a-z), Numbers (0-9)
- NOT allowed: Underscores (_), hyphens (-), or any other special characters

**Examples:**
```al
// ✅ CORRECT
var
    CustomerNo: Code[20];
    TotalAmount: Decimal;
    IsProcessed: Boolean;

// ❌ INCORRECT
var
    Customer_No: Code[20];     // Wrong: contains underscore
    Total-Amount: Decimal;     // Wrong: contains hyphen
    Is_Processed: Boolean;     // Wrong: contains underscore
```

## Namespace Strategy

### **AppSource Affix as Base Namespace**
- Always use namespaces with your AppSource affix as the base namespace
- The namespace provides the prefix/suffix, so objects DON'T need it

**Example:**
```al
// If your AppSource affix is "ABC"

namespace ABC.Sales;

// ✅ CORRECT - Object names WITHOUT affix (namespace provides it)
table 50100 CustomerData
{
    // ...
}

page 50100 CustomerList
{
    // ...
}

codeunit 50100 SalesManagement
{
    // ...
}

// ❌ INCORRECT - Don't duplicate affix in object name
table 50100 ABCCustomerData  // Wrong: affix already in namespace
table 50100 "Customer Data"  // Wrong: contains spaces
{
    // ...
}
```

### **Namespace Hierarchy**
Organize namespaces hierarchically by functional area:

```al
namespace ABC.Sales;           // Sales-related objects
namespace ABC.Purchasing;      // Purchasing-related objects
namespace ABC.Finance;         // Finance-related objects
namespace ABC.Inventory;       // Inventory-related objects
namespace ABC.Integration;     // Integration-related objects
```

## AppSource Cop Alignment

### **Always Use SUFFIXES, Never Prefixes**
- Field names in extensions: Use suffixes on the RIGHT side
- Variable names (when needed): Use suffixes on the RIGHT side
- All affixes must be suffixes (not prefixes)

**IMPORTANT DISTINCTION:**
- **Custom tables (your own objects)**: Field names DON'T need affixes
- **Table extensions (extending dependencies)**: Field names MUST have suffix affixes

**Examples:**
```al
namespace ABC.Sales;

// ✅ CORRECT - Custom table (no affixes needed on fields)
table 50100 CustomerData
{
    fields
    {
        field(1; CustomerNo; Code[20]) { }  // No affix needed - your table
        field(2; CustomerName; Text[100]) { }  // No affix needed
        field(10; CreditLimit; Decimal) { }  // No affix needed
    }
}

codeunit 50100 SalesManagement
{
    procedure ProcessOrder(SalesHeader: Record "Sales Header")
    var
        TotalAmount: Decimal;  // No affix needed for local vars in your objects
        OrderNo: Code[20];
        CustomAmountABC: Decimal;  // ✅ Suffix only when disambiguation needed
    begin
        // ...
    end;
}
```

### **When Affixes Are Required**
According to AppSource cop, affixes are required when:
1. Extending standard objects (table extensions, page extensions)
2. Adding new fields to standard tables
3. New variables that might conflict with standard AL

**Extension Example:**
```al
namespace ABC.Sales;

// ✅ CORRECT - Extension name without affix (namespace provides it)
tableextension 50100 SalesHeader extends "Sales Header"
{
    fields
    {
        // ✅ CORRECT - Fields need suffix when extending standard tables
        field(50100; CustomFieldABC; Text[50]) { }
        field(50101; SpecialDiscountABC; Decimal) { }

        // ❌ INCORRECT
        field(50102; CustomField; Text[50]) { }  // Wrong: missing suffix in extension
        field(50103; ABCCustomField; Text[50]) { }  // Wrong: prefix instead of suffix
        field(50104; "Custom Field ABC"; Text[50]) { }  // Wrong: contains spaces
    }
}

// ✅ CORRECT - Extension name without affix
pageextension 50100 SalesOrder extends "Sales Order"
{
    layout
    {
        addafter(Amount)
        {
            // ✅ CORRECT - Control referencing field with suffix
            field(CustomFieldABC; Rec.CustomFieldABC) { }
        }
    }
}

// ❌ INCORRECT - Extension names
tableextension 50100 SalesHeaderABC extends "Sales Header"  // Wrong: affix in object name
pageextension 50100 SalesOrderABC extends "Sales Order"  // Wrong: affix in object name
```

## Label Naming Conventions

All user-facing strings must use `Label` variables — never hardcoded strings. Label variable names must end with a specific suffix indicating their usage context:

| Suffix | Usage | Function |
|--------|-------|----------|
| `Lbl` | Formatting, captions, general display | - |
| `Err` | Error messages | `Error()` |
| `Msg` | Informational messages | `Message()` |
| `Qst` | Confirmation questions | `Confirm()` |
| `Txt` | General text, StrSubstNo templates | - |

**Additional rules:**
- Always add `Comment = '...'` explaining placeholders if the label contains `%1`, `%2`, etc.
- Use `Locked = true` for technical/telemetry messages that must NOT be translated

**Examples:**
```al
// ✅ CORRECT
var
    CustomerNotFoundErr: Label 'Customer %1 does not exist.', Comment = '%1 = Customer No.';
    DocumentPostedMsg: Label 'Document %1 has been posted successfully.', Comment = '%1 = Document No.';
    ConfirmDeleteQst: Label 'Do you want to delete customer %1?', Comment = '%1 = Customer No.';
    InvoiceHeaderTxt: Label 'Invoice for %1', Comment = '%1 = Customer Name';
    TelemetryEventLbl: Label 'Customer validation failed', Locked = true;

// ❌ INCORRECT
var
    NotFoundLabel: Label 'Customer not found';         // Wrong: missing Err suffix, hardcoded
    ConfirmDelete: Label 'Do you want to delete?';     // Wrong: missing Qst suffix
    TelemetryMsg: Label 'Validation failed';           // Wrong: telemetry must use Locked = true
```

---

## CodeCop Compliance

The following CodeCop rules must be respected in all code generation and reviews:

| Rule | Description |
|------|-------------|
| AA0005 | Use explicit `Rec.` and `xRec.` — never implicit field access |
| AA0008 | Always use `begin/end` blocks — even for single-line statements |
| AA0062 | Remove empty triggers — don't leave empty `OnValidate`, `OnInsert`, etc. |
| AA0136 | Use `Label` variables for all UI strings — never hardcode strings |
| AA0137 | Always set `ApplicationArea` on page fields and actions |
| AA0139 | Always set `DataClassification` on table fields |
| AA0231 | Never use `WITH` statements |
| AA0004 | Always use parentheses on procedure calls — `MyProc()` not `MyProc` |

Run Code Analysis in VS Code before committing. Enable `CodeCop` in `ruleset.json` or workspace settings.

---

## Event Subscriber Parameter Naming

Event subscriber parameters must always use **descriptive names** — never generic names like `Rec`.

**Rules:**
- Use the record type name as the parameter name (e.g., `Customer`, `SalesHeader`)
- For `xRec` patterns, prefix with `x` (e.g., `xCustomer`, `xSalesHeader`)
- The procedure name follows the pattern: `<ObjectNameNoSpecialChars>_<EventName>`

**Examples:**
```al
// ✅ CORRECT — Descriptive parameter names
[EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeInsertEvent, '', false, false)]
local procedure SalesHeader_OnBeforeInsertEvent(var SalesHeader: Record "Sales Header"; RunTrigger: Boolean)
begin
end;

[EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeModifyEvent, '', false, false)]
local procedure Customer_OnBeforeModifyEvent(var Customer: Record Customer; var xCustomer: Record Customer; RunTrigger: Boolean)
begin
end;

// ❌ INCORRECT — Generic parameter names
[EventSubscriber(ObjectType::Table, Database::Customer, OnAfterInsertEvent, '', false, false)]
local procedure HandleCustomerInsert(var Rec: Record Customer)  // Wrong: use "Customer" not "Rec"
begin
end;
```

---

## Interface and Implementation Naming

Interfaces and their implementations follow a strict naming pattern:

- **Interfaces**: Prefix with `I` (e.g., `ICustomerService`, `IPostable`)
- **Implementation codeunits**: Suffix with `Impl` (e.g., `CustomerServiceImpl`, `SalesPostImpl`)
- Keep the base name consistent between interface and implementation
- Respect the 30-character object name limit

**File naming:**
- Interface: `ICustomerService.Interface.al`
- Implementation: `CustomerServiceImpl.Codeunit.al`

**Examples:**
```al
// ✅ CORRECT
// File: ICustomerService.Interface.al
interface ICustomerService
{
    procedure GetCustomerBalance(CustomerNo: Code[20]): Decimal;
    procedure ValidateCustomer(var Customer: Record Customer): Boolean;
}

// File: CustomerServiceImpl.Codeunit.al
codeunit 50100 CustomerServiceImpl implements ICustomerService
{
    procedure GetCustomerBalance(CustomerNo: Code[20]): Decimal
    begin
        // implementation
    end;

    procedure ValidateCustomer(var Customer: Record Customer): Boolean
    begin
        // implementation
    end;
}

// ❌ INCORRECT
interface CustomerService { }              // Wrong: missing I prefix
codeunit 50100 CustomerServiceImp { }      // Wrong: truncated Impl suffix
codeunit 50100 CustomerServiceABC { }      // Wrong: affix instead of Impl
```

---

## Readability Rules

### Guard Clauses — `if not X then exit`

Prefer **early exit** over wrapping logic in `if ... then begin ... end`. This reduces indentation and makes the happy path clearer.

```al
// ✅ CORRECT — Guard clause, flat structure
SalesLine.SetRange("Document No.", SalesHeader."No.");
if not SalesLine.FindSet(false) then
    exit;

repeat
    ProcessLine(SalesLine);
until SalesLine.Next() = 0;

// ❌ INCORRECT — Nested structure
if SalesLine.FindSet(false) then begin
    repeat
        ProcessLine(SalesLine);
    until SalesLine.Next() = 0;
end;
```

Apply this pattern for: `FindSet`, `FindFirst`, `Get`, `IsEmpty`, guard conditions at procedure start.

---

### Unnecessary `else`

Omit `else` when the `then` block ends with an **exit statement** (`exit`, `Error`, `break`, `quit`). The code after the `if` only runs if the condition is false — `else` is redundant.

```al
// ✅ CORRECT — No else needed
if not Customer.Get(CustomerNo) then
    Error(CustomerNotFoundErr, CustomerNo);

ProcessCustomer(Customer);  // Only reached if Customer.Get() succeeded

// ❌ INCORRECT — Unnecessary else
if not Customer.Get(CustomerNo) then
    Error(CustomerNotFoundErr, CustomerNo)
else
    ProcessCustomer(Customer);
```

---

### Unnecessary `true` / `false`

Never compare a Boolean expression to `true` or `false` explicitly.

```al
// ✅ CORRECT
if IsProcessed then ...
if not IsComplete then ...
if Customer.IsBlocked() then ...

// ❌ INCORRECT
if IsProcessed = true then ...
if IsComplete <> true then ...
if Customer.IsBlocked() = false then ...
```

---

## Performance Rules

### `DeleteAll` — Always Check `IsEmpty()` First

`DeleteAll()` on an empty table still acquires a **SQL table lock**. Always guard with `IsEmpty()`.

```al
// ✅ CORRECT
SalesLine.SetRange("Document No.", DocumentNo);
if not SalesLine.IsEmpty() then
    SalesLine.DeleteAll(true);

// ❌ INCORRECT — Locks the table even if nothing to delete
SalesLine.SetRange("Document No.", DocumentNo);
SalesLine.DeleteAll(true);
```

---

### `IsTemporary` Safeguard in Event Subscribers

Event subscribers fire for **both real and temporary table instances**. Always exit early on temporary records to prevent business logic from running against in-memory data.

```al
// ✅ CORRECT — Guard against temporary records
[EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterInsertEvent, '', false, false)]
local procedure SalesHeader_OnAfterInsertEvent(var Rec: Record "Sales Header"; RunTrigger: Boolean)
begin
    if Rec.IsTemporary() then
        exit;

    DoBusinessLogic(Rec);
end;

// ❌ INCORRECT — Runs on temporary records too
[EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterInsertEvent, '', false, false)]
local procedure SalesHeader_OnAfterInsertEvent(var Rec: Record "Sales Header"; RunTrigger: Boolean)
begin
    DoBusinessLogic(Rec);  // Will execute on TempSalesHeader too
end;
```

---

### Subscriber Codeunit Design

Four rules for subscriber codeunits:

**1. `SingleInstance = true`** — Each subscriber call loads a new instance. `SingleInstance` avoids repeated memory allocation.

```al
codeunit 50200 MyFeatureSubscribers
{
    SingleInstance = true;

    [EventSubscriber(...)]
    local procedure OnAfterPostSalesHeader(...)
    begin
    end;
}
```

**2. Small, feature-focused codeunits** — One subscriber codeunit per functional module. Delegate business logic to dedicated management codeunits.

```al
// ✅ CORRECT — Thin subscriber, delegates logic
[EventSubscriber(...)]
local procedure SalesHeader_OnAfterPostEvent(var Rec: Record "Sales Header")
begin
    if Rec.IsTemporary() then exit;
    Codeunit.Run(Codeunit::MyFeatureMgt, Rec);  // Logic lives elsewhere
end;

// ❌ INCORRECT — Business logic mixed into subscriber
[EventSubscriber(...)]
local procedure SalesHeader_OnAfterPostEvent(var Rec: Record "Sales Header")
begin
    // 50 lines of business logic here...
end;
```

**3. Use `BindSubscription` / `UnbindSubscription` for conditional subscribers** — If a subscriber only applies sometimes, bind/unbind it rather than checking conditions on every event fire.

**4. Avoid subscribing to `OnInsert`, `OnModify`, `OnDelete` table events** — These break batch SQL operations (`ModifyAll`, `DeleteAll` become row-by-row loops), causing severe performance degradation.

```al
// ❌ AVOID — Breaks ModifyAll/DeleteAll batch operations
[EventSubscriber(ObjectType::Table, Database::Customer, OnAfterModifyEvent, '', false, false)]
local procedure Customer_OnAfterModifyEvent(var Rec: Record Customer)
begin
end;

// ✅ PREFER — Subscribe to business-level events instead
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
local procedure SalesPost_OnAfterPostSalesDoc(...)
begin
end;
```

---

## Summary Checklist

When writing or reviewing AL code, ensure:

- [ ] All names use PascalCase (leading capital)
- [ ] No spaces in any identifier names
- [ ] No special characters (underscores, hyphens, etc.) in any identifier names
- [ ] Namespace declared with AppSource affix as base
- [ ] Object names do NOT include affix (namespace provides it)
- [ ] Extension object names do NOT include affix (namespace provides it)
- [ ] Fields in custom tables do NOT need affixes
- [ ] Fields in table extensions MUST have suffix affixes (not prefixes)
- [ ] Variables only need affixes when disambiguation is required (use suffixes)
- [ ] Code aligns with AppSource cop rules
- [ ] Label variables use correct suffix (Err/Msg/Qst/Txt/Lbl) with Comment for placeholders
- [ ] Telemetry/technical labels use `Locked = true`
- [ ] CodeCop rules AA0005/AA0008/AA0062/AA0136/AA0137/AA0139/AA0231/AA0004 respected
- [ ] Event subscriber parameters use descriptive names (not `Rec`)
- [ ] Interfaces prefixed with `I`, implementations suffixed with `Impl`
- [ ] Guard clauses used (`if not X then exit`) instead of nested `if X then begin`
- [ ] No unnecessary `else` after `exit`/`Error`/`break`
- [ ] No redundant `= true` / `<> true` on boolean expressions
- [ ] `IsEmpty()` checked before `DeleteAll()`
- [ ] `IsTemporary()` guard in all table event subscribers
- [ ] Subscriber codeunits use `SingleInstance = true`, are small, delegate logic
- [ ] No subscribers on `OnInsert`/`OnModify`/`OnDelete` table events

## Evolution

These standards may evolve over time. When new rules are added:
1. Update this document with the new rule
2. Add examples showing correct and incorrect usage
3. Ensure all specialists enforce the new rule going forward

---

**Last Updated**: 2026-02-10
**Status**: Active - Must be followed in all code generation and reviews
