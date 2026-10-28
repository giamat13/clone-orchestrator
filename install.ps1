<#
.SYNOPSIS
  Installs the clone-orchestrator skill and, optionally, the tools it routes to.
.DESCRIPTION
  Prints the full plan and every command first, then asks before each step.
  Installs only official URLs at the versions pinned in tools.json.
  Skips what is already installed. Safe to run more than once.
  Never pipes downloaded content into a shell.
.PARAMETER SkillOnly
  Install only the clone-orchestrator skill (no third-party tools).
.PARAMETER DryRun
  Print the plan and exit without changing anything.
.PARAMETER Yes
  Do not ask per step (use only if you read the plan).
#>
param(
  [switch]$SkillOnly,
  [switch]$DryRun,
  [switch]$Yes
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$claudeHome = Join-Path $env:USERPROFILE '.claude'
$skillsDir = Join-Path $claudeHome 'skills'
$srcDir = Join-Path $claudeHome 'clone-orchestrator-src'
$backupDir = Join-Path $claudeHome ('clone-orchestrator-backup\' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$tools = (Get-Content (Join-Path $root 'tools.json') -Raw | ConvertFrom-Json).tools

$installed = New-Object System.Collections.ArrayList
$skipped = New-Object System.Collections.ArrayList
$failed = New-Object System.Collections.ArrayList
$manual = New-Object System.Collections.ArrayList

function Confirm-Step([string]$text) {
  Write-Host "  > $text"
  if ($DryRun) { return $false }
  if ($Yes) { return $true }
  return ((Read-Host '    Run this? [y/N]') -match '^(y|yes)$')
}

function Backup-Settings {
  if (Test-Path $backupDir) { return }
  New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
  foreach ($f in @((Join-Path $env:USERPROFILE '.claude.json'), (Join-Path $claudeHome 'settings.json'))) {
    if (Test-Path $f) { Copy-Item $f $backupDir }
  }
  Write-Host "  Backup written to $backupDir"
}

function Has-Command([string]$name) { return [bool](Get-Command $name -ErrorAction SilentlyContinue) }

function Install-Skill {
  $name = 'clone-orchestrator'
  $from = Join-Path $root 'skills\clone-orchestrator'
  $to = Join-Path $skillsDir $name
  Write-Host "`n[clone-orchestrator] copy $from -> $to"
  if (Test-Path $to) {
    $same = (Get-FileHash (Join-Path $from 'SKILL.md')).Hash -eq (Get-FileHash (Join-Path $to 'SKILL.md')).Hash
    if ($same) { [void]$skipped.Add("$name (already installed, identical)"); return }
  }
  if (-not (Confirm-Step "Copy-Item -Recurse $from $to")) { [void]$skipped.Add("$name (declined or dry run)"); return }
  try {
    if (Test-Path $to) { Backup-Settings; Move-Item $to ($to + '.bak-' + (Get-Date -Format 'yyyyMMddHHmmss')) }
    New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null
    Copy-Item -Recurse $from $to
    [void]$installed.Add($name)
  } catch { [void]$failed.Add("$name : $($_.Exception.Message)") }
}

function Clone-Pinned($tool) {
  $dest = Join-Path $srcDir $tool.id
  if (-not (Test-Path $dest)) {
    & git -c core.longpaths=true clone $tool.url $dest
    if ($LASTEXITCODE -ne 0) { throw "git clone failed for $($tool.id)" }
  }
  $ref = if ($tool.pin.commit) { $tool.pin.commit } else { $tool.pin.value }
  & git -C $dest -c advice.detachedHead=false checkout $ref
  if ($LASTEXITCODE -ne 0) { throw "git checkout $ref failed for $($tool.id)" }
  return $dest
}

function Install-Tool($tool) {
  Write-Host "`n[$($tool.id)] $($tool.name)  $($tool.url)  ($($tool.license), pin $($tool.pin.value))"
  try {
    switch ($tool.id) {
      'replica' {
        if (Test-Path (Join-Path $skillsDir 'replica-recon')) { [void]$skipped.Add('replica (already installed)'); return }
        if (-not (Confirm-Step "git clone + checkout $($tool.pin.value), copy replica-* folders into $skillsDir")) { [void]$skipped.Add('replica (declined)'); return }
        $d = Clone-Pinned $tool
        Get-ChildItem $d -Directory -Filter 'replica-*' | ForEach-Object { Copy-Item -Recurse $_.FullName (Join-Path $skillsDir $_.Name) }
        [void]$installed.Add('replica')
      }
      'clone-team' {
        if (Test-Path (Join-Path $skillsDir 'clone-team')) { [void]$skipped.Add('clone-team (already installed)'); return }
        if (-not (Confirm-Step "git clone + checkout $($tool.pin.value), copy skills/clone-team into $skillsDir")) { [void]$skipped.Add('clone-team (declined)'); return }
        $d = Clone-Pinned $tool
        Copy-Item -Recurse (Join-Path $d 'skills\clone-team') (Join-Path $skillsDir 'clone-team')
        [void]$installed.Add('clone-team')
      }
      'rea' {
        if (-not (Has-Command 'npm')) { [void]$failed.Add('rea : npm not found'); return }
        $cur = (& npm ls -g rea-agents --depth=0 2>$null | Out-String)
        if ($cur -match 'rea-agents@6\.8\.0') { [void]$skipped.Add('rea (6.8.0 already installed)'); return }
        Write-Host '  Note: this upgrades an older installed rea-agents to the pinned version.'
        if (-not (Confirm-Step 'npm install --global rea-agents@6.8.0')) { [void]$skipped.Add('rea (declined)'); return }
        & npm install --global rea-agents@6.8.0
        if ($LASTEXITCODE -ne 0) { throw 'npm install failed' }
        Write-Host '  Next, run yourself: rea setup --client claude_code --dry-run  then  rea setup --client claude_code'
        [void]$installed.Add('rea (run rea setup / rea doctor)')
      }
      'ui-reverse-engineering' {
        if (-not (Has-Command 'uv')) { [void]$failed.Add('ui-reverse-engineering : uv not found'); return }
        if (-not (Confirm-Step "git clone + checkout $($tool.pin.value); claude plugin marketplace add <clone>; claude plugin install ui-clone-skills@voidmatcha")) { [void]$skipped.Add('ui-reverse-engineering (declined)'); return }
        Backup-Settings
        $d = Clone-Pinned $tool
        & claude plugin marketplace add $d
        if ($LASTEXITCODE -ne 0) { throw 'marketplace add failed' }
        & claude plugin install ui-clone-skills@voidmatcha
        if ($LASTEXITCODE -ne 0) { throw 'plugin install failed' }
        [void]$installed.Add('ui-reverse-engineering')
      }
      default {
        [void]$manual.Add("$($tool.id) : $($tool.installNote)")
      }
    }
  } catch { [void]$failed.Add("$($tool.id) : $($_.Exception.Message)") }
}

Write-Host 'clone-orchestrator installer'
Write-Host "Skill target : $skillsDir"
Write-Host "Backups      : $backupDir (created only before settings changes)"
if (-not $SkillOnly) {
  Write-Host 'Tools        :'
  $tools | ForEach-Object { Write-Host "  - $($_.id)  $($_.url)  pin $($_.pin.value)" }
}
if ($DryRun) { Write-Host 'DRY RUN: nothing will be changed.' }

Install-Skill
if (-not $SkillOnly) { foreach ($t in $tools) { Install-Tool $t } }

Write-Host "`n=== Summary ==="
Write-Host "Installed : $($installed -join '; ')"
Write-Host "Skipped   : $($skipped -join '; ')"
Write-Host "Failed    : $($failed -join '; ')"
Write-Host "Manual    : $($manual -join '; ')"
Write-Host "`nOpen a NEW Claude Code session so the skills load."
if ($failed.Count -gt 0) { exit 1 }
