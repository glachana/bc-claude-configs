# BC Standard Patterns — MCP Query Formulation Guide

This is a **search guide**, not a static pattern library. It tells the `pattern-matcher` agent *how to query the al-mcp-server* to discover whether a given piece of custom AL code is reinventing something BC already provides natively.

---

## When to Consult This Guide

Consult this guide when you encounter custom code that:

- Manipulates records in loops where a simpler BC-native mechanism might exist
- Manages document state (numbering, dimensions, status, approvals) with hand-rolled logic
- Performs financial calculations (balances, outstanding amounts, prices) by iterating ledger entries
- Validates or blocks posting with conditions outside the standard event model

For each suspicion, locate the matching archetype below, run the prescribed MCP queries in order, and interpret the results as described.

---

## Archetypes

### 1. Header-Line Synchronisation

**Custom smell**
An `OnValidate` trigger on a header table field contains a `FindSet` / `Modify` loop that propagates the new field value down to all related line records manually.

**BC archetype**
Standard BC syncs header-to-line changes via dedicated procedures (e.g., `UpdateAllLineDim`, `SynchronizeBillToWithSellTo`) called directly from the header `OnValidate` trigger. These procedures encapsulate the loop and any cascading logic.

**MCP query sequence**

```
1. al_search_object_members("UpdateAllLine")
   → target: Sales Header, Purchase Header, or the relevant document header table
2. al_search_object_members("ModifyAll")
   → broader search for any header object calling ModifyAll on lines
3. microsoft_docs_search("sales header synchronize lines field AL")
```

**What to look for in results**
A header `OnValidate` trigger that calls a dedicated procedure which in turn iterates over lines. If the base app already has such a procedure for the field in question, the custom loop is redundant. Flag the custom code as a reinvention candidate.

---

### 2. Dimension Management

**Custom smell**
Custom code longer than approximately 20 lines that reads from or writes to `Dimension Value Entry` (or related dimension tables) directly, without delegating to a shared codeunit.

**BC archetype**
Codeunit 408 `DimensionManagement` handles all dimension operations: defaulting, validation, conflict resolution, and merging. All standard BC objects call this codeunit rather than manipulating dimension tables directly.

**MCP query sequence**

```
1. al_search_objects("Dimension Management")
   → confirm object ID 408 exists and review its interface
2. al_search_object_members("GetDefaultDimID")
   → find the procedure that resolves default dimension sets
3. al_search_object_members("OnAfterValidateDimension")
   → find integration event for post-validation extensibility
```

**What to look for in results**
Any custom procedure longer than 20 lines whose name contains "Dimension" and that does not call `DimensionManagement`. If `GetDefaultDimID` or equivalent procedures exist in the base app covering the same scenario, the custom code is a reinvention candidate.

---

### 3. No. Series Assignment

**Custom smell**
Custom code that generates document numbers using manual counter increments, string padding (e.g., `PadStr`, `Format` with leading zeros), or a custom "Last Used No." field maintained by the extension itself.

**BC archetype**
Codeunit 396 `NoSeriesMgt` (or the newer `No. Series` codeunit in recent versions) handles all number assignment. Tables that require auto-numbering call `GetNextNo` from their `OnInsert` trigger or from a dedicated procedure invoked before insert.

**MCP query sequence**

```
1. al_search_objects("No. Series")
   → locate the No. Series codeunit(s) and table
2. al_search_object_members("GetNextNo")
   → confirm the procedure signature for number retrieval
3. microsoft_docs_search("BC AL number series setup extension")
```

**What to look for in results**
Custom code building strings with padded zeros or maintaining a "Last Used No." field manually. If `GetNextNo` covers the same document type, the custom implementation is a reinvention candidate.

---

### 4. Posting Validation Guard

**Custom smell**
A large codeunit (10+ conditions) that validates prerequisites before posting and either modifies the posting codeunit directly or wraps it with its own logic — rather than subscribing to the standard posting events.

**BC archetype**
`Sales-Post` (codeunit 80) and `Purchase-Post` (codeunit 90) expose `OnBeforePostSalesDoc` and `OnBeforePostPurchaseDoc` integration events. Subscribers set `IsHandled := true` to short-circuit posting when a condition is not met.

**MCP query sequence**

```
1. al_search_object_members("OnBeforePostSalesDoc")
   → confirm event name, parameters, and IsHandled pattern
2. al_search_object_members("OnBeforePostPurchaseDoc")
   → same for purchase posting
3. microsoft_docs_search("AL event subscriber sales posting validation")
```

