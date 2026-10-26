@echo off
rem Called by service_custom_create.cmd and service_global_create.cmd, don't run it on its own.
rem Puts the chosen setting into PROFILE_ARGS and saves the choice to profile.txt (it becomes the default next time).
rem Only for web traffic (TCP 80/443), the Discord voice setting stays the same whatever is chosen.
rem 1-2 are the fake TTLs known to work in Turkey (5: Turk Telekom and most providers, 7: Superonline),
rem the rest are other methods that worked in blockcheck.
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
echo   1) fake, TTL 5               (default, Turk Telekom and most providers)
echo   2) fake, TTL 7               (Superonline)
echo   3) fake, automatic TTL       (if neither TTL works)
echo   4) fake, md5sig
echo   5) fake, badseq
echo   6) hostfakesplit, md5sig
echo   7) multidisorder             (sends no fake packets)
goto ask
:options_tr
echo   1) fake, TTL 5               (varsayilan, Turk Telekom ve cogu saglayici)
echo   2) fake, TTL 7               (Superonline)
echo   3) fake, otomatik TTL        (iki TTL de tutmazsa)
echo   4) fake, md5sig
echo   5) fake, badseq
echo   6) hostfakesplit, md5sig
echo   7) multidisorder             (sahte paket gondermez)

:ask
echo.
set "IN="
set /p "IN=%M_CHOICE% [%SEL%]: "
if defined IN set "SEL=%IN%"

set "PROFILE_ARGS="
if "%SEL%"=="1" set "PROFILE_ARGS=--dpi-desync=fake --dpi-desync-ttl=5"
if "%SEL%"=="2" set "PROFILE_ARGS=--dpi-desync=fake --dpi-desync-ttl=7"
if "%SEL%"=="3" set "PROFILE_ARGS=--dpi-desync=fake --dpi-desync-ttl=1 --dpi-desync-autottl=-2"
if "%SEL%"=="4" set "PROFILE_ARGS=--dpi-desync=fake --dpi-desync-fooling=md5sig"
if "%SEL%"=="5" set "PROFILE_ARGS=--dpi-desync=fake --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=0"
if "%SEL%"=="6" set "PROFILE_ARGS=--dpi-desync=hostfakesplit --dpi-desync-fooling=md5sig"
if "%SEL%"=="7" set "PROFILE_ARGS=--dpi-desync=multidisorder --dpi-desync-split-pos=midsld --dpi-desync-split-seqovl=midsld-1"
if defined PROFILE_ARGS goto done
echo %M_INVALID% %SEL%
set "SEL=1"
goto menu

:done
>"%~dp0profile.txt" echo %SEL%
echo %M_SELECTED% %SEL%
exit /b
