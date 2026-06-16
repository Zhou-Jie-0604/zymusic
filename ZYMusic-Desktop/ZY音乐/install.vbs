Set fso = CreateObject("Scripting.FileSystemObject")
appDir = fso.GetParentFolderName(WScript.ScriptFullName)

Set shell = CreateObject("WScript.Shell")
desktopPath = shell.SpecialFolders("Desktop")
shortcutPath = desktopPath & "\ZYmusic.lnk"

Set shortcut = shell.CreateShortcut(shortcutPath)
shortcut.TargetPath = appDir & "\launcher.vbs"
shortcut.WorkingDirectory = appDir
If fso.FileExists(appDir & "\icon.ico") Then
    shortcut.IconLocation = appDir & "\icon.ico"
End If
shortcut.Description = "ZYmusic"
shortcut.Save()

MsgBox "Done! ZYmusic shortcut is on your Desktop.", 64, "ZYmusic"
