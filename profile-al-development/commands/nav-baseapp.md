---
description: Navigate BC base app to find objects and extension points
allowed-tools: ["Task"]
---

# Base App Navigation

Explore BC base app objects, find extension points, events, and understand dependencies.

## Usage

```
/nav-baseapp "Find all Customer validation events"
/nav-baseapp "Customer table structure"
/nav-baseapp "Sales-Post codeunit events"
/nav-baseapp "What objects reference Customer.Balance?"
```

## What It Does

Spawns the **dependency-navigator** agent to:
1. Use AL Dependency MCP to explore base app
2. Find object definitions, events, and relationships
3. Identify safe extension points
4. Document findings in `.dev/nav-[topic].md`
5. Return concise summary with key findings

## Output

- `.dev/nav-[topic].md` - Object definitions, events, relationships, and extension points

## When to Use

| Scenario | Example Query |
|----------|---------------|
| **Find extension points** | "Customer table events" |
| **Explore table structure** | "Customer table fields" |
| **Find posting events** | "Sales-Post codeunit events" |
| **Understand relationships** | "What tables reference Customer?" |
| **Find where field is used** | "Where is Customer.Balance used?" |
| **Discover events** | "Events for validating sales orders" |
| **Explore codeunits** | "Sales posting flow" |
| **API endpoint discovery** | "Customer API endpoints" |

## Supported Query Types

### Table Exploration

Get table structure, fields, and keys:

```
/nav-baseapp "Customer table structure"
/nav-baseapp "Customer table fields"
/nav-baseapp "Sales Header table keys"
```

**Returns:**
- Field list with types
- Primary/secondary keys
- FlowFields and their calculations
- Table relations

### Event Discovery

Find available events for subscription:

```
/nav-baseapp "Customer table events"
/nav-baseapp "Sales-Post codeunit events"
/nav-baseapp "OnBeforePost events in base app"
```

**Returns:**
- Event names and signatures
- Event publisher objects
- Parameters and types
- Usage examples

### Relationship Mapping

Understand how objects connect:

```
/nav-baseapp "What tables reference Customer?"
/nav-baseapp "Customer table dependencies"
/nav-baseapp "Sales posting data flow"
```

**Returns:**
- Tables with foreign keys
- Codeunits that use object
- Pages that display object
- Reports that query object

### Field Usage

Find where specific fields are used:

```
/nav-baseapp "Where is Customer.Balance used?"
/nav-baseapp "What uses SalesHeader.Status?"
/nav-baseapp "CreditLimit field references"
```

**Returns:**
- Codeunits referencing field
- Pages displaying field
- Triggers using field
- Calculations involving field

### Codeunit Exploration

Understand codeunit structure and events:

```
/nav-baseapp "Sales-Post codeunit structure"
/nav-baseapp "Cust-Check Cr. Limit codeunit"
/nav-baseapp "Posting routine flow"
```

**Returns:**
- Public procedures
- Events exposed
- Dependencies
- Typical usage patterns

## Example Explorations

### Example 1: Table Extension Points

**Query:**
```
/nav-baseapp "Customer table extension points"
```

**Output summary:**
```
Base app navigation complete → .dev/nav-customer-extension.md

Found: 1 table, 12 events, 4 related pages
Extension points: OnBeforeInsert, OnAfterModify, OnBeforeValidate(field)

See file for event signatures and extension patterns.
```

### Example 2: Event Discovery

**Query:**
```
/nav-baseapp "Sales posting events"
```

**Output summary:**
```
Base app navigation complete → .dev/nav-sales-posting-events.md

Found: 15 events in Sales-Post codeunit
Key events: OnBeforePostSalesDoc, OnAfterPostSalesDoc,
OnBeforePostCommit, OnAfterFinalizePosting

See file for all event signatures.
```

### Example 3: Relationship Mapping

**Query:**
```
/nav-baseapp "What objects use Customer table?"
```

**Output summary:**
```
Base app navigation complete → .dev/nav-customer-usage.md

Found: 47 tables, 89 codeunits, 34 pages reference Customer
Key relationships: Sales Header, Customer Ledger Entry, Contact

See file for complete relationship map.
```

## Query Patterns

### For Tables

```
/nav-baseapp "[Table] table structure"
/nav-baseapp "[Table] table events"
/nav-baseapp "[Table] table relationships"
/nav-baseapp "Fields in [Table]"
```

### For Codeunits

```
/nav-baseapp "[Codeunit] events"
/nav-baseapp "[Codeunit] procedures"
/nav-baseapp "[Codeunit] dependencies"
```

