' copy-latest-screenshot.vbs — Copy WSL path of the newest screenshot to clipboard
' Intended to be bound to Ctrl+Alt+P (or any hotkey) via a Desktop shortcut.
' The shortcut's Target should be: wscript.exe "path\to\this\script"
'
' Screenshots are expected in %USERPROFILE%\Pictures\Screenshots
' (Windows 11 Snipping Tool / Win+Shift+S auto-save location).

Set fso   = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

screenDir = shell.ExpandEnvironmentStrings("%USERPROFILE%") & "\Pictures\Screenshots"

If Not fso.FolderExists(screenDir) Then WScript.Quit 1

' ── Scan for the newest .png file ──
Set folder    = fso.GetFolder(screenDir)
newest        = ""
newestTime    = CDate("1900-01-01")

For Each file In folder.Files
    If LCase(fso.GetExtensionName(file.Path)) = "png" Then
        If file.DateCreated > newestTime Then
            newestTime = file.DateCreated
            newest     = file.Path
        End If
    End If
Next

If newest = "" Then WScript.Quit 1

' ── Windows path → WSL path ──
wslPath = Replace(newest, "\", "/")
Dim re : Set re = New RegExp
re.Pattern = "^([A-Za-z]):"
wslPath = re.Replace(wslPath, "/mnt/$1")
wslPath = LCase(wslPath)

' ── Copy to clipboard ──
tempFile = fso.GetSpecialFolder(2) & "\wslpath.tmp"
Set f = fso.CreateTextFile(tempFile, True)
f.Write wslPath
f.Close

shell.Run "cmd /c clip < """ & tempFile & """ & del """ & tempFile & """", 0, True

' ── Balloon notification (async, non-blocking) ──
shell.Run "powershell -NoProfile -WindowStyle Hidden -Command " & _
    """Add-Type -AssemblyName System.Windows.Forms; " & _
    "Add-Type -AssemblyName System.Drawing; " & _
    "$b = New-Object System.Windows.Forms.NotifyIcon; " & _
    "$b.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon('C:\Windows\System32\wsl.exe'); " & _
    "$b.BalloonTipIcon = 'Info'; " & _
    "$b.BalloonTipTitle = 'Copy Latest Screenshot'; " & _
    "$b.BalloonTipText = 'Latest screenshot copied as WSL path'; " & _
    "$b.Visible = $true; " & _
    "$b.ShowBalloonTip(3000); " & _
    "Start-Sleep 3; " & _
    "$b.Dispose()""", 0, False
