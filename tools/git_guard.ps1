# 控制面提交门卫。只在本仓库内 add，推送只走 SSH 部署密钥。
# 用法：
#   .\tools\git_guard.ps1 -Message "why"     有改动则提交，然后 SSH push
#   .\tools\git_guard.ps1 -PushOnly          只推已有提交
param(
    [string]$Message = "",
    [switch]$PushOnly
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if (-not (Test-Path (Join-Path $root ".git"))) {
    throw "Not a git repo: $root"
}

$key = Join-Path $env:USERPROFILE ".ssh\upr6_github"
if (-not (Test-Path $key)) {
    throw "Missing SSH key: $key"
}

$origin = (git remote get-url origin).Trim()
if ($origin -match '^https://') {
    throw "origin is HTTPS ($origin). Control plane must use SSH: git@github.com:NGXingye/UPR6Lesson-workspace.git"
}
if ($origin -notmatch '^git@github\.com:') {
    throw "origin must be git@github.com:...  got: $origin"
}

function Invoke-SshGit {
    param([Parameter(Mandatory = $true)][string[]]$GitArgs)
    $ssh = "ssh -i `"$key`" -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
    $env:GCM_INTERACTIVE = "never"
    & git -c "core.sshCommand=$ssh" @GitArgs
    if ($LASTEXITCODE -ne 0) {
        throw "git failed: $($GitArgs -join ' ')"
    }
}

if (-not $PushOnly) {
    if ([string]::IsNullOrWhiteSpace($Message)) {
        throw "Commit requires -Message. Use -PushOnly to only push."
    }

    $denyNames = @("project_cursor.yml")
    $denyFragments = @("\Library\", "/Library/", "\Temp\", "\Logs\", "UPR6Lesson\Assets\", "UPR6Lesson/Assets/")

    $status = git status --porcelain
    if ($status) {
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
    }
    else {
        Write-Output "Nothing to commit."
    }
}

Invoke-SshGit -GitArgs @("push", "-u", "origin", "HEAD")
git status -sb
