# Personal AL Coding Standards -- Detailed Examples

## PascalCase Naming

PascalCase applies to every identifier in AL. No exceptions, no abbreviation shortcuts.

### Correct

```al
codeunit 50100 SalesOrderProcessor
{
    var
        SalesHeader: Record SalesHeader;
        IsProcessed: Boolean;
        TotalAmount: Decimal;

    procedure ProcessSalesOrder(SalesOrderNo: Code[20]): Boolean
    begin
        // ...
    end;

    local procedure CalculateLineDiscount(SalesLine: Record SalesLine; DiscountPercent: Decimal): Decimal
    begin
        // ...
    end;
}
```

### Incorrect

```al
codeunit 50100 sales_order_processor  // Wrong: snake_case
{
    var
        salesHeader: Record SalesHeader;  // Wrong: camelCase
        is_processed: Boolean;            // Wrong: snake_case
        totalAmt: Decimal;               // Wrong: camelCase and abbreviation

    procedure processSalesOrder(sales_order_no: Code[20]): Boolean  // Wrong: camelCase, snake_case param
    begin
        // ...
    end;
}
```

## Namespace Hierarchy

The AppSource registered affix forms the root namespace. Build a logical hierarchy beneath it.

### Correct

```al
// Base namespace for the app
namespace ABC.Core;

// Feature-specific namespaces
namespace ABC.Sales;
namespace ABC.Sales.Documents;
namespace ABC.Sales.Pricing;
namespace ABC.Inventory;
namespace ABC.Inventory.Tracking;
```

```al
namespace ABC.Sales;

table 50100 SpecialPriceHeader  // No affix in the object name
{
    Caption = 'Special Price Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])  // No affix needed on custom table fields
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; CustomerNo; Code[20])  // No affix needed on custom table fields
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
    }
}
```

### Incorrect

```al
namespace Sales;  // Wrong: missing affix root segment

table 50100 ABCSpecialPriceHeader  // Wrong: affix in object name (namespace provides it)
{
    fields
    {
        field(1; "No."; Code[20])
        {
            // Wrong: missing DataClassification
        }
        field(2; "ABC Description"; Text[100])  // Wrong: affix on custom table field
        {
            DataClassification = CustomerContent;
        }
    }
}
```

## AppSource Cop Alignment -- Suffix Affixes Only

When extending base application or third-party tables, your fields must have a **suffix** affix. This is a hard AppSource requirement. Never use prefix affixes.

### Correct -- Table Extension Fields with Suffix

```al
namespace ABC.Sales;

tableextension 50100 CustomerExtension extends Customer  // No affix in extension object name
{
    fields
    {
        field(50100; "Loyalty Tier ABC"; Enum LoyaltyTier)  // Suffix affix
        {
            Caption = 'Loyalty Tier ABC';
            DataClassification = CustomerContent;
        }
        field(50101; "Last Review Date ABC"; Date)  // Suffix affix
        {
            Caption = 'Last Review Date ABC';
            DataClassification = CustomerContent;
        }
        field(50102; "Credit Score ABC"; Integer)  // Suffix affix
        {
            Caption = 'Credit Score ABC';
            DataClassification = CustomerContent;
        }
    }
}
```

### Incorrect -- Prefix Affixes and Missing Affixes

```al
namespace ABC.Sales;

tableextension 50100 ABCCustomerExtension extends Customer  // Wrong: affix in extension name
{
    fields
    {
        field(50100; "ABC Loyalty Tier"; Enum LoyaltyTier)  // Wrong: PREFIX affix
        {
            Caption = 'ABC Loyalty Tier';
            DataClassification = CustomerContent;
        }
        field(50101; "Last Review Date"; Date)  // Wrong: NO affix on table extension field
        {
            Caption = 'Last Review Date';
            DataClassification = CustomerContent;
        }
    }
}
```

## Custom Tables vs Table Extensions -- Summary

| Context | Object Name Affix | Field Name Affix |
|---|---|---|
| Custom table | No | No |
| Table extension | No | Yes, suffix only |
| Custom page | No | N/A |
| Page extension | No | N/A |
| Codeunit | No | N/A |
| Enum | No | N/A |
| Enum extension | No | Yes, suffix only |

## SetLoadFields Before Record Retrieval

### Correct

```al
procedure GetCustomerName(CustomerNo: Code[20]): Text[100]
var
    Customer: Record Customer;
begin
    Customer.SetLoadFields(Name);
    if Customer.Get(CustomerNo) then
        exit(Customer.Name);
end;

procedure FindOpenSalesOrders(CustomerNo: Code[20])
var
    SalesHeader: Record "Sales Header";
begin
    SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
    SalesHeader.SetRange(Status, SalesHeader.Status::Open);
    SalesHeader.SetLoadFields("No.", "Sell-to Customer Name", "Order Date", Amount);
    if SalesHeader.FindSet() then
        repeat
            ProcessOrder(SalesHeader);
        until SalesHeader.Next() = 0;
end;
```

### Incorrect

```al
procedure GetCustomerName(CustomerNo: Code[20]): Text[100]
var
    Customer: Record Customer;
begin
    // Wrong: no SetLoadFields -- loads entire record just to read Name
    if Customer.Get(CustomerNo) then
        exit(Customer.Name);
end;
```

## Error Handling with FieldCaption

### Correct

```al
procedure ValidateQuantity(SalesLine: Record "Sales Line")
begin
    if SalesLine.Quantity <= 0 then
        Error(QuantityMustBePositiveErr, SalesLine.FieldCaption(Quantity));
end;

var
    QuantityMustBePositiveErr: Label '%1 must be a positive value.', Comment = '%1 = field caption';
```

### Incorrect

```al
procedure ValidateQuantity(SalesLine: Record "Sales Line")
begin
    if SalesLine.Quantity <= 0 then
        Error('Quantity must be a positive value.');  // Wrong: hardcoded field name
end;
```

## Integration Events

### Correct

```al
codeunit 50100 SalesOrderProcessor
{
    /// <summary>
    /// Processes a sales order and raises events for extensibility.
    /// </summary>
    /// <param name="SalesHeader">The sales order to process.</param>
    procedure ProcessSalesOrder(SalesHeader: Record "Sales Header")
    begin
        OnBeforeProcessSalesOrder(SalesHeader);

        DoProcessSalesOrder(SalesHeader);

        OnAfterProcessSalesOrder(SalesHeader);
    end;

    local procedure DoProcessSalesOrder(SalesHeader: Record "Sales Header")
    begin
        // Core processing logic
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessSalesOrder(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessSalesOrder(var SalesHeader: Record "Sales Header")
    begin
    end;
}
```
