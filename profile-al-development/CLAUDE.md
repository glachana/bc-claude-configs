# AL Development Profile - Full Lifecycle Workflow

**Version:** 2.12.0

## 🎯 Core Principles

### 1. Document-Driven Development
**All agents collaborate via markdown documents in `.dev/` directory.**

Main conversation stays clean - agents write detailed results to files, return one-line status updates.

### 2. Project Memory System (Performance Optimization)
**Project context prevents redundant exploration.**

- `.dev/project-context.md` documents project structure, patterns, and objects
- ALL agents read context FIRST before exploration (saves 5-15 min per workflow)
- Agents update context when they learn something new
- Initialize with `/init-context` (one-time 2-3 min setup)

### 3. Smart Workflow Routing
**Match complexity to workflow - avoid overkill for simple changes.**

- See `workflow-routing.md` for classification system
- TRIVIAL (2-5 min): Direct fix, skip all agents
- SIMPLE (5-15 min): Lightweight planning + implementation + review
- MEDIUM (20-40 min): Balanced planning + development, skip testing
- COMPLEX (45-90 min): Full pipeline with comprehensive planning

### 4. Proportional Planning
**Planning detail must match implementation complexity.**

- See `proportional-planning.md` for detailed guidelines
- SIMPLE: 100-150 lines total (no ASCII art, no alternatives analysis)
- MEDIUM: 200-400 lines total (balanced detail)
- COMPLEX: 400-800 lines total (comprehensive documentation)
- Prevents 946-line plans for 3-file changes

## 📁 Development Directory Structure

```
.dev/
├── project-context.md       # 🆕 Project memory (read first, saves 5-15 min!)
├── workflow-state.json      # 🆕 Current workflow state (for /status)
├── 01-requirements.md       # Requirements engineering output
├── 02-solution-plan.md      # Complete solution design + implementation plan
├── 03-code-review.md        # Code review findings
├── 04-diagnostics.md        # Compiler diagnostics + fixes
├── 05-test-plan.md          # Test strategy and plan
├── 06-test-review.md        # Test review results
└── session-log.md           # Cross-agent activity log
```

**🚀 Performance Tip:** Run `/init-context` once to create `project-context.md`. This documents your project structure so agents don't explore from scratch every time, reducing workflow runtime by 40-60%.

## 🔄 Development Lifecycle Pipeline

### Phase 1: Planning & Design
```
User Request
    ↓
1. requirements-engineer → 01-requirements.md
    ↓
2. solution-planner → 02-solution-plan.md (uses BC MCP + MS Docs + codebase exploration)
   - Architecture & design rationale
   - Implementation steps & code templates
   - All in one comprehensive document
```

### Phase 2: Development & Quality (Iterative)
```
3. al-developer → writes AL code (reads 02-solution-plan.md)
    ↓
4. code-reviewer → 03-code-review.md
    ├─ If Critical/High issues → ITERATE back to al-developer (step 3)
    └─ If only Medium/Low → Continue
    ↓
5. diagnostics-fixer → 04-diagnostics.md + auto-fixes safe issues
    ├─ If complex errors (3+ or logic issues) → ITERATE back to al-developer (step 3)
    └─ If minor/no errors → Continue to testing

Iteration continues until code quality is acceptable (no Critical/High issues, clean/minor compilation)
```

### Phase 3: Testing & Validation
```
6. test-engineer → 05-test-plan.md + writes test code
    ↓
7. test-reviewer → 06-test-review.md
    ↓
Done ✓
```

## 🛑 CRITICAL: Approval Gates in Workflows

**When running /dev-cycle or /plan commands, ALWAYS stop for user approval between major phases.**

### Mandatory Approval Points

1. **After Requirements** (01-requirements.md)
   - Read and summarize key findings (3-5 bullets)
   - Use AskUserQuestion: Approve / Refine / Stop
   - Only continue to solution plan if approved

2. **After Solution Plan** (02-solution-plan.md)
   - Read and summarize solution approach + implementation plan (3-5 bullets)
   - Use AskUserQuestion: Approve / Refine / Start Implementation / Stop
   - Only start development if approved

3. **After Code Review** (03-code-review.md)
   - Summarize review findings
   - Use AskUserQuestion: Approve / Fix Issues / Stop
   - Only continue to testing if approved

