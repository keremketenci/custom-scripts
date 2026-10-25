@echo off
rem Runs the setup without changing the PowerShell execution policy
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0DiscordScreenShareEchoFix.ps1"
pause
