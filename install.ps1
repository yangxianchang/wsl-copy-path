# install.ps1 — One-click installer for wsl-copy-path
# Run: powershell -ExecutionPolicy Bypass -File install.ps1
# Or:  Right-click install.ps1 → "Run with PowerShell"

$ErrorActionPreference = "Stop"

# ── Paths ──
$scriptDir     = Split-Path -Parent $MyInvocation.MyCommand.Path
$targetDir     = "$env:USERPROFILE\Scripts"
$shortcutPath  = "$env:USERPROFILE\Desktop\Copy Latest Screenshot.lnk"
$vbsContext    = "copy-wsl-path.vbs"
$vbsHotkey     = "copy-latest-screenshot.vbs"

Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   wsl-copy-path — Installer                  ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── 1. Create target directory ──
Write-Host "[1/4] Creating $targetDir ..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

# ── 2. Copy VBS scripts ──
Write-Host "[2/4] Installing scripts ..." -ForegroundColor Yellow
Copy-Item -Path "$scriptDir\scripts\$vbsContext" -Destination "$targetDir\$vbsContext" -Force
Copy-Item -Path "$scriptDir\scripts\$vbsHotkey"  -Destination "$targetDir\$vbsHotkey"  -Force
Write-Host "       $targetDir\$vbsContext" -ForegroundColor Green
Write-Host "       $targetDir\$vbsHotkey"  -ForegroundColor Green

# ── 3. Import registry (context menu) ──
Write-Host "[3/4] Adding 'Copy as WSL Path' to context menu ..." -ForegroundColor Yellow

$regContent = @"
Windows Registry Editor Version 5.00

; Copy as WSL Path — All files
[HKEY_CLASSES_ROOT\*\shell\CopyWslPath]
@="Copy as WSL Path"
"Icon"="C:\\Windows\\System32\\wsl.exe,0"

[HKEY_CLASSES_ROOT\*\shell\CopyWslPath\command]
@="wscript.exe \"$($targetDir.Replace('\', '\\'))\\$vbsContext\" \"%1\""

; Copy as WSL Path — Folders
[HKEY_CLASSES_ROOT\Directory\shell\CopyWslPath]
@="Copy as WSL Path"
"Icon"="C:\\Windows\\System32\\wsl.exe,0"

[HKEY_CLASSES_ROOT\Directory\shell\CopyWslPath\command]
@="wscript.exe \"$($targetDir.Replace('\', '\\'))\\$vbsContext\" \"%V\""

; Copy as WSL Path — Folder background
[HKEY_CLASSES_ROOT\Directory\Background\shell\CopyWslPath]
@="Copy as WSL Path"
"Icon"="C:\\Windows\\System32\\wsl.exe,0"

[HKEY_CLASSES_ROOT\Directory\Background\shell\CopyWslPath\command]
@="wscript.exe \"$($targetDir.Replace('\', '\\'))\\$vbsContext\" \"%V\""
"@

$tempReg = "$env:TEMP\wsl-copy-path-install.reg"
$regContent | Out-File -FilePath $tempReg -Encoding ASCII
reg import $tempReg | Out-Null
Remove-Item $tempReg
Write-Host "       Context menu registered" -ForegroundColor Green

# ── 4. Create desktop shortcut with Ctrl+Alt+P hotkey ──
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

# ── Done ──
Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Installation complete!                     ║" -ForegroundColor Cyan
Write-Host "╠══════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║                                              ║" -ForegroundColor Cyan
Write-Host "║   Right-click any file  → Copy as WSL Path   ║" -ForegroundColor Cyan
Write-Host "║   Screenshot then press → Ctrl+Alt+P         ║" -ForegroundColor Cyan
Write-Host "║                                              ║" -ForegroundColor Cyan
Write-Host "║   To uninstall: run uninstall.ps1            ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