### Never Auto-Continue

❌ **WRONG:**
```
Spawning requirements-engineer...
Spawning bc-solution-designer...  ← NO! Wait for approval!
```

✅ **CORRECT:**
```
Requirements analysis complete → .dev/01-requirements.md

Key findings:
- 5 functional requirements
- 2 BC integration points
- Credit limit validation on sales posting

[Use AskUserQuestion with Approve/Refine/Stop options]

[Wait for user response before spawning solution-planner]
```

### Handling User Responses

- **Approve:** Continue to next phase
- **Refine:** Ask for feedback, re-run same agent with user input
- **Stop:** End workflow, summarize what's complete

### Why This Matters

- User needs to review and validate each phase
- Prevents wasted work if direction is wrong
- Enables iterative refinement
- Builds trust in the system

### Support Agents (On-Demand)
- **bc-expert** - BC specialist consultation (any phase)
- **docs-lookup** - Microsoft docs research (any phase)
- **dependency-navigator** - Base app exploration (any phase)

**Note:** The solution-planner agent uses these MCP tools internally, so you typically don't need to call support agents separately during planning.

## 🚀 Quick Start Commands

### Setup (Run Once)
```
/init-context                # Initialize project memory (2-3 min)
                             # Speeds up ALL future workflows by 40-60%
```

### Quick Bug Fix (Fastest ⚡)
```
/fix "Error: Email validation rejects john.doe@example.com"
```
Fast track: locate → fix → verify (2-5 min, no planning/testing)

### Full Development Cycle
```
/dev-cycle "Add customer credit limit validation"
```
Runs entire pipeline: requirements → design → implementation → code → review → diagnostics → tests

### Individual Phases
```
/plan "Feature description"              # Phases 1-2: Planning only
/develop                                  # Phase 2: Development + review
/test                                     # Phase 3: Testing
```

### Workflow Management
```
/status                      # Show current workflow state & progress
```

### On-Demand Agents
```
/bc-expert "How do I implement custom posting routines?"
/docs-lookup "Table extension best practices"
/nav-baseapp "Find all Customer validation events"
```

## 🛠️ Available MCP Tools

### BC Code Intelligence MCP
- Domain expertise and BC specialist consultation
- Base app patterns and best practices
- Architecture guidance
- **Tool prefix:** `mcp__bc-code-intelligence-mcp__*`

### Microsoft Docs MCP
- Official Microsoft Learn documentation
- API reference lookup
- AL language documentation
- **Tool prefix:** `mcp__microsoft_docs_mcp__*`

### AL Dependency MCP
- Navigate base app objects
- Explore extension dependencies
- Find object definitions and references
- **Tool prefix:** `mcp__al_dependency_mcp__*`

## ⚠️ CRITICAL RULE: MCP Tool Usage

**Main conversation must NEVER call MCP tools directly. Only agents use MCP tools.**

❌ **WRONG** (Main conversation):
```
Claude: [calls mcp__bc-code-intelligence-mcp__ask directly]
Result: 10KB of JSON floods context
```

✅ **CORRECT** (Agent delegation):
```
Claude: [spawns solution-planner agent]
Agent: [uses MCP tools: get_table_structure, ask_bc_expert, search_docs]
Agent: [writes findings to .dev/02-solution-plan.md]
Agent: [returns "Solution plan complete → .dev/02-solution-plan.md"]
Claude: "Solution designed. Details in .dev/02-solution-plan.md"
```

**Why?** MCP responses can be verbose (KB of JSON). Agents keep main conversation lean by writing details to files.

### Which Agent Uses Which MCP?

| Agent | MCP Tools Used | Purpose |
|-------|----------------|---------|
| `solution-planner` | ✅ All 3 MCPs | Uses AL Dependency, BC Expert, MS Docs during planning |
| `bc-expert` | ✅ BC Intelligence only | On-demand BC consultation (user command) |
| `docs-lookup` | ✅ MS Docs only | On-demand documentation lookup (user command) |
| `dependency-navigator` | ✅ AL Dependency only | On-demand base app exploration (user command) |
| Main conversation | ❌ None | Never uses MCP directly |

