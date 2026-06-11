#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Re-vendor Microsoft's BCQuality knowledge corpus into the AL plugin.

.DESCRIPTION
    Vendoring keeps BCQuality as plain files inside the plugin (required: Claude Code
    plugins copy their files to a cache and cannot reference external paths, so a git
    submodule would deploy empty). This script pulls the latest upstream and overwrites
    the vendored microsoft/ and community/ knowledge layers.

    It NEVER touches bcquality/custom/ — those are our own DynInter rules, not Microsoft's.

.PARAMETER Check
    Drift check only. Compares the upstream HEAD commit to the vendored commit recorded
    in bcquality/README.md and reports whether an update is available. Modifies nothing.

.EXAMPLE
    ./scripts/revendor-bcquality.ps1 -Check
    Tells you if you are behind upstream, without changing anything.

.EXAMPLE
    ./scripts/revendor-bcquality.ps1
    Pulls the latest upstream, overwrites microsoft/ and community/, updates the recorded
    commit/date in README.md. Review `git diff` before committing.
#>
[CmdletBinding()]
param(
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

$Upstream   = 'https://github.com/microsoft/BCQuality.git'
$RepoRoot   = Split-Path $PSScriptRoot -Parent
$VendorDir  = Join-Path $RepoRoot 'profile-al-development/bcquality'
$Readme     = Join-Path $VendorDir 'README.md'
$Layers     = @('microsoft/knowledge', 'community/knowledge')

function Get-VendoredSha {
    if (-not (Test-Path $Readme)) { return $null }
    $line = Select-String -Path $Readme -Pattern 'Vendored commit:\s*`([0-9a-f]{7,40})`' | Select-Object -First 1
    if ($line) { return $line.Matches[0].Groups[1].Value }
    return $null
}

function Get-UpstreamSha {
    # Lightweight: no clone, just ask the remote for HEAD.
    $out = git ls-remote $Upstream HEAD 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $out) { throw "Cannot reach upstream ($Upstream). Check network/git." }
    return ($out -split '\s+')[0]
}

$vendored = Get-VendoredSha
Write-Host "Vendored commit : $($vendored ?? '(unknown)')" -ForegroundColor Cyan

# ----- CHECK MODE -------------------------------------------------------------
if ($Check) {
    $upstream = Get-UpstreamSha
    Write-Host "Upstream HEAD   : $upstream" -ForegroundColor Cyan
    if ($vendored -and $upstream.StartsWith($vendored)) {
        Write-Host "`n[OK] Up to date. Nothing to re-vendor." -ForegroundColor Green
    } else {
        Write-Host "`n[BEHIND] Upstream has moved. Run this script with no arguments to re-vendor." -ForegroundColor Yellow
    }
    return
}

# ----- RE-VENDOR MODE ---------------------------------------------------------
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) 'bcq-revendor'
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }

try {
    Write-Host "`nCloning upstream (shallow)..." -ForegroundColor Cyan
    git clone --depth 1 --quiet $Upstream $tmp
    if ($LASTEXITCODE -ne 0) { throw "git clone failed." }

    $newSha  = (git -C $tmp rev-parse HEAD).Trim()
    $newDate = (git -C $tmp show -s --format=%cs HEAD).Trim()   # %cs = committer date, YYYY-MM-DD

    foreach ($layer in $Layers) {
        $src = Join-Path $tmp $layer
        $dst = Join-Path $VendorDir $layer
        if (-not (Test-Path $src)) {
            Write-Host "  ! upstream layer '$layer' missing, skipping." -ForegroundColor Yellow
            continue
        }
        if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
        New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
        Copy-Item -Recurse -Force $src $dst
        $n = (Get-ChildItem -Recurse -File $dst).Count
        Write-Host "  vendored $layer ($n files)" -ForegroundColor Green
    }

    # Refresh LICENSE
    Copy-Item -Force (Join-Path $tmp 'LICENSE') (Join-Path $VendorDir 'LICENSE')

    # Update provenance in README
    $content = Get-Content $Readme -Raw
    $content = $content -replace '(Vendored commit:\s*`)[0-9a-f]{7,40}(`)', "`${1}$newSha`${2}"
    $content = $content -replace '(Vendored date \(upstream commit date\):\s*)[0-9]{4}-[0-9]{2}-[0-9]{2}', "`${1}$newDate"
    Set-Content -Path $Readme -Value $content -NoNewline

    Write-Host "`n[DONE] Re-vendored to $newSha ($newDate)." -ForegroundColor Green
    Write-Host "Review the changes before committing:" -ForegroundColor Cyan
    Write-Host "  git -C `"$RepoRoot`" status --short profile-al-development/bcquality" -ForegroundColor DarkGray
    Write-Host "  git -C `"$RepoRoot`" diff --stat profile-al-development/bcquality" -ForegroundColor DarkGray
}
finally {
    if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
}