**What to look for in results**
The `IsHandled` parameter in the event signature — this is the correct BC mechanism to short-circuit posting without modifying the posting codeunit. If the custom code bypasses this pattern, it is a reinvention candidate and likely fragile across upgrades.

---

### 5. Approval Workflow Integration

**Custom smell**
A custom `Status` field on a document table combined with approval-check logic scattered across multiple triggers (`OnValidate`, `OnModify`, action triggers), without reference to BC's Approval Management infrastructure.

**BC archetype**
Codeunit 1535 `ApprovalsMgmt` and table 454 `Approval Entry` form the BC approval backbone. Procedures such as `CheckSalesApprovalPossible` and the `Workflow` framework provide structured approval routing without custom status fields.

**MCP query sequence**

```
1. al_search_objects("Approval Management")
   → confirm codeunit 1535 and its public interface
2. al_search_object_members("CheckSalesApprovalPossible")
   → find the guard procedure for sales document approval eligibility
3. al_search_objects("Workflow")
   → discover Workflow-related tables and codeunits available for extension
```

**What to look for in results**
A custom "Status" field with values like Pending / Approved / Rejected managed by hand-written trigger logic. If `ApprovalsMgmt` already covers the document type, the custom status field is a reinvention candidate.

---

### 6. Balance / Outstanding Amount Calculation

**Custom smell**
A custom `FindSet` loop over `Cust. Ledger Entry` or `Vendor Ledger Entry` that accumulates amounts to calculate a balance or outstanding total — instead of using BC's built-in FlowFields or helper codeunits.

**BC archetype**
The `Customer` table exposes `Balance` and `Balance (LCY)` as CalcFields (FlowFields). Codeunit `Customer Mgt.` provides helper procedures such as `GetAmountOnPostedInvoices` for more granular queries. The same pattern exists on the Vendor side.

**MCP query sequence**

```
1. al_get_object_definition(Table, "Customer")
   → inspect existing FlowFields: Balance, "Balance (LCY)", "Balance Due", etc.
2. al_search_objects("Customer Mgt.")
   → locate the helper codeunit and its procedure list
3. al_search_object_members("GetAmountOnPostedInvoices")
   → confirm procedure exists and review its signature
```

**What to look for in results**
Any `FindSet` loop over `Cust. Ledger Entry` that sums `Amount` or `"Remaining Amount"` fields. If a matching FlowField or `Customer Mgt.` procedure covers the same calculation, the custom loop is a reinvention candidate.

---

### 7. Price Calculation

**Custom smell**
Custom pricing or discount logic that hardcodes amounts, ignores the BC Price Calculation Setup, or builds its own price table — rather than going through BC's price calculation interface.

**BC archetype**
From BC v19 onward, the `PriceCalculation` interface and `Price List Line` table (7001) form the standard price calculation framework. Objects implement `PriceCalculation` and call `ApplyPrice` and `ApplyDiscount` rather than computing prices inline.

**MCP query sequence**

```
1. al_search_objects("Price Calculation")
   → locate the interface and its implementations
2. al_search_object_members("ApplyPrice")
   → confirm the procedure signature used by implementing codeunits
3. microsoft_docs_search("BC AL price calculation extension interface")
```

**What to look for in results**
Custom discount calculations that reference hardcoded percentage fields or custom price tables without going through `Price List Line`. If `ApplyPrice` / `ApplyDiscount` covers the scenario, the custom logic is a reinvention candidate.

---

## Generic Query Patterns

Use these when no archetype above matches the suspicious code.

**Find integration events in any codeunit**
```
al_search_object_members("[IntegrationEvent]")
```
Filter results to the target codeunit. Every `[IntegrationEvent]` is a sanctioned extension point — custom code duplicating behaviour that could subscribe to one of these is a reinvention candidate.

**Find whether a base procedure already exists**
```
al_search_object_members("<verb>")
```
Examples: `"Validate"`, `"Check"`, `"Calculate"`. If a matching procedure exists in the base app covering the same domain, the custom implementation is suspect.

**Find domain-related BC tables and codeunits**
```
al_search_objects("<domain keyword>")
```
Examples: `"Approval"`, `"Dimension"`, `"Price"`, `"No. Series"`. Use results to map the BC object landscape before concluding that a custom implementation has no standard equivalent.
