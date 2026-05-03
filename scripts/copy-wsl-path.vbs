' copy-wsl-path.vbs — Convert a Windows path to WSL path and copy to clipboard
' Usage: wscript.exe copy-wsl-path.vbs "C:\path\to\file"
' Typically invoked by the right-click context menu (CopyWslPath registry entry).

Set args = WScript.Arguments
If args.Count = 0 Then WScript.Quit 1

filePath = args(0)

' ── Path conversion: C:\foo\bar → /mnt/c/foo/bar ──
wslPath = Replace(filePath, "\", "/")
Dim re : Set re = New RegExp
re.Pattern = "^([A-Za-z]):"
wslPath = re.Replace(wslPath, "/mnt/$1")
wslPath = LCase(wslPath)

' UNC paths: \\server\share → //server/share
If Left(wslPath, 2) = "\\" Then wslPath = "/" & Mid(wslPath, 3)

' ── Copy to clipboard (zero-window via clip.exe) ──
Set fso = CreateObject("Scripting.FileSystemObject")
tempFile = fso.GetSpecialFolder(2) & "\wslpath.tmp"
Set f = fso.CreateTextFile(tempFile, True)
f.Write wslPath
f.Close

Set shell = CreateObject("WScript.Shell")
shell.Run "cmd /c clip < """ & tempFile & """ & del """ & tempFile & """", 0, True
