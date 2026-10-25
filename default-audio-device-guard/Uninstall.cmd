@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0DefaultAudioDeviceGuard.ps1" -Uninstall
pause
