@echo off
rem Re-launch as administrator if needed
fltmc >nul 2>&1
if not errorlevel 1 goto admin
echo Requesting administrator permission... / Yonetici izni isteniyor...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b
:admin

set "SVC=goodbyedpi-custom"
set "DEST=%ProgramData%\goodbyedpi-custom"
set "TMPDIR=%TEMP%\goodbyedpi-custom-uninstall"

rem The create script copies this file to %DEST% as uninstall.cmd. Opened from there, run a temp copy instead,
rem a batch file can't delete the folder it runs from.
if /i not "%~dp0"=="%DEST%\" goto start
rd /s /q "%TMPDIR%" >nul 2>&1
md "%TMPDIR%"
copy /y "%~f0" "%TMPDIR%\" >nul
copy /y "%~dp0select-language.cmd" "%TMPDIR%\" >nul
if exist "%~dp0language.txt" copy /y "%~dp0language.txt" "%TMPDIR%\" >nul
cd /d "%TEMP%"
start "" cmd /c ""%TMPDIR%\%~nx0""
exit /b
:start

rem Messages in the saved language (chosen when the service was installed)
set "DPI_CALLER=1"
if not exist "%~dp0select-language.cmd" goto nolang
call "%~dp0select-language.cmd"

sc stop %SVC% >nul 2>&1
sc delete %SVC% >nul 2>&1
rem GoodbyeDPI 0.2.2 uses the old WinDivert 1.4 driver that no other tool uses; stop it so the folder can be deleted
sc stop WinDivert1.4 >nul 2>&1
timeout /t 2 /nobreak >nul
rd /s /q "%DEST%" >nul 2>&1
if exist "%DEST%" goto rdfail

echo %M_CUSTOM_REMOVED%
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
rem Running from the temp copy: delete it too once this script has ended
if /i not "%~dp0"=="%TMPDIR%\" exit /b
(goto) 2>nul & rd /s /q "%TMPDIR%"
