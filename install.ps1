param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('install', 'remove')]
    [string]$Action
)

$scriptDir = "$env:USERPROFILE\bin"
$scriptPath = "$scriptDir\filemerger.ps1"
$profilePath = $PROFILE.CurrentUserAllHosts

function Test-AdminPrivileges {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-FileMerger {
    # Create bin directory if it doesn't exist
    if (-not (Test-Path $scriptDir)) {
        New-Item -ItemType Directory -Path $scriptDir | Out-Null
    }

    # Copy script to bin directory
    Copy-Item -Path ".\filemerger.ps1" -Destination $scriptPath -Force

    # Create PowerShell profile if it doesn't exist
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    # Add to PATH if not already there
    $path = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($path -notlike "*$scriptDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$path;$scriptDir", "User")
    }

    # Add alias to PowerShell profile if not already there
    $aliasContent = "Set-Alias -Name fmerge -Value $scriptPath"
    if (-not (Select-String -Path $profilePath -Pattern "Set-Alias.*fmerge" -Quiet)) {
        Add-Content -Path $profilePath -Value "`n$aliasContent"
    }

    Write-Host "Installation complete! Please restart your PowerShell window to use 'fmerge' command."
}

function Remove-FileMerger {
    # Remove script
    if (Test-Path $scriptPath) {
        Remove-Item -Path $scriptPath -Force
        Write-Host "Removed script from $scriptPath"
    }

    # Remove bin directory if empty
    if (Test-Path $scriptDir) {
        $items = Get-ChildItem -Path $scriptDir
        if ($items.Count -eq 0) {
            Remove-Item -Path $scriptDir -Force
            Write-Host "Removed empty bin directory"
        }
    }

    # Remove from PATH
    $path = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($path -like "*$scriptDir*") {
        $newPath = ($path -split ';' | Where-Object { $_ -ne $scriptDir }) -join ';'
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    }

    # Remove alias from profile
    if (Test-Path $profilePath) {
        $content = Get-Content $profilePath | Where-Object { $_ -notmatch "Set-Alias.*fmerge" }
        Set-Content -Path $profilePath -Value $content
    }

    Write-Host "Removal complete! Please restart your PowerShell window for changes to take effect."
}

# Check if running as administrator for PATH modifications
if (-not (Test-AdminPrivileges)) {
    Write-Warning "Some features require administrator privileges. Running with limited functionality."
}

# Execute requested action
switch ($Action) {
    "install" { Install-FileMerger }
    "remove" { Remove-FileMerger }
}