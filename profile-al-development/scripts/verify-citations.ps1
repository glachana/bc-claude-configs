<#
.SYNOPSIS
  Validates BCQuality citations in agent deliverables.

.DESCRIPTION
  Scans markdown/text deliverables for `[BCQuality: <path>]` citations and verifies each
  cited path resolves to a real file in the vendored corpus. Catches hallucinated paths,
  stale slugs (renamed/removed after a re-vendor), and malformed citations.

  This turns the lead's soft "did they cite?" gate into a mechanical "is the citation
  real?" check. House findings (`house:` prefix, no path) are reported as informational.

.PARAMETER Path
  File or directory to scan. Default: the project's .dev/ folder (where agents write
  deliverables), resolved from CLAUDE_PROJECT_DIR or the current directory.

.PARAMETER PluginRoot
  Plugin root containing bcquality/. Default: CLAUDE_PLUGIN_ROOT, else this script's
  parent's parent.

.OUTPUTS
  Exit 0 = all citations valid (or none found). Exit 2 = one or more broken citations.

.EXAMPLE
  pwsh scripts/verify-citations.ps1 -Path .dev/credit-limit-validation
#>
[CmdletBinding()]
param(
    [string]$Path,
    [string]$PluginRoot,
    # Hook mode: always exit 0 (report findings without blocking). The lead reads the
    # report and enforces the gate. Manual runs omit this for a real exit-2 gate.
    [switch]$ReportOnly
)

$ErrorActionPreference = 'Stop'

if (-not $PluginRoot) {
    $PluginRoot = $env:CLAUDE_PLUGIN_ROOT
}
if (-not $PluginRoot) {
    $PluginRoot = (Split-Path -Parent (Split-Path -Parent $PSCommandPath))
}

if (-not $Path) {
    $base = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
    $Path = Join-Path $base '.dev'
}

if (-not (Test-Path $Path)) {
    Write-Host "verify-citations: nothing to scan (path not found: $Path)"
    exit 0
}

# Collect target files.
$files = if (Test-Path $Path -PathType Leaf) {
    @(Get-Item -LiteralPath $Path)
} else {
    Get-ChildItem -Path $Path -Recurse -File -Include '*.md', '*.al', '*.txt' -ErrorAction SilentlyContinue
}

# Citation token: [BCQuality: <path>]  (path may contain / and -, . )
$citationRx = '\[BCQuality:\s*([^\]]+?)\s*\]'
$houseRx = 'house:[A-Za-z0-9\-_]+'

$total = 0
$broken = @()
$houseCount = 0
$seenPaths = [System.Collections.Generic.HashSet[string]]::new()

foreach ($f in $files) {
    $content = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    $houseCount += ([regex]::Matches($content, $houseRx)).Count

    foreach ($m in [regex]::Matches($content, $citationRx)) {
        $total++
        $cited = $m.Groups[1].Value.Trim()
        # Normalize: strip leading ./ and any wrapping backticks.
        $cited = $cited.Trim('`').TrimStart('.', '/')
        $resolved = Join-Path $PluginRoot $cited
        if (-not (Test-Path $resolved -PathType Leaf)) {
            $broken += [pscustomobject]@{ File = $f.FullName; Citation = $cited }
        } else {
            [void]$seenPaths.Add($cited)
        }
    }
}

Write-Host "verify-citations: scanned $($files.Count) file(s) under $Path"
Write-Host ("  citations: {0} total, {1} distinct valid, {2} broken, {3} house findings" -f `
        $total, $seenPaths.Count, $broken.Count, $houseCount)

if ($broken.Count -gt 0) {
    Write-Host ""
    Write-Host "BROKEN CITATIONS (path does not resolve in corpus):" -ForegroundColor Red
    foreach ($b in $broken) {
        $rel = $b.File.Replace($PluginRoot, '').TrimStart('\', '/')
        Write-Host ("  - {0}" -f $b.Citation) -ForegroundColor Red
        Write-Host ("      in {0}" -f $rel)
    }
    Write-Host ""
    Write-Host "Fix: cite an existing path from bcquality/_index/<domain>.md, or use a 'house:' finding."
    if ($ReportOnly) { exit 0 }
    exit 2
}

if ($total -eq 0 -and $houseCount -eq 0) {
    Write-Host "  (no BCQuality citations found — expected only if no covered domain was touched)"
}

exit 0
