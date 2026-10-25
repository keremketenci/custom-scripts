@echo off
rem Re-launch as administrator if needed
fltmc >nul 2>&1
if not errorlevel 1 goto admin
echo Requesting administrator permission... / Yonetici izni isteniyor...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b
:admin

cd /d "%~dp0"
set "SVC=zapret-custom"
set "DEST=%ProgramData%\zapret-custom"
rem This folder without the trailing backslash
set "HERE=%~dp0"
set "HERE=%HERE:~0,-1%"

rem Language menu: sets LNG and all messages (M_*)
set "DPI_CALLER=1"
if not exist "%~dp0select-language.cmd" goto nolang
call "%~dp0select-language.cmd" ask

if not exist "%~dp0winws.exe" goto noexe
set "MISSING=files\list-custom.txt"
if not exist "%~dp0files\list-custom.txt" goto nofile
set "MISSING=select-profile.cmd"
if not exist "%~dp0select-profile.cmd" goto nofile

:pick
rem Settings menu: the chosen setting goes into PROFILE_ARGS
call "%~dp0select-profile.cmd"
rem Make sure this zapret version accepts the setting before any service is touched
set "BASE=%HERE%"
set Q="
call :buildargs
"%~dp0winws.exe" --dry-run %ARGS% >nul 2>&1
if not errorlevel 1 goto accepted
echo.
echo %M_BADPROFILE1%
echo %M_BADPROFILE2%
goto pick
:accepted

rem Only one custom service at a time: fully remove GoodbyeDPI's custom service and the ones from older GoodbyeDPI scripts
call :removesvc goodbyedpi-custom "%ProgramData%\goodbyedpi-custom"
call :removesvc GoodbyeDPI
call :removesvc GoodbyeDPI-discord

sc stop %SVC% >nul 2>&1
sc delete %SVC% >nul 2>&1
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
rem Wildcards instead of exact names, so versions that ship different DLLs or drivers still work.
robocopy "%~dp0." "%DEST%" winws.exe *.dll *.sys /R:1 /W:1 >nul
if errorlevel 8 goto copyfail
robocopy "%~dp0files" "%DEST%\files" list-custom.txt /R:1 /W:1 >nul
if errorlevel 8 goto copyfail
if not exist "%~dp0windivert.filter\" goto copied
robocopy "%~dp0windivert.filter" "%DEST%\windivert.filter" /E /R:1 /W:1 >nul
if errorlevel 8 goto copyfail
:copied
if not exist "%DEST%\winws.exe" goto copyfail

set "BASE=%DEST%"
set Q=\"
call :buildargs

sc create %SVC% binPath= "\"%DEST%\winws.exe\" %ARGS%" start= auto DisplayName= "zapret-custom" >nul
if errorlevel 1 goto createfail
sc description %SVC% "zapret - only the sites in list-custom.txt + Discord voice" >nul
sc start %SVC% >nul
if errorlevel 1 goto startfail
rem Make sure it's still running a few seconds later (an antivirus may kill it)
timeout /t 3 /nobreak >nul
sc query %SVC% | find "RUNNING" >nul
if errorlevel 1 goto startfail

echo.
echo %M_INSTALLED%
if not defined HASVOICE echo %M_NOVOICE%
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

:startfail
echo %M_STARTFAIL1%
echo %M_STARTFAIL2%
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

rem Builds ARGS from BASE (folder with the zapret files) and Q (" to run winws directly, \" inside the sc binPath).
rem 1st profile: the sites in the list (TCP 80/443) with the chosen setting
rem 2nd profile: Discord voice (UDP). Voice traffic has no site name, so it can't be matched by the list.
rem Filter files missing from this zapret version are skipped.
:buildargs
set "HASVOICE="
set ARGS=--wf-tcp=80,443
if exist "%BASE%\windivert.filter\windivert_part.discord_media.txt" set "HASVOICE=1"
if exist "%BASE%\windivert.filter\windivert_part.discord_media.txt" set ARGS=%ARGS% --wf-raw-part=@%Q%%BASE%\windivert.filter\windivert_part.discord_media.txt%Q%
if exist "%BASE%\windivert.filter\windivert_part.stun.txt" set ARGS=%ARGS% --wf-raw-part=@%Q%%BASE%\windivert.filter\windivert_part.stun.txt%Q%
set ARGS=%ARGS% --filter-tcp=80,443 --hostlist=%Q%%BASE%\files\list-custom.txt%Q% %PROFILE_ARGS% --new --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=2
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
