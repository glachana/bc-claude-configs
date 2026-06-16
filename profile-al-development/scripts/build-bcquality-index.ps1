<#
.SYNOPSIS
  Generates per-domain index files for the vendored BCQuality corpus.

.DESCRIPTION
  Walks bcquality/{custom,community,microsoft}/knowledge/<domain>/*.md and emits one
  index file per domain at bcquality/_index/<domain>.md. Each index is a markdown table
  (slug, layer, bc-version, triggers, summary, samples) sorted by layer precedence
  (custom > community > microsoft) then slug.

  Subagents read their domain index FIRST (one small deterministic file) instead of
  grepping the ~250-file corpus blindly, then Read only the 2-6 slugs they need.

  Re-run this after re-vendoring the corpus. Idempotent: overwrites _index/ each time.

.NOTES
  Pure file generation. No network, no BC instance.
#>
[CmdletBinding()]
param(
    # Plugin root (folder containing bcquality/). Defaults to this script's parent's parent.
    [string]$PluginRoot = (Split-Path -Parent (Split-Path -Parent $PSCommandPath))
)

$ErrorActionPreference = 'Stop'

$corpus = Join-Path $PluginRoot 'bcquality'
if (-not (Test-Path $corpus)) {
    throw "BCQuality corpus not found at: $corpus"
}

$indexDir = Join-Path $corpus '_index'
$null = New-Item -ItemType Directory -Force -Path $indexDir

# Layer precedence: highest authority first.
$layers = @('custom', 'community', 'microsoft')

function Get-FrontmatterAndBody {
    param([string[]]$Lines)
    $fm = @{}
    $bodyStart = 0
    if ($Lines.Count -gt 0 -and $Lines[0].Trim() -eq '---') {
        $i = 1
        while ($i -lt $Lines.Count -and $Lines[$i].Trim() -ne '---') {
            if ($Lines[$i] -match '^\s*([\w-]+)\s*:\s*(.*)$') {
                $fm[$matches[1]] = $matches[2].Trim()
            }
            $i++
        }
        $bodyStart = $i + 1
    }
    [pscustomobject]@{ Frontmatter = $fm; BodyStart = $bodyStart }
}

function Format-ListField {
    param([string]$Raw)
    if ([string]::IsNullOrWhiteSpace($Raw)) { return '' }
    $Raw.Trim().TrimStart('[').TrimEnd(']')
}

function Get-FirstSentence {
    param([string[]]$Lines, [int]$BodyStart)
    # Find '## Description' and take the first non-empty paragraph line, first sentence.
    $descIdx = -1
    for ($i = $BodyStart; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^##\s+Description\s*$') { $descIdx = $i; break }
    }
    if ($descIdx -lt 0) { return '' }
    for ($i = $descIdx + 1; $i -lt $Lines.Count; $i++) {
        $line = $Lines[$i].Trim()
        if ($line -eq '') { continue }
        if ($line.StartsWith('>')) { continue }   # skip callouts/blockquotes
        if ($line.StartsWith('#')) { break }       # hit next heading, no prose
        # First sentence: split on '. ' but keep it bounded.
        $sentence = ($line -split '(?<=\.)\s', 2)[0]
        if ($sentence.Length -gt 160) { $sentence = $sentence.Substring(0, 157) + '...' }
        return $sentence
    }
    return ''
}

function ConvertTo-Cell {
    param([string]$Text)
    # Escape pipes and collapse whitespace for markdown table safety.
    if ($null -eq $Text) { return '' }
    ($Text -replace '\|', '\|' -replace '\s+', ' ').Trim()
}

# Discover domains across all layers.
$domains = [System.Collections.Generic.SortedSet[string]]::new()
foreach ($layer in $layers) {
    $kdir = Join-Path $corpus "$layer/knowledge"
    if (Test-Path $kdir) {
        Get-ChildItem -Path $kdir -Directory | ForEach-Object { [void]$domains.Add($_.Name) }
    }
}

$summaryRows = @()

foreach ($domain in $domains) {
    $rows = @()
    foreach ($layer in $layers) {
        $ddir = Join-Path $corpus "$layer/knowledge/$domain"
        if (-not (Test-Path $ddir)) { continue }
        Get-ChildItem -Path $ddir -Filter '*.md' -File |
            Where-Object { $_.Name -ne 'README.md' } |
            ForEach-Object {
                $slug = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
                $lines = Get-Content -LiteralPath $_.FullName
                $parsed = Get-FrontmatterAndBody -Lines $lines
                $fm = $parsed.Frontmatter
                $bcv = Format-ListField $fm['bc-version']
                if ([string]::IsNullOrWhiteSpace($bcv)) { $bcv = 'all' }
                $kw = Format-ListField $fm['keywords']
                $summary = Get-FirstSentence -Lines $lines -BodyStart $parsed.BodyStart
                $good = Test-Path (Join-Path $ddir "$slug.good.al")
                $bad = Test-Path (Join-Path $ddir "$slug.bad.al")
                $samples = @()
                if ($good) { $samples += 'good' }
                if ($bad) { $samples += 'bad' }

                $rows += [pscustomobject]@{
                    Slug    = $slug
                    Layer   = $layer
                    BcVer   = $bcv
                    Trigger = $kw
                    Summary = $summary
                    Samples = ($samples -join '/')
                    RelPath = "bcquality/$layer/knowledge/$domain/$slug.md"
                }
            }
    }

    # Sort: layer precedence (custom=0, community=1, microsoft=2) then slug.
    $order = @{ custom = 0; community = 1; microsoft = 2 }
    $rows = $rows | Sort-Object @{ Expression = { $order[$_.Layer] } }, Slug

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("# BCQuality index — domain: ``$domain``")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("> AUTO-GENERATED by ``scripts/build-bcquality-index.ps1``. Do not edit by hand.")
    [void]$sb.AppendLine("> Read this index FIRST, pick the 2-6 relevant slugs by Trigger/Summary,")
    [void]$sb.AppendLine("> then ``Read`` only those ``.md`` files. Cite as ``[BCQuality: <path>]``.")
    [void]$sb.AppendLine("> Layer precedence: custom > community > microsoft.")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("| slug | layer | bc-version | triggers (keywords) | summary | samples |")
    [void]$sb.AppendLine("|------|-------|-----------|---------------------|---------|---------|")
    foreach ($r in $rows) {
        $cells = @(
            (ConvertTo-Cell $r.Slug),
            (ConvertTo-Cell $r.Layer),
            (ConvertTo-Cell $r.BcVer),
            (ConvertTo-Cell $r.Trigger),
            (ConvertTo-Cell $r.Summary),
            (ConvertTo-Cell $r.Samples)
        )
        [void]$sb.AppendLine("| " + ($cells -join ' | ') + " |")
    }
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("_Path pattern: ``bcquality/<layer>/knowledge/$domain/<slug>.md``  -  $($rows.Count) rules._")

    $outFile = Join-Path $indexDir "$domain.md"
    Set-Content -LiteralPath $outFile -Value $sb.ToString() -Encoding utf8 -NoNewline
    Write-Host ("  {0,-12} {1,3} rules -> {2}" -f $domain, $rows.Count, "_index/$domain.md")
    $summaryRows += [pscustomobject]@{ Domain = $domain; Rules = $rows.Count }
}

# Master README for the _index folder.
$readme = [System.Text.StringBuilder]::new()
[void]$readme.AppendLine("# BCQuality index")
[void]$readme.AppendLine()
[void]$readme.AppendLine("AUTO-GENERATED per-domain retrieval indexes. Subagents read the domain file(s)")
[void]$readme.AppendLine("matching their assigned domain, then ``Read`` only the relevant ``<slug>.md`` rules.")
[void]$readme.AppendLine()
[void]$readme.AppendLine("| domain | rules | index file |")
[void]$readme.AppendLine("|--------|-------|------------|")
foreach ($s in ($summaryRows | Sort-Object Domain)) {
    [void]$readme.AppendLine("| $($s.Domain) | $($s.Rules) | ``bcquality/_index/$($s.Domain).md`` |")
}
[void]$readme.AppendLine()
[void]$readme.AppendLine("Regenerate with: ``pwsh scripts/build-bcquality-index.ps1``")
Set-Content -LiteralPath (Join-Path $indexDir 'README.md') -Value $readme.ToString() -Encoding utf8 -NoNewline

Write-Host ""
Write-Host ("Done. {0} domain indexes written to {1}" -f $summaryRows.Count, $indexDir)
