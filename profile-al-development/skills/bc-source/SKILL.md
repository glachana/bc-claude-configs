---
name: bc-source
description: Look up Business Central base application source code (tables, pages, codeunits, events) from MSDyn365BC.Sandbox.Code.History. Use this to verify object structures, find event publishers, or check field definitions.
---

# /bc-source — BC Base App Source Lookup

Reference repository for BC base application AL source code across all versions.
Use this when you need to verify table structures, find event publishers, check page layouts,
or understand how standard BC objects work.

## Setup (one-time per session)

Clone the correct branch for the customer's BC version. Check `app.json` for the runtime version.

```bash
# Clone to /tmp/bc-source (shallow, fast)
git clone -b w1-27 --single-branch --depth 1 \
  https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History.git \
  /tmp/bc-source 2>/dev/null || echo "Already cloned"
```

For country-specific localizations, use the country code:
```bash
git clone -b us-27 --single-branch --depth 1 ...
```

Branch naming: `{country}-{major}` where country is `w1` (worldwide), `us`, `de`, `fr`, etc.

## Finding objects

The base app source is in `BaseApp/Source/Base Application/`.

### Find a table by name or ID

```bash
grep -rl "table [0-9]* \"Purchase Header\"" /tmp/bc-source/BaseApp/Source/ | head -5
# or by ID
grep -rl "table 38 " /tmp/bc-source/BaseApp/Source/ | head -5
```

### Find a page

```bash
grep -rl "page [0-9]* \"Purchase Order\"" /tmp/bc-source/BaseApp/Source/ | head -5
```

### Find a codeunit

```bash
grep -rl "codeunit [0-9]* \"Approvals Mgmt.\"" /tmp/bc-source/BaseApp/Source/ | head -5
```

### Find event publishers

```bash
# Find all integration events in a specific codeunit
grep -n "IntegrationEvent" /tmp/bc-source/BaseApp/Source/**/ApprovalsMgmt.Codeunit.al
```

### Find all fields on a table

```bash
# Read the table file to see all fields
cat /tmp/bc-source/BaseApp/Source/**/PurchaseHeader.Table.al | head -200
```

### Search for any pattern across base app

```bash
grep -rn "OnAfterCheck.*ApprovalPossible" /tmp/bc-source/BaseApp/Source/
```

## Common use cases

1. **Verify a field exists on a table** before writing a table extension
2. **Find the right event** to subscribe to (search for `IntegrationEvent` in relevant codeunits)
3. **Check field types and properties** (DataClassification, OptionMembers, etc.)
4. **Understand data flow** by reading codeunit procedures
5. **Find page controls** to determine where to add extension fields

## Structure reference

```
/tmp/bc-source/
├── BaseApp/Source/Base Application/   ← Main app (tables, pages, codeunits)
├── System Application/Source/         ← System utilities
├── BusinessFoundation/Source/         ← Foundation types
└── ...other modules
```

Within BaseApp, files follow the pattern:
- `{ObjectName}.Table.al`
- `{ObjectName}.Page.al`
- `{ObjectName}.Codeunit.al`
- `{ObjectName}.Report.al`
- `{ObjectName}.Enum.al`
