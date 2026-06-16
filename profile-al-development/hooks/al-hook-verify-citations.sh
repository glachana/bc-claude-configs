#!/usr/bin/env bash
# SubagentStop hook: validates BCQuality citations in .dev/ deliverables.
# Non-blocking (report-only) — surfaces broken/hallucinated citation paths to the lead,
# which enforces the hard gate. Never traps on stale deliverables.

set -uo pipefail

# Drain stdin (hook receives JSON payload; we don't need its fields here).
cat >/dev/null 2>&1 || true

# Need PowerShell to run the validator. Skip silently if unavailable.
PWSH=$(command -v pwsh || command -v powershell || true)
[[ -z "$PWSH" ]] && exit 0

SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/verify-citations.ps1"
[[ ! -f "$SCRIPT" ]] && exit 0

OUT=$("$PWSH" -NoProfile -File "$SCRIPT" -ReportOnly 2>&1 || true)

# Only speak up when something is actually broken; stay quiet otherwise.
if echo "$OUT" | grep -q "BROKEN CITATIONS"; then
    {
        echo "BCQuality citation check found unresolved paths in .dev/ deliverables:"
        echo "$OUT"
    } >&2
fi

exit 0
