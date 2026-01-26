---
description: Consult BC specialists for expert advice
allowed-tools: ["Task"]
---

# BC Expert Consultation

Get expert advice from BC Code Intelligence specialists for complex BC/AL development questions.

## Usage

```
/bc-expert "How do I implement custom posting routines?"
/bc-expert "Best practice for extending Customer table with credit limits?"
/bc-expert "Why is my event subscriber not firing?"
```

## What It Does

Spawns the **bc-expert** agent to:
1. Route your question to the appropriate specialist(s)
2. Consult BC Code Intelligence MCP for expert advice
3. Search knowledge base for relevant patterns
4. Document findings in `.dev/expert-[topic].md`
5. Return concise summary with key recommendation

## Output

- `.dev/expert-[topic].md` - Full consultation results with recommendations, code examples, and pitfalls to avoid

## When to Use

| Scenario | Example Question |
|----------|------------------|
| **Architecture decisions** | "Should I use table extension or separate table?" |
| **Posting routines** | "How do I extend the sales posting routine?" |
| **Performance issues** | "Why is my query slow with large datasets?" |
| **Security concerns** | "How do I implement field-level security?" |
| **Debugging help** | "Why is my event subscriber not firing?" |
| **Best practices** | "What's the correct pattern for validation?" |
| **Code review guidance** | "Is this pattern following BC standards?" |
| **Integration patterns** | "How do I integrate with external APIs?" |

## Available Specialists

### Core Development Team

| Specialist | Emoji | Expertise | Use For |
|------------|-------|-----------|---------|
| **Dean Debug** | 🔍 | Debugging & troubleshooting | Runtime errors, why code doesn't work, tracing issues |
| **Sam Coder** | ⚡ | Expert coding & patterns | Writing new code, implementing features, AL syntax |
| **Roger Reviewer** | 👨‍⚖️ | Code quality & standards | Code review, naming conventions, quality assessment |
| **Alex Architect** | 🏗️ | Solution architecture | System design, extension strategy, base app integration |
| **Pat Performance** | 🚀 | Performance optimization | Query optimization, scalability, efficiency |

### Specialized Experts

| Specialist | Emoji | Expertise | Use For |
|------------|-------|-----------|---------|
| **Sam Security** | 🔒 | Security & permissions | Permission sets, data security, field-level security |
| **Terry Test** | 🧪 | Testing strategies | Test codeunit design, coverage, test patterns |
| **Isaac Integration** | 🔗 | Integration patterns | External APIs, web services, data exchange |
| **Uri UX** | 🎨 | User experience | Page layouts, usability, UI best practices |
| **Dana Docs** | 📚 | Documentation | API docs, feature docs, technical writing |

## Routing Guidelines

The agent automatically routes your question, but you can hint at the specialist:

### Architecture Questions → Alex Architect
```
/bc-expert "What's the best architecture for a multi-level approval workflow?"
/bc-expert "Should I create a separate module or extend existing functionality?"
```

### Debugging Questions → Dean Debug
```
/bc-expert "Why does my OnBeforePost event not fire?"
/bc-expert "Getting AL0132 error, what does it mean?"
/bc-expert "Record is locked but I didn't call LockTable"
```

### Performance Questions → Pat Performance
```
/bc-expert "How do I optimize customer ledger queries?"
/bc-expert "My report takes 30 seconds, how can I speed it up?"
/bc-expert "When should I use SetLoadFields?"
```

### Security Questions → Sam Security
```
/bc-expert "How do I restrict access to sensitive fields?"
/bc-expert "What permission set should I create for this feature?"
/bc-expert "How does field-level security work in BC?"
```

### Code Quality Questions → Roger Reviewer
```
/bc-expert "Does this code follow BC best practices?"
/bc-expert "What's the correct naming convention for events?"
/bc-expert "How should I structure this codeunit?"
```

## Example Consultations

### Example 1: Architecture Decision

**Question:**
```
/bc-expert "Should I use table extension or separate table for customer credit limits?"
```

**Agent routes to:** Alex Architect

**Output summary:**
```
BC expert consultation complete → .dev/expert-credit-limit-architecture.md

Specialist: Alex Architect
Key recommendation: Use table extension - maintains Customer relationship,
simpler queries, aligns with BC extension patterns.

See file for trade-off analysis and code examples.
```

### Example 2: Performance Issue

**Question:**
```
/bc-expert "Why is my Customer Ledger Entry query slow?"
```

**Agent routes to:** Pat Performance

**Output summary:**
```
BC expert consultation complete → .dev/expert-ledger-query-performance.md

Specialist: Pat Performance
Key recommendation: Use SetLoadFields + filter before loading + FindSet pattern.
Query was loading all 150 fields when only 5 needed.

See file for optimized code example.
```

### Example 3: Debugging Help

**Question:**
```
/bc-expert "My OnBeforeValidate event subscriber isn't being called"
```

**Agent routes to:** Dean Debug

**Output summary:**
```
BC expert consultation complete → .dev/expert-event-subscriber-debug.md

Specialist: Dean Debug
Key recommendation: Check event signature matches exactly, verify
SingleInstance property, and ensure codeunit is instantiated.

See file for troubleshooting checklist and common causes.
```

## Multi-Specialist Consultations

For complex questions spanning multiple domains, the agent may consult multiple specialists:

```
/bc-expert "Design a high-performance, secure credit limit validation system"
```

**Routes to:**
1. **Alex Architect** - Overall system design
2. **Pat Performance** - Query optimization strategy
3. **Sam Security** - Permission and data security

**Output:** Synthesized recommendations from all three specialists.

## Tips for Better Consultations

### DO ✓
- **Be specific** - "How do I validate credit limit on sales posting?" not "Help with validation"
- **Provide context** - "I'm extending the Customer table and need to..."
- **Ask one thing** - Multiple questions? Make multiple consultations
- **Include error messages** - If debugging, include the exact error

### DON'T ✗
- **Vague questions** - "How do I do BC development?" (too broad)
- **Multiple unrelated questions** - Split into separate consultations
- **Asking for complete implementations** - Use `/develop` for that

## Integration with Development Workflow

**During Planning:**
```
/bc-expert "Best architecture for credit limit feature?"
→ Use insights in solution plan
```

**During Implementation:**
```
/bc-expert "Why is my event not firing?"
→ Quick debugging help without leaving flow
```

**During Review:**
```
/bc-expert "Does this pattern follow BC standards?"
→ Validate approach before code review
```

## Comparison with Other Commands

| Command | Use For |
|---------|---------|
| `/bc-expert` | Expert advice, architecture, debugging |
| `/docs-lookup` | Official Microsoft documentation |
| `/nav-baseapp` | Exploring base app objects and events |

**Rule of thumb:**
- Need expert opinion? → `/bc-expert`
- Need official syntax/API? → `/docs-lookup`
- Need to find base app objects? → `/nav-baseapp`

## Output File Format

The `.dev/expert-[topic].md` file contains:
- Executive summary
- Key insights (numbered)
- Specific recommendations
- Code examples with explanations
- Pitfalls to avoid
- Related patterns
- Follow-up questions (if any)

---

**Remember:** BC experts provide guidance and patterns. For implementation, use `/develop`. For official docs, use `/docs-lookup`.
