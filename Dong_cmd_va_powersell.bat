@echo off
title Dong CMD va PowerShell

echo Dang dong tat ca CMD / PowerShell / Windows Terminal...

REM Dong PowerShell truoc
taskkill /F /T /IM powershell.exe >nul 2>&1
taskkill /F /T /IM pwsh.exe >nul 2>&1

REM Dong Windows Terminal neu co
taskkill /F /T /IM WindowsTerminal.exe >nul 2>&1

REM Dong CMD cuoi cung vi file .bat dang chay bang cmd
taskkill /F /T /IM cmd.exe >nul 2>&1

exit