---
description: Look up official Microsoft Docs for BC/AL
allowed-tools: ["Task"]
---

# Microsoft Docs Lookup

Search and retrieve official Microsoft Learn documentation for BC/AL development.

## Usage

```
/docs-lookup "table extension syntax"
/docs-lookup "event subscriber pattern BC"
/docs-lookup "Customer table API reference"
/docs-lookup "BC v24 breaking changes"
```

## What It Does

Spawns the **docs-lookup** agent to:
1. Search Microsoft Learn/Docs for your query
2. Retrieve relevant articles and API references
3. Extract key information, syntax, and examples
4. Document findings in `.dev/docs-[topic].md`
5. Return concise summary with links

## Output

- `.dev/docs-[topic].md` - Official documentation summary with code examples and links

## When to Use

| Scenario | Example Query |
|----------|---------------|
| **AL syntax reference** | "AL table extension syntax" |
| **Base app API docs** | "Customer table API reference" |
| **Event documentation** | "OnBeforePost event parameters" |
| **Breaking changes** | "BC v24 breaking changes" |
| **Official patterns** | "BC event subscriber best practices" |
| **Setup guides** | "BC development environment setup" |
| **Feature documentation** | "BC approval workflow documentation" |
| **Property reference** | "AL DataClassification property" |

## Search Strategy Guide

### For AL Language Features

Use prefix "AL" for language-specific queries:

```
/docs-lookup "AL procedure parameters"
/docs-lookup "AL trigger syntax"
/docs-lookup "AL variable types"
/docs-lookup "AL error handling"
```

### For Base App Objects

Use "Business Central" + object name:

```
/docs-lookup "Business Central Customer table"
/docs-lookup "Business Central Sales-Post codeunit"
/docs-lookup "Business Central posting events"
```

### For API Reference

Use object name + "API reference":

```
/docs-lookup "Customer Ledger Entry API reference"
/docs-lookup "Sales Header API BC"
/docs-lookup "REST API Business Central"
```

### For Breaking Changes

Include version number:

```
/docs-lookup "BC v24 breaking changes"
/docs-lookup "Business Central 2024 Wave 1 changes"
/docs-lookup "AL language updates v24"
```

### For Patterns and Best Practices

Use "pattern" or "best practices":

```
/docs-lookup "BC extension development best practices"
/docs-lookup "AL event subscriber pattern"
/docs-lookup "table extension design pattern"
```

## Example Lookups

### Example 1: Syntax Reference

**Query:**
```
/docs-lookup "AL table extension field syntax"
```

**Output summary:**
```
Microsoft Docs lookup complete → .dev/docs-table-extension-syntax.md

Found: 3 articles
Key info: Field syntax requires DataClassification, supports triggers,
field IDs must be in extension range (50000+).

See file for full syntax and examples.
```

### Example 2: API Documentation

**Query:**
```
/docs-lookup "Customer table events BC"
```

**Output summary:**
```
Microsoft Docs lookup complete → .dev/docs-customer-events.md

Found: 2 articles
Key info: Customer table exposes OnBeforeInsert, OnAfterModify,
OnBeforeDelete events. Event subscribers use Database::Customer.

See file for event signatures and examples.
```

### Example 3: Breaking Changes

**Query:**
```
/docs-lookup "BC v23 breaking changes"
```

**Output summary:**
```
Microsoft Docs lookup complete → .dev/docs-breaking-changes-v23.md

Found: 1 article
Key info: 5 breaking changes including Customer.Post behavior change
and deprecated FlowField syntax. Migration guidance included.

See file for complete list and migration steps.
```

## Version-Specific Documentation

### Specifying BC Version

When documentation varies by version, include the version:

```
/docs-lookup "BC v23 event subscriber syntax"
/docs-lookup "Business Central 2023 Wave 2 API"
```

### Latest vs Specific Version

- **Latest:** Omit version for current documentation
- **Specific:** Include version number for version-specific info

```
/docs-lookup "AL syntax"                    # Latest
/docs-lookup "AL syntax BC v22"             # Specific version
```

## Response Types

### Syntax Documentation

Includes:
- Official syntax definition
- Property descriptions
- Required vs optional elements
- Code examples from Microsoft

### API Reference

Includes:
- Object type and ID
- Key fields/methods
- Events exposed
- Usage examples
- Related objects

### Breaking Changes

Includes:
- Change description
- Affected versions
- Migration guidance
- Code before/after examples

### Setup Guides

Includes:
- Prerequisites
- Step-by-step instructions
- Configuration options
- Troubleshooting tips

## Tips for Better Searches

### DO ✓

- **Use specific terms** - "AL table extension" not just "extension"
- **Include object names** - "Customer table" not just "table"
- **Mention version** - If version-specific info needed
- **Use official terminology** - "DataClassification" not "data class"

### DON'T ✗

- **Vague queries** - "How to do BC" (too broad)
- **Non-BC terms** - Use BC-specific terminology
- **Multiple topics** - One topic per lookup

## Handling No Results

If no official documentation found:
1. Agent tries alternative search terms
2. Searches broader topic
3. Notes what was searched
4. Provides general AL guidance based on knowledge

**Note:** Some advanced/niche topics may not have official docs. The agent will document this and provide best-effort guidance.

## Integration with Development Workflow

**During Design:**
```
/docs-lookup "event subscriber pattern"
→ Verify official approach before designing
```

**During Implementation:**
```
/docs-lookup "AL CalcFields syntax"
→ Get exact syntax for implementation
```

**Before Upgrade:**
```
/docs-lookup "BC v24 breaking changes"
→ Identify changes before upgrading
```

## Comparison with Other Commands

| Command | Use For |
|---------|---------|
| `/docs-lookup` | Official Microsoft documentation |
| `/bc-expert` | Expert advice, architecture, debugging |
| `/nav-baseapp` | Exploring base app objects and events |

**Rule of thumb:**
- Need official syntax? → `/docs-lookup`
- Need expert opinion? → `/bc-expert`
- Need to find base app objects? → `/nav-baseapp`

## Output File Format

The `.dev/docs-[topic].md` file contains:
- Summary of findings
- Key information extracted
- API reference (if applicable)
- Official code examples
- Version applicability
- Breaking changes (if any)
- Related documentation links
- Official URLs for reference

## Common Documentation Topics

### Object Types
- Tables, Table Extensions
- Pages, Page Extensions
- Codeunits, Reports
- Queries, XMLports
- Enums, Interfaces

### Language Features
- Procedures, Triggers
- Variables, Data Types
- Events (Integration, Business)
- Error Handling
- Attributes

### Patterns
- Extension patterns
- Event subscriber patterns
- Test codeunit patterns
- API patterns

### Configuration
- app.json properties
- launch.json settings
- ruleset.json configuration

---

**Remember:** This retrieves official Microsoft documentation. For expert opinions and patterns, use `/bc-expert`. For exploring base app, use `/nav-baseapp`.
