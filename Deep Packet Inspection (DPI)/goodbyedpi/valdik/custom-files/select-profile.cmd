@echo off
rem Called by service_custom_create.cmd and service_global_create.cmd, don't run it on its own.
rem Puts the chosen setting into PROFILE_ARGS and saves the choice to profile.txt (it becomes the default next time).
rem Only uses modes -1 ... -6, which every GoodbyeDPI version since 0.2.2 supports.
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
echo   1) -5 + DNS                 (default)
echo   2) -5 --set-ttl 5 + DNS     (recommended for Turkey)
echo   3) -6 + DNS                 (fake packet with wrong sequence number)
echo   4) --set-ttl 3 + DNS
echo   5) -1 + DNS                 (old, most compatible mode)
echo   6) -5                       (no DNS redirect)
goto ask
:options_tr
echo   1) -5 + DNS                 (varsayilan)
echo   2) -5 --set-ttl 5 + DNS     (Turkiye icin onerilen)
echo   3) -6 + DNS                 (yanlis sira numarali sahte paket)
echo   4) --set-ttl 3 + DNS
echo   5) -1 + DNS                 (eski, en uyumlu mod)
echo   6) -5                       (DNS yonlendirme yok)

:ask
echo.
set "IN="
set /p "IN=%M_CHOICE% [%SEL%]: "
if defined IN set "SEL=%IN%"

set "PROFILE_ARGS="
if "%SEL%"=="1" set "PROFILE_ARGS=-5 %DNS%"
if "%SEL%"=="2" set "PROFILE_ARGS=-5 --set-ttl 5 %DNS%"
if "%SEL%"=="3" set "PROFILE_ARGS=-6 %DNS%"
if "%SEL%"=="4" set "PROFILE_ARGS=--set-ttl 3 %DNS%"
if "%SEL%"=="5" set "PROFILE_ARGS=-1 %DNS%"
if "%SEL%"=="6" set "PROFILE_ARGS=-5"
if defined PROFILE_ARGS goto done
echo %M_INVALID% %SEL%
set "SEL=1"
goto menu

:done
>"%~dp0profile.txt" echo %SEL%
echo %M_SELECTED% %SEL%
exit /b
