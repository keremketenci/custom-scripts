@echo off
rem Re-launch as administrator if needed
fltmc >nul 2>&1
if not errorlevel 1 goto admin
echo Requesting administrator permission... / Yonetici izni isteniyor...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b
:admin

set "SVC=zapret-global"
set "DEST=%ProgramData%\zapret-global"

rem Messages in the saved language (chosen when the service was installed)
set "DPI_CALLER=1"
if not exist "%~dp0select-language.cmd" goto nolang
call "%~dp0select-language.cmd"

sc stop %SVC% >nul 2>&1
sc delete %SVC% >nul 2>&1
timeout /t 2 /nobreak >nul
rd /s /q "%DEST%" >nul 2>&1
if exist "%DEST%" goto rdfail

echo %M_GLOBAL_REMOVED%
goto end

:rdfail
echo %M_RD_FAIL%
goto end

:nolang
echo ERROR: select-language.cmd not found. Copy everything inside custom-files into this folder.
echo HATA: select-language.cmd bulunamadi. custom-files icindeki her seyi bu klasore kopyala.
pause
exit /b 1

:end
echo %M_PRESSKEY%
pause >nul
