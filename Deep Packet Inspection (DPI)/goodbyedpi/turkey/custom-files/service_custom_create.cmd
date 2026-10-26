@echo off
rem Re-launch as administrator if needed
fltmc >nul 2>&1
if not errorlevel 1 goto admin
echo Requesting administrator permission... / Yonetici izni isteniyor...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b
:admin

cd /d "%~dp0"
set "SVC=goodbyedpi-custom"
set "DEST=%ProgramData%\goodbyedpi-custom"

set "ARCH=x86"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "ARCH=x86_64"
if defined PROCESSOR_ARCHITEW6432 set "ARCH=x86_64"

rem Language menu: sets LNG and all messages (M_*)
set "DPI_CALLER=1"
if not exist "%~dp0select-language.cmd" goto nolang
call "%~dp0select-language.cmd" ask

rem Find goodbyedpi.exe next to this script, or one folder down (some release zips extract into a subfolder)
set "SRC="
if exist "%~dp0%ARCH%\goodbyedpi.exe" set "SRC=%~dp0%ARCH%"
if not defined SRC for /d %%D in ("%~dp0*") do if exist "%%~D\%ARCH%\goodbyedpi.exe" set "SRC=%%~D\%ARCH%"
if not defined SRC goto noexe
set "MISSING=list-custom.txt"
if not exist "%~dp0list-custom.txt" goto nofile
set "MISSING=select-profile.cmd"
if not exist "%~dp0select-profile.cmd" goto nofile
set "MISSING=service_custom_remove.cmd"
if not exist "%~dp0service_custom_remove.cmd" goto nofile

rem Settings menu: the chosen setting goes into PROFILE_ARGS
call "%~dp0select-profile.cmd"

rem Only one custom service at a time: fully remove zapret's custom service and the ones from older scripts
call :removesvc zapret-custom "%ProgramData%\zapret-custom"
call :removesvc GoodbyeDPI
call :removesvc GoodbyeDPI-discord

sc stop %SVC% >nul 2>&1
sc delete %SVC% >nul 2>&1
rem A previous GoodbyeDPI 0.2.2 install leaves its WinDivert 1.4 driver loaded, locking the files we're about to overwrite
sc stop WinDivert1.4 >nul 2>&1
rem Wait until the service is fully deleted (max 10 s), otherwise sc create fails
set /a N=0
:waitdel
sc query %SVC% >nul 2>&1
if errorlevel 1 goto deleted
set /a N+=1
if %N% geq 10 goto deleted
timeout /t 1 /nobreak >nul
goto waitdel
:deleted

rem Copy the files to a fixed place so the service keeps working even if this folder is moved or deleted.
rem Wildcards instead of exact names, so versions that ship different WinDivert files still work.
robocopy "%SRC%" "%DEST%" goodbyedpi.exe *.dll /R:1 /W:1 >nul
if errorlevel 8 goto copyfail
rem The WinDivert driver stays loaded until restart and locks its .sys file in %DEST%, so copy a .sys only if it differs.
for %%F in ("%SRC%\*.sys") do (
  fc /b "%%~fF" "%DEST%\%%~nxF" >nul 2>&1 || copy /y "%%~fF" "%DEST%\" >nul 2>&1 || goto driverlocked
)
robocopy "%~dp0." "%DEST%" list-custom.txt /R:1 /W:1 >nul
if errorlevel 8 goto copyfail
if not exist "%DEST%\goodbyedpi.exe" goto copyfail
rem An uninstaller next to the service, so it can be removed even if this folder is deleted
copy /y "%~dp0service_custom_remove.cmd" "%DEST%\uninstall.cmd" >nul
copy /y "%~dp0select-language.cmd" "%DEST%\" >nul
if exist "%~dp0language.txt" copy /y "%~dp0language.txt" "%DEST%\" >nul

rem Chosen setting, only for the sites in the list
set ARGS=%PROFILE_ARGS% --blacklist \"%DEST%\list-custom.txt\"

sc create %SVC% binPath= "\"%DEST%\goodbyedpi.exe\" %ARGS%" start= auto DisplayName= "goodbyedpi-custom" >nul
if errorlevel 1 goto createfail
sc description %SVC% "GoodbyeDPI - only the sites in list-custom.txt" >nul
sc start %SVC% >nul
if errorlevel 1 goto startfail
rem GoodbyeDPI exits right away if it doesn't accept a setting, so make sure it's still running
timeout /t 3 /nobreak >nul
sc query %SVC% | find "RUNNING" >nul
if errorlevel 1 goto startfail

echo.
echo %M_INSTALLED%
goto end

:nolang
echo ERROR: select-language.cmd not found. Copy everything inside custom-files into this folder.
echo HATA: select-language.cmd bulunamadi. custom-files icindeki her seyi bu klasore kopyala.
pause
exit /b 1

:noexe
echo %M_NOEXE1%
echo %M_NOEXE2%
goto fail

:nofile
echo %M_NOFILE% %MISSING%
goto fail

:driverlocked
echo %M_DRIVERLOCKED1%
echo %M_DRIVERLOCKED2%
goto fail

:copyfail
echo %M_COPYFAIL1%
echo %M_COPYFAIL2%
goto fail

:createfail
echo %M_CREATEFAIL%
goto fail

:startfail
echo %M_STARTFAIL1%
echo %M_STARTFAIL2%
echo %M_STARTFAIL3%
goto fail

:fail
echo.
echo %M_PRESSKEY%
pause >nul
exit /b 1

:end
echo %M_PRESSKEY%
pause >nul
exit /b

rem Usage: call :removesvc <service> [folder]
:removesvc
sc query %1 >nul 2>&1
if errorlevel 1 exit /b
echo %M_REMOVING% %1
sc stop %1 >nul 2>&1
sc delete %1 >nul 2>&1
rem GoodbyeDPI 0.2.2's WinDivert 1.4 driver stays loaded and locks its folder; no other tool uses it, so stop it
sc stop WinDivert1.4 >nul 2>&1
timeout /t 2 /nobreak >nul
if not "%~2"=="" rd /s /q "%~2" >nul 2>&1
exit /b
