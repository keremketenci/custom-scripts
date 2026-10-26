@echo off
rem Sets LNG (en/tr) and every message the scripts show (M_*).
rem "call select-language.cmd ask" shows the language menu, without "ask" the saved language is used.
rem The choice is saved to language.txt. English is the default.
rem Callers set DPI_CALLER=1 and call it after SVC and DEST are set, some messages use them.
rem Opened directly (double-click), it just lets the user change the saved language.
set "LNG=en"
if exist "%~dp0language.txt" set /p LNG=<"%~dp0language.txt"
if /i not "%LNG%"=="tr" set "LNG=en"
if not defined DPI_CALLER goto standalone
if /i "%~1"=="ask" call :choose
goto apply

:standalone
call :choose
echo.
if "%LNG%"=="tr" goto standalone_tr
echo Language saved: English. The scripts will use it from now on.
echo To install, run service_custom_create.cmd or service_global_create.cmd.
pause
exit /b
:standalone_tr
echo Dil kaydedildi: Turkce. Scriptler bundan sonra bunu kullanacak.
echo Kurmak icin service_custom_create.cmd veya service_global_create.cmd'yi calistir.
pause
exit /b

:choose
set "DEF=1"
if "%LNG%"=="tr" set "DEF=2"
echo.
echo Language / Dil:
echo   1) English
echo   2) Turkce
set "IN="
set /p "IN=[%DEF%]: "
if "%IN%"=="1" set "LNG=en"
if "%IN%"=="2" set "LNG=tr"
>"%~dp0language.txt" echo %LNG%
exit /b

:apply
if "%LNG%"=="tr" goto tr

set "M_MENU1=Which setting should be used? If you're not sure, just press Enter."
set "M_MENU2=If a site still won't open, run the create script again and try the next number."
set "M_CHOICE=Choice"
set "M_INVALID=Invalid choice:"
set "M_SELECTED=Selected setting:"
set "M_BADPROFILE1=This zapret version doesn't accept the chosen setting. Pick another one."
set "M_BADPROFILE2=If it accepts none of them, use the zapret-win-bundle-master that came with this package."
set "M_REMOVING=Removing a service, only one DPI tool can run at a time:"
set "M_INSTALLED=Installed."
set "M_GLOBAL_CREATED=Zapret Global service created."
set "M_CUSTOM_REMOVED=Zapret Custom service removed."
set "M_GLOBAL_REMOVED=Zapret Global service removed."
set "M_RD_FAIL=The service was removed, but the %DEST% folder couldn't be deleted. Restart the PC and delete it manually."
set "M_NOVOICE=WARNING: This zapret version has no windivert_part.discord_media.txt, so Discord voice may not work."
set "M_NOEXE1=ERROR: winws.exe not found."
set "M_NOEXE2=Copy everything inside custom-files into zapret-win-bundle-master\zapret-winws. If your zapret version no longer has winws.exe, use the zapret-win-bundle-master that came with this package."
set "M_NOFILE=ERROR: A file is missing. Copy everything inside custom-files into this folder:"
set "M_COPYFAIL1=ERROR: Couldn't copy the files to %DEST%."
set "M_COPYFAIL2=Close any open zapret windows and try again."
set "M_DRIVERLOCKED1=ERROR: The WinDivert driver of the previous install is still loaded, so its file can't be replaced with this version."
set "M_DRIVERLOCKED2=Restart the PC and run this again."
set "M_CREATEFAIL=ERROR: Couldn't create the service. If services.msc is open, close it and try again."
set "M_STARTFAIL1=ERROR: The service was created but isn't running."
set "M_STARTFAIL2= - Your antivirus may have blocked winws.exe or WinDivert. Add %DEST% to its exclusions."
set "M_ERRCODE=error"
set "M_DRIVERFAIL1= - The WinDivert driver couldn't be loaded, this isn't an antivirus problem."
set "M_DRIVERFAIL2= - Restart the PC and run this again. If it keeps happening, another DPI tool or an anti-cheat may be blocking WinDivert."
set "M_PRESSKEY=Press any key to close this window."
exit /b

:tr
set "M_MENU1=Hangi ayar kullanilsin? Bilmiyorsan Enter'a bas."
set "M_MENU2=Site acilmazsa create dosyasini tekrar calistirip siradaki numarayi dene."
set "M_CHOICE=Secim"
set "M_INVALID=Gecersiz secim:"
set "M_SELECTED=Secilen ayar:"
set "M_BADPROFILE1=Bu zapret surumu secilen ayari kabul etmiyor. Baska bir ayar sec."
set "M_BADPROFILE2=Hicbirini kabul etmiyorsa bu paketle gelen zapret-win-bundle-master'i kullan."
set "M_REMOVING=Servis kaldiriliyor, ayni anda tek DPI araci calisabilir:"
set "M_INSTALLED=Kuruldu."
set "M_GLOBAL_CREATED=Zapret Global servisi olusturuldu."
set "M_CUSTOM_REMOVED=Zapret Custom servisi kaldirildi."
set "M_GLOBAL_REMOVED=Zapret Global servisi kaldirildi."
set "M_RD_FAIL=Servis kaldirildi ama %DEST% klasoru silinemedi. PC'yi yeniden baslatip elle silebilirsin."
set "M_NOVOICE=UYARI: Bu zapret surumunde windivert_part.discord_media.txt yok, Discord sesli sohbet calismayabilir."
set "M_NOEXE1=HATA: winws.exe bulunamadi."
set "M_NOEXE2=custom-files icindeki her seyi zapret-win-bundle-master\zapret-winws klasorune kopyala. Zapret surumunde artik winws.exe yoksa bu paketle gelen zapret-win-bundle-master'i kullan."
set "M_NOFILE=HATA: Bir dosya eksik. custom-files icindeki her seyi bu klasore kopyala:"
set "M_COPYFAIL1=HATA: Dosyalar %DEST% klasorune kopyalanamadi."
set "M_COPYFAIL2=Acik zapret pencerelerini kapatip tekrar dene."
set "M_DRIVERLOCKED1=HATA: Onceki kurulumun WinDivert surucusu hala yuklu, dosyasi bu surumle degistirilemiyor."
set "M_DRIVERLOCKED2=PC'yi yeniden baslatip bunu tekrar calistir."
set "M_CREATEFAIL=HATA: Servis olusturulamadi. services.msc aciksa kapatip tekrar dene."
set "M_STARTFAIL1=HATA: Servis olusturuldu ama calismiyor."
set "M_STARTFAIL2= - Antivirus winws.exe veya WinDivert'i engellemis olabilir. %DEST% klasorunu istisnalara ekle."
set "M_ERRCODE=hata"
set "M_DRIVERFAIL1= - WinDivert surucusu yuklenemedi, bu bir antivirus sorunu degil."
set "M_DRIVERFAIL2= - PC'yi yeniden baslatip bunu tekrar calistir. Devam ederse baska bir DPI araci veya anti-cheat WinDivert'i engelliyor olabilir."
set "M_PRESSKEY=Pencereyi kapatmak icin bir tusa bas."
exit /b
