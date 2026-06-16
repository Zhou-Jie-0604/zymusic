Dim shell, appDir
Set shell = CreateObject("WScript.Shell")
appDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
shell.CurrentDirectory = appDir
shell.Run """" & appDir & "\启动.bat""", 7, False
