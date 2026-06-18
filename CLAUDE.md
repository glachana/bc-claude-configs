# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a configuration repository for Claude Code plugins. It contains reusable plugin profiles that can be synced across multiple projects and computers via GitHub. The repository does not contain application code - it contains plugin configurations, custom commands, specialized agents, and MCP server configurations.

## Architecture

### Plugin System

This repository uses Claude Code's plugin architecture where:

1. **Plugin profiles** are self-contained directories with a `.claude-plugin/plugin.json` file
2. **Plugins are registered** in project `.claude/settings.json` files via `extraKnownMarketplaces` and `enabledPlugins`
3. **Multiple plugins can be composed** together in a single project
4. **Configuration is additive** - all plugins load together with project-specific settings

### Repository Structure

```
claude-configs/
├── profile-al-development/          # AL/Business Central development profile
│   ├── .claude-plugin/
│   │   ├── plugin.json              # Plugin metadata (name, version, author)
│   │   └── settings.json            # Plugin-specific settings
│   ├── CLAUDE.md                    # AL orchestration, routing, BCQuality gate
│   ├── skills/                      # Workflows + knowledge (invoked with /, or auto-loaded)
│   │   ├── plan/                    # Competitive solution design (architect prompts)
│   │   ├── develop/                 # Parallel impl + 4-specialist review prompts
│   │   ├── test/                    # Parallel test engineers prompts
│   │   ├── fix/                     # Lightweight fix workflow
│   │   ├── interview/               # Deep requirements gathering
│   │   ├── document/                # Technical documentation generation
│   │   ├── compile/ publish/ run-tests/ translate/   # Build/CLI skills
│   │   ├── workflow-routing/ proportional-planning/  # Routing plumbing (auto-loaded)
│   │   ├── bcquality-citation/ bc-expert-consultation/  # Citation + expert gates
│   │   └── ...                      # See `Available Skills` in plugin CLAUDE.md
│   ├── agents/                      # Single remaining subagent
│   │   └── al-repo-summarizer.md    # Repo overview agent (others migrated to skill prompts)
│   ├── commands/                    # Slash commands not yet migrated to skills
│   │   └── review-pr.md            # Azure DevOps PR review
│   ├── rules/                       # Auto-loaded AL guardrails (engineering, naming, ...)
│   ├── hooks/                       # Turn-end auto-compile
│   ├── .mcp.json                    # MCP servers (incl. bcquality-mcp, bc-source-mcp)
│   └── README.md                    # Profile documentation
│                                    # NB: BCQuality corpus is no longer vendored here —
│                                    #     it is served by bcquality-mcp (DynInter fork)
├── project-settings-template.json   # Template for project .claude/settings.json
├── .gitignore
└── README.md                        # Repository overview and setup
```

## Key Concepts

### Document-Driven Development (AL Profile)

The AL profile implements a document-driven workflow where:

1. **Agents write to files, not chat** - Keeps main conversation clean
2. **Agents read previous outputs** - Sequential context flow via `.dev/` directory
3. **Persistent documentation** - Full audit trail in markdown files
4. **User approval gates** - Stop between major phases for validation

### Agent Collaboration Pattern

Each phase is a skill invoked with `/`. The lead session orchestrates; specialist
personas are spawned from prompt files inside each skill (no standalone agent files).

```
User Request
    ↓
/interview (optional) → .dev/<task>/00-interview.md
    ↓
/plan → .dev/<task>/02-solution-plan.md   (2-3 solution-architect personas debate, use MCP)
    ↓  [approval gate]
/develop → AL source files + .dev/<task>/03-code-review.md
           (al-developer personas, then 4-specialist review team)
    ↓  [approval gate]
/test → test codeunits + .dev/<task>/05-test-plan.md   (4 test-engineer personas)
    ↓
/document → docs/ (docs-writer persona)
```

### MCP Server Integration

The AL profile declares these MCP servers in `.mcp.json`:

1. **BC Code Intelligence MCP** (`bc-code-intelligence-mcp`)
   - BC specialist consultations via structured personas (the reasoning *judge*)
   - Uses the MCP's bundled knowledge base

2. **BCQuality MCP** (`bcquality-mcp`)
   - Serves Microsoft's BCQuality corpus (microsoft + community + DynInter `custom/` layers)
   - The *cited jurisprudence*; pointed at `DynamicsInternational/BCQuality` via `BCQUALITY_REPO_URL`
   - Workhorse tool: `bcquality_get_applicable_for_context`

3. **BC Source MCP** (`bc-source-mcp`)
   - Base app AL source lookup across all versions/localizations (partial clone + SQLite index)
   - Tools `bc_get_object`, `bc_get_event_publishers`, `bc_get_procedure`, `bc_search_code`, …

4. **Microsoft Docs MCP** (`microsoft_docs_mcp`)
   - Official AL/BC documentation lookup (HTTP-based)

5. **AL Dependency MCP** (`al-mcp-server`)
   - Base app object navigation, event discovery, dependency analysis

Plus `alcops` (AL code analysis) and `nab-al-tools` (XLIFF translation).

## Common Development Tasks

### Adding a New Plugin Profile

```bash
cd ~/claude-configs
mkdir -p profile-name/{.claude-plugin,commands,agents}

# Create plugin.json
cat > profile-name/.claude-plugin/plugin.json <<EOF
{
  "name": "profile-name",
  "description": "Brief description",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
EOF

# Add configuration files
# - profile-name/CLAUDE.md
# - profile-name/commands/*.md
# - profile-name/agents/*.md
# - profile-name/.mcp.json (if needed)

git add profile-name/
git commit -m "Add profile-name plugin"
git push
```

