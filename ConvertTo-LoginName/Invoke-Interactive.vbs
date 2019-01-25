RunPath = Replace( WScript.ScriptFullName, "\" & WScript.ScriptName, "" )

Set WshShell = WScript.CreateObject("WScript.Shell")

WshShell.Run "powershell.exe -File """ & RunPath & "\Invoke-Interactive.ps1""", 1