### For Events

```
/nav-baseapp "Events for [action]"
/nav-baseapp "OnBefore/OnAfter [action] events"
/nav-baseapp "[Object] integration events"
```

### For Relationships

```
/nav-baseapp "What references [Object]?"
/nav-baseapp "[Object] dependencies"
/nav-baseapp "Tables related to [Table]"
```

## Extension Point Categories

### Safe Extension Points ✓

| Type | Description | Example |
|------|-------------|---------|
| **Table Extension** | Add fields to existing tables | Extend Customer with CreditLimit |
| **Page Extension** | Add controls to existing pages | Add fields to Customer Card |
| **Event Subscriber** | Subscribe to table/codeunit events | OnBeforePost validation |
| **Interface Implementation** | Implement BC interfaces | IPaymentMethod |

### Risky/Unsupported ⚠️

| Type | Issue | Alternative |
|------|-------|-------------|
| **Base table modification** | Not possible in extensions | Use table extension |
| **Procedure override** | Not supported | Use events |
| **Field removal** | Not supported | Mark obsolete |
| **Change field type** | Breaking change | Create new field |

## Relationship Visualization

The agent documents relationships in ASCII diagrams:

```
Customer (18)
├── Related Tables
│   ├── Sales Header (36) - Sell-to Customer No.
│   ├── Customer Ledger Entry (21) - Customer No.
│   └── Contact (5050) - Contact Business Relation
├── Pages
│   ├── Customer Card (21)
│   └── Customer List (22)
└── Codeunits
    ├── Cust-Check Cr. Limit (312)
    └── Sales-Post (80) - validates customer
```

## Common Navigation Tasks

### Before Extending a Table

```
/nav-baseapp "Customer table structure"
```
→ See existing fields to avoid conflicts

```
/nav-baseapp "Customer table events"
```
→ Find available events for validation

### Before Extending Posting

```
/nav-baseapp "Sales-Post events"
```
→ Find correct event to subscribe to

```
/nav-baseapp "Sales posting flow"
```
→ Understand when events fire

### Before Extending a Page

```
/nav-baseapp "Customer Card page structure"
```
→ Find groups and controls for extension

## Tips for Better Navigation

### DO ✓

- **Be specific about object** - "Customer table" not just "customer"
- **Specify what you need** - "events" vs "structure" vs "relationships"
- **Use object names** - Official BC object names work best
- **Ask for extension points** - Explicitly request extension guidance

### DON'T ✗

- **Vague queries** - "How do I extend BC?" (too broad)
- **Multiple objects** - Focus on one object at a time
- **Implementation questions** - Use `/bc-expert` for how-to

## Integration with Development Workflow

**During Design:**
```
/nav-baseapp "Customer table events"
→ Identify events for solution design
```

**During Planning:**
```
/nav-baseapp "Sales posting flow"
→ Understand integration points
```

**During Implementation:**
```
/nav-baseapp "OnBeforePost event signature"
→ Get exact event signature for subscription
```

## Comparison with Other Commands

| Command | Use For |
|---------|---------|
| `/nav-baseapp` | Exploring base app objects and events |
| `/bc-expert` | Expert advice, architecture, debugging |
| `/docs-lookup` | Official Microsoft documentation |

**Rule of thumb:**
- Need to explore base app? → `/nav-baseapp`
- Need expert opinion? → `/bc-expert`
- Need official syntax? → `/docs-lookup`

## Output File Format

The `.dev/nav-[topic].md` file contains:
- Object overview (type, ID, purpose)
- Field list (for tables)
- Event list with signatures
- Relationship diagram
- Extension points identified
- Safe vs risky extension guidance
- Code examples for common patterns
- Related objects list

## Common Objects to Explore

### Core Business Objects
- Customer (Table 18)
- Vendor (Table 23)
- Item (Table 27)
- Sales Header/Line (Table 36/37)
- Purchase Header/Line (Table 38/39)

### Posting Codeunits
- Sales-Post (Codeunit 80)
- Purch.-Post (Codeunit 90)
- Gen. Jnl.-Post Line (Codeunit 12)

### Financial Objects
- G/L Entry (Table 17)
- Customer Ledger Entry (Table 21)
- Vendor Ledger Entry (Table 25)

### Setup Objects
- General Ledger Setup (Table 98)
- Sales & Receivables Setup (Table 311)

---

**Remember:** This explores base app structure. For expert patterns, use `/bc-expert`. For official docs, use `/docs-lookup`.