### Updating an Existing Plugin

```bash
cd ~/claude-configs

# Edit files (e.g., profile-al-development/CLAUDE.md)
# Make improvements to agents, commands, or instructions

git add profile-al-development/
git commit -m "Improve [specific aspect]"
git push

# On other computers
git pull  # Changes immediately available to all projects
```

### Creating a Command

Commands are user-invocable slash commands stored in `commands/*.md`:

```markdown
# Command: /command-name

Brief description of what this command does.

## Implementation

[Detailed instructions for Claude on how to execute this command]
```

### Creating an Agent

Agents are autonomous subprocesses stored in `agents/*.md`:

```markdown
# Agent: agent-name

Role description and purpose.

## Input

What this agent reads (e.g., .dev/01-requirements.md)

## Output

What this agent produces (e.g., .dev/02-solution.md)

## Process

[Detailed steps the agent should follow]
```

### Testing Plugin Changes

```bash
# In a test AL project
cd ~/path/to/test-project

# Ensure plugin is enabled in .claude/settings.json
cat .claude/settings.json

# Start Claude Code and test the change
claude

# Test specific command
/command-name "test input"
```

## Configuration Hierarchy

Claude Code loads configurations in this order (later overrides earlier):

1. Enterprise managed settings (if configured)
2. User settings (`~/.claude/settings.json`)
3. User plugins (registered in user settings)
4. **Project settings** (`.claude/settings.json`)
5. **Project plugins** (enabled in project settings) ← This repository's plugins load here
6. Local settings (`.claude/settings.local.json` - gitignored)

## File Naming Conventions

- **Commands**: `commands/command-name.md` (kebab-case)
- **Agents**: `agents/agent-name.md` (kebab-case)
- **Config**: `.claude-plugin/plugin.json`, `.mcp.json`
- **Documentation**: `CLAUDE.md` (uppercase), `README.md`

## MCP Configuration Structure

MCP servers are configured in `.mcp.json` at the plugin root:

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio|http|sse",
      "command": "executable",
      "args": ["arg1", "arg2"],
      "env": {
        "VAR_NAME": "value"
      }
    }
  }
}
```

## Git Workflow

This repository should be cloned to `~/claude-configs/` and kept synchronized:

```bash
# Initial setup
cd ~
git clone git@github.com:YOUR_USERNAME/claude-configs.git

# Regular sync
cd ~/claude-configs
git pull  # Get updates from other computers
# ... make changes ...
git add .
git commit -m "Descriptive message"
git push  # Share with other computers
```

## Security Considerations

- Never commit credentials, API keys, or certificates
- Use `.gitignore` to prevent accidental commits
- Keep authentication in project-local files (`.env`, gitignored)
- The `.gitignore` already excludes common sensitive patterns

## AL Profile Specifics

### Approval Gates

The AL profile implements mandatory approval gates in workflows:

1. After requirements analysis - user must approve before solution planning
2. After solution planning - user must approve before implementation
3. After code review - user must approve before testing

These gates prevent wasted work and ensure user validation at each phase.

### Iteration Pattern

Development phase uses iterative refinement:

```
al-developer → code
    ↓
code-reviewer → review
    ↓
If Critical/High issues → ITERATE back to al-developer
If Minor issues → Continue to diagnostics-fixer
```

### AL Compilation

The profile includes an `al-compile` bash script that:

- Auto-detects VS Code AL extension and uses matching compiler version
- Auto-detects workspace structure (single vs multi-app)
- Auto-finds all `.alpackages` directories
- Auto-applies ruleset files
- Includes standard analyzers by default
- Handles complex compilation scenarios automatically

Always use `al-compile` instead of manual AL compiler commands.

## Plugin Version Management

Plugins use semantic versioning in `plugin.json`:

- **Major**: Breaking changes (e.g., renamed commands, removed agents)
- **Minor**: New features (e.g., new commands, enhanced agents)
- **Patch**: Bug fixes, documentation improvements

Update the version in `plugin.json` and document changes in the profile's README.md.

## Troubleshooting

### Plugin Not Loading

1. Verify registration in project `.claude/settings.json`
2. Check `extraKnownMarketplaces` path is absolute
3. Validate `plugin.json` syntax
4. Run `/config` in Claude Code to see loaded plugins

### MCP Server Issues

1. Check `.mcp.json` syntax
2. Verify executable paths (e.g., `bc-code-intelligence-mcp` in PATH)
3. Test MCP servers independently
4. Check environment variables are set correctly

### Command Not Found

1. Ensure plugin is enabled in project settings
2. Command files must be in `commands/` directory
3. Command names are kebab-case without `.md` extension
4. Restart Claude Code session if needed

### Changes Not Appearing

1. Settings and CLAUDE.md hot-reload automatically
2. For command/agent changes, start a new Claude Code session
3. Verify changes are committed and pushed
4. On other computers, verify `git pull` was run

## Best Practices

1. **Test before pushing** - Verify changes work in a test project
2. **Clear commit messages** - Describe what changed and why
3. **Update documentation** - Keep READMEs in sync with changes
4. **Semantic versioning** - Increment version in plugin.json
5. **Backward compatibility** - Avoid breaking changes when possible
6. **Scope plugins narrowly** - One technology/domain per plugin
7. **Document agent inputs/outputs** - Clear data flow in agent definitions
8. **Use approval gates** - Stop for user validation at major decision points