**Key principle:** `solution-planner` uses MCP tools automatically during planning. `bc-expert`, `docs-lookup`, and `dependency-navigator` are for user-invoked on-demand consultation via `/bc-expert`, `/docs-lookup`, `/nav-baseapp` commands.

## 🔨 AL Compilation Tool

**ALWAYS use `al-compile` instead of manual AL compiler commands.**

### Quick Usage
```bash
al-compile                    # Default: compile with all standard analyzers
al-compile --verbose          # Show detailed compilation info
al-compile --analyzers all    # Include ALL analyzers
al-compile --clean            # Clean .alpackages before compile
```

### What It Does Automatically
✅ **Auto-detects VS Code AL extension** and uses matching compiler version
✅ **Auto-detects workspace structure** (single vs multi-app)
✅ **Auto-finds all `.alpackages` directories** for transitive dependencies
✅ **Auto-applies ruleset files** (workspace or project level)
✅ **Auto-includes AppSourceCop** if `AppSourceCop.json` exists
✅ **Warns if AppSourceCop config missing** when explicitly enabled

### Default Analyzers
When you run `al-compile` without options, it includes:
- **CodeCop** - Code quality and best practices
- **UICop** - User interface rules
- **PerTenantExtensionCop** - Extension-specific rules
- **LinterCop** - Additional quality checks
- **AppSourceCop** - Only if `AppSourceCop.json` exists in project

### Options
```bash
--analyzers <mode>    # Analyzer mode:
                      #   default: Standard set (+ AppSourceCop if config exists)
                      #   all: All analyzers including AppSourceCop
                      #   none: No analyzers
                      #   list: Custom comma-separated (e.g., CodeCop,UICop)

--output <file>       # Error log location (default: .dev/compile-errors.log)
--clean               # Clean .alpackages before compiling
--no-parallel         # Disable parallel compilation
--verbose, -v         # Show detailed output
--help, -h           # Show help
```

### Why Use This Instead of Manual AL Commands?

**Manual compilation is complex:**
```bash
# What you'd need to do manually (15+ steps):
1. Find AL extension directory
2. Detect workspace structure
3. Find all .alpackages directories
4. Build semicolon-separated package paths
5. Find all analyzer DLLs
6. Build analyzer arguments
7. Find ruleset files
8. Use correct compiler version (match analyzers)
9. Enable external rulesets
10. Set parallel compilation
... (see diagnostics-fixer.md for full complexity)
```

**With al-compile:**
```bash
al-compile  # Done! All the above handled automatically
```

### Examples

**Basic compile:**
```bash
al-compile
```

**Verbose output to see what's happening:**
```bash
al-compile --verbose
```

**Include all analyzers (even without AppSourceCop.json):**
```bash
al-compile --analyzers all
```

**Custom analyzer selection:**
```bash
al-compile --analyzers "CodeCop,UICop,LinterCop"
```

**Clean and compile:**
```bash
al-compile --clean
```

### Integration with Agents

**diagnostics-fixer agent** automatically uses `al-compile` to:
1. Run compilation with all analyzers
2. Parse error log from `.dev/compile-errors.log`
3. Auto-fix safe issues
4. Recompile to verify fixes

**All agents should use `al-compile` for any compilation needs.**

### Troubleshooting

**If `al-compile` command not found:**
```bash
source ~/.bashrc  # Reload PATH in current terminal
# Or open a new terminal
```

**If analyzers show version warnings:**
- Extension compiler version: `~/.vscode/extensions/ms-dynamics-smb.al-*/bin/linux/alc`
- Analyzer DLLs: `~/.vscode/extensions/ms-dynamics-smb.al-*/bin/Analyzers/`
- Both should match - `al-compile` handles this automatically

## 🎯 Agent Design Principles

### 1. Single Responsibility
Each agent does ONE thing well:
- Requirements engineer extracts requirements
- Designer designs BC integration
- Developer writes code
- Reviewer reviews code

### 2. Read Previous Context
Each agent reads predecessor's output:
```markdown
# In solution-planner agent
1. Read .dev/01-requirements.md
2. Research BC patterns using MCP tools
3. Create comprehensive solution plan (design + implementation)
4. Write to .dev/02-solution-plan.md

# In al-developer agent
1. Read .dev/02-solution-plan.md
2. Implement code following the plan
3. Write AL source files
```

