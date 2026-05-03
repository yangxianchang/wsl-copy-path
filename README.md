# wsl-copy-path

Right-click any file or hit a hotkey after a screenshot — paste a WSL path into your terminal. No typing `/mnt/c/...` by hand.

## The Problem

You work in WSL2. You need to give a file path or a screenshot to Claude Code (or any terminal tool).

- Drag a file into the terminal → pastes `C:\Users\...` — WSL can't read that
- Copy an image from the clipboard → pastes nothing — terminals only accept text
- So you end up typing `/mnt/c/Users/you/...` by hand

## What This Does

Two things:

- **Right-click any file** → "Copy as WSL Path" — adds a context menu item in Explorer
- **Take a screenshot** → `Ctrl+Alt+P` — finds the newest screenshot, copies its WSL path

Both run silently. No terminal window pops up.

## Install

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Or right-click `install.ps1` → **Run with PowerShell**.

No dependencies. No admin rights needed.

## Usage

### Copy a file's WSL path

1. Right-click any file (image, PDF, folder, whatever)
2. Click **"Copy as WSL Path"**
3. Paste into your WSL terminal → `/mnt/c/Users/you/Documents/report.pdf`

### Copy the latest screenshot path

1. Take a screenshot (`Win+Shift+S` or `PrtSc`)
2. Press **`Ctrl+Alt+P`**
3. A balloon tip confirms the copy
4. Paste into your WSL terminal → `/mnt/c/Users/you/Pictures/Screenshots/screenshot.png`

## How It Works

Both features use the same mechanism:

1. A VBScript gets the Windows path (from the context menu argument, or by scanning the Screenshots folder)
2. Converts `C:\Users\...\file.png` → `/mnt/c/Users/.../file.png` (backslash to forward slash, drive letter to `/mnt/` prefix)
3. Pipes the result to `clip.exe` (built into Windows) which copies it to the clipboard

The VBScript runs via `wscript.exe` — the same host Windows uses for `.vbs` files — so no console window ever appears.

## Uninstall

```powershell
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

## Compatibility

- Windows 10 / 11
- WSL2 (any distro)
- Windows Terminal, VS Code integrated terminal, any WSL terminal

## Files

```
├── install.ps1                       # Adds context menu + hotkey shortcut
├── uninstall.ps1                     # Removes everything cleanly
└── scripts/
    ├── copy-wsl-path.vbs             # Context menu handler
    └── copy-latest-screenshot.vbs    # Hotkey handler
```

## License

MIT
