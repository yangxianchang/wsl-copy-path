' copy-wsl-path.vbs -- Convert a Windows path to WSL path and copy to clipboard

Set args = WScript.Arguments
If args.Count = 0 Then WScript.Quit 1

filePath = args(0)

' -- Path conversion: C:\foo\bar -> /mnt/c/foo/bar --
wslPath = Replace(filePath, "\", "/")
Dim re : Set re = New RegExp
re.Pattern = "^([A-Za-z]):"
wslPath = re.Replace(wslPath, "/mnt/$1")
wslPath = LCase(wslPath)

' UNC paths: \\server\share -> //server/share
If Left(wslPath, 2) = "\\" Then wslPath = "/" & Mid(wslPath, 3)

' -- Copy to clipboard via PowerShell (hidden, no flash) --
Set shell = CreateObject("WScript.Shell")
psCmd = "powershell -NoProfile -WindowStyle Hidden -Command " & _
    """Set-Clipboard -Value '" & Replace(wslPath, "'", "''") & "'"""
shell.Run psCmd, 0, True