### 3. Minimal Chat Output
Agents return concise status:
```
Solution plan complete → .dev/02-solution-plan.md

Architecture summary:
- 2 table extensions
- 1 event subscriber
- 1 page extension

Implementation summary:
- 4 files to create
- 3 phases
- Ready for development
```

### 4. Update Session Log
Every agent appends to `.dev/session-log.md`:
```markdown
## [Timestamp] solution-planner
- Input: .dev/01-requirements.md
- Consulted BC Intelligence MCP for posting patterns
- Researched MS Docs for event subscribers
- Explored base app objects
- Designed solution with 2 extensions, 1 event
- Planned 4 files in 3 phases
- Output: .dev/02-solution-plan.md
```

### 5. Support Iteration
Agents can be re-invoked:
```
User: "The solution plan needs to use a separate validation codeunit"
Claude: [spawns solution-planner again, reads 01-requirements.md + user feedback]
Agent: [updates .dev/02-solution-plan.md with revised approach]
```

## 📋 Agent Capabilities Matrix

| Agent | Input | Output | MCP Tools Used |
|-------|-------|--------|----------------|
| requirements-engineer | User request | 01-requirements.md | None |
| solution-planner | 01-requirements.md | 02-solution-plan.md | BC Intel, MS Docs, AL Dep |
| al-developer | 02-solution-plan.md | AL code files | None |
| code-reviewer | Code files | 03-code-review.md | None |
| diagnostics-fixer | Compiler output | 04-diagnostics.md + fixes | None |
| test-engineer | 02+code | 05-test-plan.md + tests | None |
| test-reviewer | Test code | 06-test-review.md | None |
| bc-expert | Question | expert-*.md | BC Intel |
| docs-lookup | Question | docs-*.md | MS Docs |
| dependency-navigator | Query | nav-*.md | AL Dependency |

## 🔧 AL Coding Standards (Quick Reference)

### Object Naming
- **PascalCase** for all objects
- **Prefix** custom objects with company/app abbreviation
- **Table names**: Singular nouns (`Customer`, `SalesHeader`)
- **Page names**: Match table + type suffix (`CustomerCard`, `CustomerList`)
- **Codeunit names**: Descriptive of purpose

### Field Naming
- **PascalCase** for field names
- **Boolean fields**: Start with verbs (`IsBlocked`, `HasCustomer`)
- **Date fields**: End with `Date` (`PostingDate`, `ShipmentDate`)
- **Avoid abbreviations** unless industry standard

### Code Style
- **Explicit typing** - avoid `variant` when possible
- **Local procedures** over global when appropriate
- **Meaningful names** (`Customer` not `Cust`)
- **XML documentation** for public procedures
- **Group variables** logically (parameters, return values, locals)

### AL Best Practices
- **Table extensions** instead of modifying base tables
- **Error handling** with meaningful messages
- **Events (subscribers)** over modifying base code
- **Temporary tables** for processing
- **Validate user input** in pages/APIs
- **Single responsibility** for codeunits

### Performance
- **SetLoadFields** to optimize data loading
- **FindSet** for iteration (not `Find('-')`)
- **Filter before loading** records
- **Cautious with LOCKTABLE** in multi-user scenarios
- **Batch operations** for bulk data

## 📝 Standard Event Pattern

```al
[EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
local procedure OnBeforeInsertCustomer(var Rec: Record Customer)
begin
    // Custom logic here
end;
```

## 🔍 Error Handling Pattern

```al
if not SomeCondition then
    Error('Clear error message: %1', Value);
```

## 📂 Project Structure

- **Related functionality together** in subfolders
- **Separate folders** for tables, pages, codeunits, reports
- **File naming**: `ObjectType.ObjectName.al`

## 💡 Common Workflows

### Workflow 0: Quick Bug Fix (Fastest - 5 minutes)
```
1. /fix "Error message or bug description"
2. Review proposed fix
3. Approve → diagnostics run
4. Done! Commit the fix
```

**Best for:**
- Compiler errors
- Small logic bugs
- Validation errors
- Quick corrections

