@echo off
rem Re-launch as administrator if needed
fltmc >nul 2>&1
if not errorlevel 1 goto admin
echo Requesting administrator permission... / Yonetici izni isteniyor...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b
:admin

cd /d "%~dp0"
set "SVC=goodbyedpi-global"
set "DEST=%ProgramData%\goodbyedpi-global"

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
set "MISSING=select-profile.cmd"
if not exist "%~dp0select-profile.cmd" goto nofile

rem Settings menu: the chosen setting goes into PROFILE_ARGS
call "%~dp0select-profile.cmd"

rem Only one global service at a time: fully remove zapret's global service
call :removesvc zapret-global "%ProgramData%\zapret-global"

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
robocopy "%SRC%" "%DEST%" goodbyedpi.exe *.dll *.sys /R:1 /W:1 >nul
if errorlevel 8 goto copyfail
if not exist "%DEST%\goodbyedpi.exe" goto copyfail

rem Chosen setting, all sites
set ARGS=%PROFILE_ARGS%

sc create %SVC% ^
binPath= "\"%DEST%\goodbyedpi.exe\" %ARGS%" ^
DisplayName= "goodbyedpi-global" ^
start= demand >nul
if errorlevel 1 goto createfail
sc description %SVC% "GoodbyeDPI - all traffic, started with run-goodbyedpi-global.bat" >nul

echo.
echo %M_GLOBAL_CREATED%
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

:copyfail
echo %M_COPYFAIL1%
echo %M_COPYFAIL2%
goto fail

:createfail
echo %M_CREATEFAIL%
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
