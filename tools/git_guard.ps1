# 控制面提交门卫。只在 UPR6Lesson-workspace 内 add。
# 用法：.\tools\git_guard.ps1 -Message "why"
param(
    [Parameter(Mandatory = $true)]
    [string]$Message
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if (-not (Test-Path (Join-Path $root ".git"))) {
    throw "Not a git repo: $root"
}

$denyNames = @("project_cursor.yml")
$denyFragments = @("\Library\", "/Library/", "\Temp\", "\Logs\", "UPR6Lesson\Assets\", "UPR6Lesson/Assets/")

$status = git status --porcelain
if (-not $status) {
    Write-Output "Nothing to commit."
    exit 0
}

$blocked = @()
foreach ($line in $status) {
    $path = $line.Substring(3).Trim().Trim('"')
    foreach ($name in $denyNames) {
        if ([System.IO.Path]::GetFileName($path) -eq $name) { $blocked += $path }
    }
    foreach ($frag in $denyFragments) {
        if ($path.IndexOf($frag, [StringComparison]::OrdinalIgnoreCase) -ge 0) { $blocked += $path }
    }
}

if ($blocked.Count -gt 0) {
    throw ("git_guard denied:`n" + ($blocked | Select-Object -Unique | ForEach-Object { "  $_" } | Out-String))
}

git add -A
git reset HEAD -- project_cursor.yml 2>$null
git commit -m $Message
git status
