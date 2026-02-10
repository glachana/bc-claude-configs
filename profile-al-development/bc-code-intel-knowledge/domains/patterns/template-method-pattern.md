---
title: "Template Method Pattern in AL"
domain: patterns
difficulty: intermediate
tags:
  - template-method
  - interface
  - architecture
  - extensibility
  - posting
related_topics:
  - facade-pattern
---

# Template Method Pattern in AL

## Intent

Define the **skeleton of an algorithm** in a template codeunit, delegating the specific steps to implementations via an interface. Standardizes how similar processes work without duplicating orchestration logic.

---

## Problem

When multiple developers independently solve similar problems (exports, postings, report printing), they produce inconsistent, hard-to-maintain solutions. Each reinvents the orchestration logic differently.

---

## Solution

Three components work together:

| Component | Role |
|-----------|------|
| **Interface** | Declares the steps the algorithm needs |
| **Template codeunit** | Orchestrates the flow — calls steps via the interface |
| **Implementation codeunit(s)** | Each implements the interface for one specific case |

> The template defines **only the flow**, not the details. Adding a new case = new implementation, no changes to the template.

---

## Structure

```al
// ============================================================
// INTERFACE — Declares the required steps
// File: IDataExport.Interface.al
// ============================================================
interface IDataExport
{
    procedure CheckData(): Boolean;
    procedure GetLinesToExport(): Boolean;
    procedure ExportLine();
    procedure NextLine(): Boolean;
    procedure Finish();
}

// ============================================================
// TEMPLATE — Orchestrates the algorithm flow
// File: DataExportTemplate.Codeunit.al
// ============================================================
codeunit 50000 DataExportTemplate
{
    /// <summary>
    /// Runs the full export process using the provided implementation.
    /// </summary>
    /// <param name="DataExport">The export implementation to use</param>
    procedure ExportData(DataExport: Interface IDataExport)
    begin
        if not DataExport.CheckData() then
            exit;

        if not DataExport.GetLinesToExport() then
            exit;

        repeat
            DataExport.ExportLine();
        until not DataExport.NextLine();

        DataExport.Finish();
    end;
}

// ============================================================
// IMPLEMENTATION A — Sales export
// File: SalesHeaderExport.Codeunit.al
// ============================================================
codeunit 50001 SalesHeaderExport implements IDataExport
{
    var
        SalesHeader: Record "Sales Header";

    procedure CheckData(): Boolean
    begin
        exit(SalesHeader.FindFirst());
    end;

    procedure GetLinesToExport(): Boolean
    begin
        exit(SalesHeader.FindSet(false));
    end;

    procedure ExportLine()
    begin
        // Export current SalesHeader record
    end;

    procedure NextLine(): Boolean
    begin
        exit(SalesHeader.Next() <> 0);
    end;

    procedure Finish()
    begin
        // Finalization logic
    end;
}

// ============================================================
// IMPLEMENTATION B — Customer export (different case, same template)
// File: CustomerExport.Codeunit.al
// ============================================================
codeunit 50002 CustomerExport implements IDataExport
{
    // Different implementation, same template orchestrates it
}
```

---

## Usage (Caller Side)

```al
procedure RunSalesExport()
var
    Template: Codeunit DataExportTemplate;
    SalesExport: Codeunit SalesHeaderExport;
begin
    Template.ExportData(SalesExport);
end;
```

---

## Benefits

| Benefit | Explanation |
|---------|-------------|
| **Consistency** | All export/posting processes follow the same flow |
| **Extensibility** | New case = new implementation, zero template changes |
| **Readability** | Template reads like pseudo-code describing the algorithm |
| **Testability** | Mock implementations are trivial to create |

---

## When to Use

**Good fit:**
- Document posting (sales, purchase, general ledger)
- Data export/import processes
- Report generation workflows
- Any repeatable multi-step process with varying data sources

**Not a good fit:**
- When the steps differ too much between cases (e.g., one case has both header + lines, another only header) — create two separate templates instead
- Simple one-off procedures

---

## References

- [Template Method Pattern — alguidelines.dev](https://alguidelines.dev/docs/patterns/template-method-pattern/)

---

**Last Updated**: 2026-02-10
**Status**: Active
