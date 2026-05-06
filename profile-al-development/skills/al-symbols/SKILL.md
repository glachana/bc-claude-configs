---
name: al-symbols
description: Download AL symbol packages (.app files) for the current project's dependencies from Microsoft NuGet feeds. Reads app.json to determine required packages.
---

# /al-symbols — Download AL Symbol Packages

## Tool Location

`al-symbols` is on PATH (installed at `/usr/local/bin/al-symbols`).

## Tool Reference

```
!al-symbols --help
```

## Behavior

1. Parse `$ARGUMENTS` and pass them through (e.g., `/al-symbols -c de --latest`)
2. If no country code is provided, ask the user which localization they need
3. Run `al-symbols` in the project directory (where `app.json` is located)
4. Symbol `.app` files are downloaded to `.alpackages/` by default
5. Report which packages were downloaded and their versions

## Common Usage

```bash
# Download symbols for a specific country
al-symbols -c w1

# Download latest compatible versions instead of oldest
al-symbols -c be --latest

# Use a custom NuGet feed with authentication
al-symbols -c de --pat $AL_SYMBOLS_PAT
```

## Notes

- Requires network access to `dynamicssmb2.pkgs.visualstudio.com` (allowed through firewall)
- Must be run from a directory containing `app.json`
- Downloads the **oldest** compatible version by default (safer for dependency resolution)
