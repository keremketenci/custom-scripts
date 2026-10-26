@echo off
rem Called by service_custom_create.cmd and service_global_create.cmd, don't run it on its own.
rem Puts the chosen setting into PROFILE_ARGS and saves the choice to profile.txt (it becomes the default next time).
rem 1-2 are the fake TTLs known to work in Turkey (5: Turk Telekom and most providers, 7: Superonline),
rem 3 is -5 with its automatic TTL, the rest are the Superonline alternatives from GoodbyeDPI-Turkey's own scripts.
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
set "DNS=--dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253"
set "SEL=1"
if exist "%~dp0profile.txt" set /p SEL=<"%~dp0profile.txt"

:menu
echo.
echo %M_MENU1%
echo %M_MENU2%
echo.
if "%LNG%"=="tr" goto options_tr
echo   1) -5 --set-ttl 5 + DNS     (default, Turk Telekom and most providers)
echo   2) -5 --set-ttl 7 + DNS     (Superonline)
echo   3) -5 + DNS                 (automatic TTL, if neither TTL works)
echo   4) -5                       (Superonline alternative 2)
echo   5) --set-ttl 3              (Superonline alternative 1)
echo   6) --set-ttl 3 + DNS        (Superonline alternative 3)
echo   7) -9 + DNS                 (Superonline alternative 5)
echo   8) -9                       (Superonline alternative 6)
goto ask
:options_tr
echo   1) -5 --set-ttl 5 + DNS     (varsayilan, Turk Telekom ve cogu saglayici)
echo   2) -5 --set-ttl 7 + DNS     (Superonline)
echo   3) -5 + DNS                 (otomatik TTL, iki TTL de tutmazsa)
echo   4) -5                       (Superonline alternatif 2)
echo   5) --set-ttl 3              (Superonline alternatif 1)
echo   6) --set-ttl 3 + DNS        (Superonline alternatif 3)
echo   7) -9 + DNS                 (Superonline alternatif 5)
echo   8) -9                       (Superonline alternatif 6)

:ask
echo.
set "IN="
set /p "IN=%M_CHOICE% [%SEL%]: "
if defined IN set "SEL=%IN%"

set "PROFILE_ARGS="
if "%SEL%"=="1" set "PROFILE_ARGS=-5 --set-ttl 5 %DNS%"
if "%SEL%"=="2" set "PROFILE_ARGS=-5 --set-ttl 7 %DNS%"
if "%SEL%"=="3" set "PROFILE_ARGS=-5 %DNS%"
if "%SEL%"=="4" set "PROFILE_ARGS=-5"
if "%SEL%"=="5" set "PROFILE_ARGS=--set-ttl 3"
if "%SEL%"=="6" set "PROFILE_ARGS=--set-ttl 3 %DNS%"
if "%SEL%"=="7" set "PROFILE_ARGS=-9 %DNS%"
if "%SEL%"=="8" set "PROFILE_ARGS=-9"
if defined PROFILE_ARGS goto done
echo %M_INVALID% %SEL%
set "SEL=1"
goto menu

:done
>"%~dp0profile.txt" echo %SEL%
echo %M_SELECTED% %SEL%
exit /b
