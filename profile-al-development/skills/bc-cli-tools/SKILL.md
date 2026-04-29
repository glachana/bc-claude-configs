---
name: bc-cli-tools
description: Use when invoking BC build/test CLI tools (al-compile, bc-publish, bc-test) for AL development. Covers auto-detection features, options reference, output formats (text/JSON), failures-only filter, .bcconfig.json structure, and the standard build-test cycle. Reference whenever a teammate is about to compile, deploy, or run AL tests.
---

# BC Build & Test CLI Tools

These CLI tools are available on PATH for compilation, deployment, and test execution against a local BC dev server.

---

## al-compile — AL Compilation Wrapper

**ALWAYS use `al-compile` instead of manual AL compiler commands.**

```bash
al-compile                    # Default: compile with all standard analyzers
al-compile --verbose          # Show detailed compilation info
al-compile --analyzers all    # Include ALL analyzers
al-compile --clean            # Clean .alpackages before compile
```

### What it does automatically

- Auto-detects VS Code AL extension and uses matching compiler version
- Auto-detects workspace structure (single vs multi-app)
- Auto-finds all `.alpackages` directories for transitive dependencies
- Auto-applies ruleset files (workspace or project level)
- Auto-includes AppSourceCop if `AppSourceCop.json` exists

### Default analyzers

CodeCop, UICop, PerTenantExtensionCop, LinterCop (+ AppSourceCop if config exists)

### Options

```bash
--analyzers <mode>    # default | all | none | "CodeCop,UICop,LinterCop"
--output <file>       # Error log location (default: .dev/compile-errors.log)
--clean               # Clean .alpackages before compiling
--no-parallel         # Disable parallel compilation
--verbose, -v         # Show detailed output
```

### Troubleshooting

If not found, run `source ~/.bashrc` or open new terminal.

---

## bc-publish — Deploy to BC Server

**Publishes .app files to BC development server.**

```bash
bc-publish                    # Publish current app
bc-publish --init             # Create .bcconfig.json template
```

Requires `.bcconfig.json` in project root or home directory with server configuration.

---

## bc-test — Execute Test Codeunits

**Runs AL test codeunits via OData API against BC server.**

```bash
bc-test                       # Auto-detect codeunit range from app.json
bc-test 50200                 # Run specific codeunit
bc-test 50200 50201           # Run multiple codeunits
bc-test 50200-50210           # Run codeunit range
```

### File output (recommended for agents)

```bash
bc-test -o .dev/test-results.txt              # Text format (human-readable)
bc-test -o .dev/test-results.json -f json     # JSON format (machine-readable)
bc-test --failures-only                        # Show only failed tests
bc-test -o .dev/failures.txt --failures-only   # Save only failures
```

### Smart defaults

- Console output → defaults to `--failures-only` (less noise)
- File output → defaults to all tests (complete record)

### Auto-detection

Reads first `idRange` from `app.json` in current directory — no codeunit IDs needed.

### JSON output structure

```json
{
  "total_tests_run": 567,
  "passed": 558,
  "failed": 9,
  "showing": "all",
  "tests": [
    {
      "codeunitId": 83220,
      "codeunitName": "Credit Limit Tests",
      "functionName": "Test_ValidateCreditLimit_WithinLimit",
      "success": true,
      "errorMessage": "",
      "callStack": ""
    }
  ]
}
```

### CI/CD parsing

```bash
# Parse with jq for failed tests
jq '.tests[] | select(.success == false)' test-results.json

# Check if any tests failed
if jq -e '.failed > 0' test-results.json; then
  echo "Tests failed!"
  exit 1
fi
```

---

## .bcconfig.json — BC Server Configuration

Required by `bc-publish` and `bc-test`:

```json
{
  "server": "http://localhost",
  "port": 7048,
  "instance": "BC",
  "tenant": "default",
  "username": "admin",
  "password": "Admin123!",
  "apiInstance": "BC",
  "apiPassword": "your-web-service-key",
  "schemaUpdateMode": "synchronize"
}
```

- `apiPassword`: web service access key (for bc-test OData access)
- `password`: dev endpoint publishing
- Create with `bc-publish --init`
- Place in project root or home directory

---

## Standard Build-Test Cycle

**Teammates follow this sequence:**

```bash
al-compile                                    # 1. Compile
bc-publish                                    # 2. Deploy to BC
bc-test -o .dev/test-results.txt              # 3. Run tests
```

For full TDD discipline (RED-GREEN-REFACTOR with hard approval gates), see the `tdd-workflow` skill.
