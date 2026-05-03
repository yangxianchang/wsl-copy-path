# uninstall.ps1 — Remove wsl-copy-path from the system
# Run: powershell -ExecutionPolicy Bypass -File uninstall.ps1

Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   wsl-copy-path — Uninstaller                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$targetDir    = "$env:USERPROFILE\Scripts"
$shortcutPath = "$env:USERPROFILE\Desktop\Copy Latest Screenshot.lnk"

# ── 1. Remove context menu registry entries ──
Write-Host "[1/3] Removing context menu entries ..." -ForegroundColor Yellow
reg delete "HKEY_CLASSES_ROOT\*\shell\CopyWslPath"              /f 2>$null
reg delete "HKEY_CLASSES_ROOT\Directory\shell\CopyWslPath"      /f 2>$null
reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\CopyWslPath" /f 2>$null
Write-Host "       Removed" -ForegroundColor Green

# ── 2. Remove desktop shortcut ──
Write-Host "[2/3] Removing desktop shortcut ..." -ForegroundColor Yellow
if (Test-Path $shortcutPath) {
    Remove-Item $shortcutPath -Force
    Write-Host "       Removed" -ForegroundColor Green
} else {
    Write-Host "       Not found (already removed?)" -ForegroundColor Gray
}

# ── 3. Remove scripts ──
Write-Host "[3/3] Removing scripts ..." -ForegroundColor Yellow
$vbs1 = "$targetDir\copy-wsl-path.vbs"
$vbs2 = "$targetDir\copy-latest-screenshot.vbs"

if (Test-Path $vbs1) { Remove-Item $vbs1 -Force; Write-Host "       Removed $vbs1" -ForegroundColor Green }
if (Test-Path $vbs2) { Remove-Item $vbs2 -Force; Write-Host "       Removed $vbs2" -ForegroundColor Green }

# ── Done ──
Write-Host ""
Write-Host "Uninstall complete." -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: If %USERPROFILE%\Scripts\ is now empty, you may delete it manually." -ForegroundColor Gray