**Skips:** Planning, design, testing (just fix + verify)

### Workflow A: All-in-One (Fast)
```
1. /dev-cycle "Feature description"
2. Approve each phase when prompted (requirements → solution plan → dev → test)
3. Done! All artifacts in .dev/
```

### Workflow B: Plan First, Implement Later (Recommended)
```
Session 1 - Planning:
1. /plan "Feature description"
2. Approve requirements → solution plan
3. Review .dev/02-solution-plan.md carefully offline
4. Share plan with team if needed
5. Stop here

Session 2 - Implementation (same day or later):
6. /develop
   OR /dev-cycle "..." (will detect existing plan and ask to reuse)
7. Agent implements code based on approved plan
8. Review .dev/03-code-review.md
9. Done with development

Session 3 - Testing:
10. /test
11. Review .dev/06-test-review.md
12. Complete!
```

**Why Workflow B is better:**
- Planning can be reviewed at your pace
- No pressure during approval gates
- Can implement hours/days later
- Team can review plan before coding starts
- Separates thinking from doing

### Starting a New Feature (Detailed)
```
1. /dev-cycle "Feature description"
2. Review .dev/01-requirements.md - approve or refine
3. Review .dev/02-solution-plan.md - approve architecture & implementation plan
4. Agent implements code
5. Review .dev/03-code-review.md
6. Agent fixes diagnostics
7. Agent writes tests
8. Review .dev/06-test-review.md
9. Done!
```

### Debugging Existing Code
```
1. /diagnostics-fixer
2. Review .dev/04-diagnostics.md
3. Agent fixes issues
4. Recompile, verify
```

### Understanding Base App Integration
```
1. /nav-baseapp "Find Customer posting events"
2. Review .dev/nav-customer-events.md
3. /bc-expert "Best practice for extending Customer posting"
4. Review .dev/expert-posting-patterns.md
5. Implement with guidance
```

### Code Review Existing Changes
```
1. /code-reviewer
2. Review .dev/03-code-review.md
3. Address findings
4. /diagnostics-fixer
5. Verify improvements
```

## 🎓 When to Use Support Agents

### bc-expert
- Complex BC patterns (posting routines, integration patterns)
- Architecture decisions (how to extend base app)
- Performance optimization strategies
- Security concerns (permission sets, field security)

### docs-lookup
- Official Microsoft documentation needed
- API reference for base app objects
- AL language features and syntax
- Breaking changes in BC versions

### dependency-navigator
- Find base app objects and their structure
- Understand table relationships
- Locate events and extension points
- Explore existing extension patterns

## 📊 Session Log Format

`.dev/session-log.md` tracks all agent activity:

```markdown
# Development Session Log

**Started:** 2026-01-14 10:30:00
**Project:** Customer Credit Limit Feature

## [10:30:15] requirements-engineer
- Input: "Add customer credit limit validation"
- Extracted 5 functional requirements
- Identified 2 base app touchpoints
- Output: .dev/01-requirements.md
- Status: ✓ Complete

## [10:32:40] solution-planner
- Input: .dev/01-requirements.md
- Consulted BC MCP for Customer table extension patterns
- Researched MS Docs for validation patterns
- Explored base app objects
- Designed event subscriber approach with 2 extensions
- Planned step-by-step implementation (3 files, 4 phases)
- Output: .dev/02-solution-plan.md
- Status: ✓ Complete

[... continues ...]
```

## 🔄 Iteration & Refinement

Agents support iterative refinement:

```
User: "Actually, let's use a separate validation codeunit instead"

Claude: [spawns implementation-planner again]
Agent: [reads 01+02, applies new constraint, updates 03]
Agent: "Implementation plan revised → .dev/02-solution-plan.md"
```

All previous context preserved in documents - agents adapt to feedback.

## ✅ Success Criteria

A complete development cycle produces:
- ✓ Clear requirements document
- ✓ Comprehensive solution plan (architecture + implementation)
- ✓ Working AL code
- ✓ Code review with findings
- ✓ Clean compilation (no errors)
- ✓ Comprehensive tests
- ✓ Test review confirmation

**All documented in `.dev/` for future reference.**

---

*This profile enables full-lifecycle AL development with collaborative agents and document-driven workflow.*
