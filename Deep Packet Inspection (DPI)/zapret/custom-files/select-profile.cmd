@echo off
rem Called by service_custom_create.cmd and service_global_create.cmd, don't run it on its own.
rem Puts the chosen setting into PROFILE_ARGS and saves the choice to profile.txt (it becomes the default next time).
rem Only for web traffic (TCP 80/443), the Discord voice setting stays the same whatever is chosen.
rem Every option is a different method that worked in blockcheck.
rem Opened directly (double-click): explain how to change the setting instead
if defined DPI_CALLER goto main
set "LNG=en"
if exist "%~dp0language.txt" set /p LNG=<"%~dp0language.txt"
if /i "%LNG%"=="tr" goto standalone_tr
echo This file is used by the create scripts, don't open it directly.
echo To change the setting, run service_custom_create.cmd and pick another number.
pause
exit /b
:standalone_tr
echo Bu dosya create scriptleri tarafindan kullanilir, dogrudan acma.
echo Ayari degistirmek icin service_custom_create.cmd'yi calistirip baska bir numara sec.
pause
exit /b

:main
set "SEL=1"
if exist "%~dp0profile.txt" set /p SEL=<"%~dp0profile.txt"

:menu
echo.
echo %M_MENU1%
echo %M_MENU2%
echo.
if "%LNG%"=="tr" goto options_tr
echo   1) fake, TTL 7               (default)
echo   2) fake, automatic TTL       (if TTL 7 doesn't work)
echo   3) fake, md5sig
echo   4) fake, badseq
echo   5) hostfakesplit, md5sig
echo   6) multidisorder             (sends no fake packets)
goto ask
:options_tr
echo   1) fake, TTL 7               (varsayilan)
echo   2) fake, otomatik TTL        (TTL 7 tutmazsa)
echo   3) fake, md5sig
echo   4) fake, badseq
echo   5) hostfakesplit, md5sig
echo   6) multidisorder             (sahte paket gondermez)

:ask
echo.
set "IN="
set /p "IN=%M_CHOICE% [%SEL%]: "
if defined IN set "SEL=%IN%"

set "PROFILE_ARGS="
if "%SEL%"=="1" set "PROFILE_ARGS=--dpi-desync=fake --dpi-desync-ttl=7"
if "%SEL%"=="2" set "PROFILE_ARGS=--dpi-desync=fake --dpi-desync-ttl=1 --dpi-desync-autottl=-2"
if "%SEL%"=="3" set "PROFILE_ARGS=--dpi-desync=fake --dpi-desync-fooling=md5sig"
if "%SEL%"=="4" set "PROFILE_ARGS=--dpi-desync=fake --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=0"
if "%SEL%"=="5" set "PROFILE_ARGS=--dpi-desync=hostfakesplit --dpi-desync-fooling=md5sig"
if "%SEL%"=="6" set "PROFILE_ARGS=--dpi-desync=multidisorder --dpi-desync-split-pos=midsld --dpi-desync-split-seqovl=midsld-1"
if defined PROFILE_ARGS goto done
echo %M_INVALID% %SEL%
set "SEL=1"
goto menu

:done
>"%~dp0profile.txt" echo %SEL%
echo %M_SELECTED% %SEL%
exit /b
