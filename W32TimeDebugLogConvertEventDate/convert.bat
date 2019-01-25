@echo off
setlocal

:var
set runpath=%~dp0
set runpath=%runpath:~0,-1%

:begin
"powershell.exe" -ExecutionPolicy UnRestricted -NoLogo -File "%runpath%\convert.ps1"
pause

:exit
endlocal & exit /b %ERRORLEVEL%