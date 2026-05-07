# install.ps1 -- One-click installer for wsl-copy-path
# Run: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"

# -- Paths --
$scriptDir     = Split-Path -Parent $MyInvocation.MyCommand.Path
$targetDir     = "$env:USERPROFILE\Scripts"
$shortcutPath  = "$env:USERPROFILE\Desktop\Copy Latest Screenshot.lnk"
$vbsContext    = "copy-wsl-path.vbs"
$vbsHotkey     = "copy-latest-screenshot.vbs"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  wsl-copy-path -- Installer" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# -- 1. Create target directory --
Write-Host "[1/4] Creating $targetDir ..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

# -- 2. Copy VBS scripts --
Write-Host "[2/4] Installing scripts ..." -ForegroundColor Yellow
Copy-Item -Path "$scriptDir\scripts\$vbsContext" -Destination "$targetDir\$vbsContext" -Force
Copy-Item -Path "$scriptDir\scripts\$vbsHotkey"  -Destination "$targetDir\$vbsHotkey"  -Force
Write-Host "       $targetDir\$vbsContext" -ForegroundColor Green
Write-Host "       $targetDir\$vbsHotkey"  -ForegroundColor Green

# -- 3. Add context menu entries via direct registry writes --
Write-Host "[3/4] Adding 'Copy as WSL Path' to context menu ..." -ForegroundColor Yellow

# Write to HKCU (per-user) to avoid admin/UAC prompt
$hkcrRoot = "Registry::HKEY_CURRENT_USER\Software\Classes"

function Add-ContextMenuEntry {
    param(
        [string]$RegPath,
        [string]$Label,
        [string]$CommandArgs
    )

    $keyPath = "$hkcrRoot\$RegPath\shell\CopyWslPath"
    New-Item -Path $keyPath -Force | Out-Null
    New-ItemProperty -Path $keyPath -Name "(default)" -Value $Label -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $keyPath -Name "Icon" -Value "C:\Windows\System32\wsl.exe,0" -PropertyType String -Force | Out-Null

    $cmdPath = "$keyPath\command"
    New-Item -Path $cmdPath -Force | Out-Null
    $command = "C:\Windows\System32\wscript.exe `"$targetDir\$vbsContext`" `"$CommandArgs`""
    New-ItemProperty -Path $cmdPath -Name "(default)" -Value $command -PropertyType String -Force | Out-Null
}

Add-ContextMenuEntry -RegPath "*"                   -Label "Copy as WSL Path" -CommandArgs "%1"
Add-ContextMenuEntry -RegPath "Directory"            -Label "Copy as WSL Path" -CommandArgs "%V"
Add-ContextMenuEntry -RegPath "Directory\Background" -Label "Copy as WSL Path" -CommandArgs "%V"

Write-Host "       Context menu registered" -ForegroundColor Green

# -- 4. Create desktop shortcut with Ctrl+Alt+P hotkey --
Write-Host "[4/4] Creating Ctrl+Alt+P hotkey shortcut ..." -ForegroundColor Yellow

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath       = "wscript.exe"
$Shortcut.Arguments        = "`"$targetDir\$vbsHotkey`""
$Shortcut.Hotkey           = "Ctrl+Alt+P"
$Shortcut.WorkingDirectory = $targetDir
$Shortcut.WindowStyle      = 7
$Shortcut.IconLocation     = "C:\Windows\System32\wsl.exe,0"
$Shortcut.Save()
Write-Host "       $shortcutPath" -ForegroundColor Green

# -- Done --
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Installation complete!" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Right-click any file  -> Copy as WSL Path" -ForegroundColor Cyan
Write-Host "  Screenshot then press -> Ctrl+Alt+P" -ForegroundColor Cyan
Write-Host ""
Write-Host "  To uninstall: run uninstall.ps1" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to close this window"
