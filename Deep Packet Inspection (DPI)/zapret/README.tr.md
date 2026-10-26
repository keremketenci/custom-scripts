# Windows 11 için Custom Zapret

🇬🇧 [English version](README.md)

Windows 11'de DPI engellerini aşmak için [zapret-win-bundle](https://github.com/bol-van/zapret-win-bundle) üzerine hazırlanmış birkaç hazır script.

İki modu var:

| Mod | Neyi etkiler | Nasıl çalışır |
|---|---|---|
| **zapret-custom** | Sadece `files\list-custom.txt` içindeki siteler (varsayılan: Discord) + Discord sesli sohbet | Windows servisi, PC her açıldığında **otomatik başlar** |
| **zapret-global** | PC'deki **tüm** trafik | Sadece terminal penceresi açıkken çalışır. Pencereyi kapatırsan durur |

---

## Kurulum

### 0. (İsteğe bağlı, önerilir) Zapret'in en güncel sürümünü indir

Bu paketin içinde `zapret-win-bundle-master` klasörü zaten hazır geliyor, yani **bu adımı atlayabilirsin**, sorunsuz çalışır.

Ama zapret sık sık güncelleniyor (hata düzeltmeleri, daha iyi engel aşma yöntemleri) ve paketteki sürüm sana ulaştığında eskimiş olabilir. En güncel sürümü kullanmak istersen:

1. https://github.com/bol-van/zapret-win-bundle adresine git.
2. **Code → Download ZIP**'e tıkla. Çıkarmadan önce zip'in engelini [Windows scriptleri engellerse](https://github.com/keremketenci/custom-scripts/blob/main/README.tr.md#windows-scriptleri-engellerse) bölümünde anlatıldığı gibi kaldır, sonra zip'i klasöre çıkar.
3. Aşağıdaki adımlarda hazır gelen klasör yerine bu yeni `zapret-win-bundle-master` klasörünü kullan.

> ℹ️ **Scriptler yeni sürümlere uyum sağlar:** DLL ve sürücü dosyalarını tam adlarıyla değil joker karakterle kopyalar. Yeni sürümde artık olmayan filtre dosyalarını atlar, Discord ses filtresi eksikse uyarı verir. Seçilen ayarı herhangi bir servise dokunmadan **önce** `winws --dry-run` ile o sürümün kabul edip etmediğini kontrol eder. Kabul etmezse başka bir ayar seçmeni ister.
>
> ⚠️ **Kalan risk:** Zapret'in ileriki bir sürümü `winws.exe`'yi tamamen kaldırırsa (zapret2 / `winws2.exe` farklı bir yazım kullanıyor) ya da ayarların hiçbirini kabul etmezse, create dosyaları bunu açıklayan bir hata mesajı gösterir. Bu durumda paketle **hazır gelen** `zapret-win-bundle-master` klasörünü kullan, scriptler o sürüm için hazırlandı. Klasörü bozarsan yanındaki `zapret-win-bundle-master.zip` orijinal kopyadır.

### 1. Dosyaları kopyala

`custom-files` klasörünün **içindeki her şeyi** şu klasöre kopyala:

```
zapret-win-bundle-master\zapret-winws
```

Windows "dosyaların yerini değiştir" diye sorarsa **Değiştir**'e tıkla.

> ℹ️ Create dosyaları gerekli dosyaları `C:\ProgramData\zapret-custom` ve `C:\ProgramData\zapret-global` klasörlerine kopyalıyor, servisler oradan çalışıyor. Yani kurduktan sonra `zapret-winws` klasörünü taşıyabilir, hatta silebilirsin — ama site listesini düzenlemek için saklaman iyi olur. Onsuz kaldırmak için o klasörlerdeki `uninstall.cmd`'yi kullan.

### 2. Servisleri kur

`zapret-win-bundle-master\zapret-winws` içinde şu dosyalara **çift tıkla** ve yönetici (UAC) uyarısında **Evet**'e bas:

- `service_custom_create.cmd` → **zapret-custom** servisini kurar ve başlatır. Artık her PC açılışında otomatik çalışır. Başka bir şey yapmana gerek yok.
- `service_global_create.cmd` → **zapret-global** servisini kurar (başlatmaz, sadece elle başlatılır — aşağıya bak).

İkisi de önce **dil** sorar (`1) English  2) Turkce`), sonra bir **ayar menüsü** gösterir. Türkçe için `2` yaz. Ayarda ne seçeceğini bilmiyorsan **Enter'a bas**, varsayılan ayar kurulur. Seçimlerin kaydedilir (`language.txt`, `profile.txt`) ve bir sonraki kurulumda (global dahil) varsayılan olarak gelir. Kaldırma dosyaları ve global penceresi tekrar sormadan kayıtlı dili kullanır. Sadece dili değiştirmek istersen `select-language.cmd`'ye çift tıkla. (`select-profile.cmd` sadece create dosyaları tarafından kullanılır, doğrudan açarsan sana bunu söyler.) Site açılmazsa ne yapacağın aşağıda, *Sorun Giderme* bölümünde.

`Kuruldu.` / `Zapret Global servisi olusturuldu.` yazısını görünce (İngilizce seçtiysen `Installed.` / `Zapret Global service created.`) bir tuşa basıp pencereyi kapatabilirsin. Bir şey ters giderse `HATA:` (İngilizce'de `ERROR:`) ile başlayan bir mesaj ve ne yapman gerektiği yazar.

> ℹ️ **GoodbyeDPI ile birlikte:** İkisi aynı anda açık olursa siteler açılmayabilir. Bu yüzden her modda sadece bir araç kurulu olabilir. `service_custom_create.cmd` GoodbyeDPI'ın custom servisini (`goodbyedpi-custom`, eski `GoodbyeDPI` / `GoodbyeDPI-discord` servisleri de dahil) **tamamen kaldırır**. `service_global_create.cmd` de `goodbyedpi-global`'i kaldırır. GoodbyeDPI'ın create dosyaları da zapret'i aynı şekilde kaldırır. Hangisini en son kurduysan o kalır.

---

## Kullanım

### zapret-custom (belirli siteler, sürekli açık)

Hiçbir şey yapmana gerek yok — arka planda hep çalışıyor.

Site eklemek/çıkarmak için `files\list-custom.txt` dosyasını düzenle (her satıra bir domain), örneğin:

```
discord.com
discord.gg
ornek.com
```

Alt alan adları otomatik dahil: `ornek.com` yazarsan `www.ornek.com`, `cdn.ornek.com` vs. de etkilenir.

Sonra `service_custom_create.cmd`'yi tekrar çalıştır — yeni listeyi kopyalar ve servisi yeniden başlatır. (`C:\ProgramData\zapret-custom\files\list-custom.txt` dosyasını direkt düzenlersen servis yeniden başlayana kadar etkisi olmaz.)

> ℹ️ Discord sesli sohbet trafiğinde site adı olmadığı için listeyle seçilemiyor. Bu yüzden custom, Discord ses ve STUN paketlerini (bazı diğer sesli/görüntülü uygulamalar da STUN kullanır) listeden bağımsız olarak her zaman işler.

### zapret-global (tüm PC, istediğinde)

1. `run-zapret-global.bat` dosyasına çift tıkla. Bu dosya `C:\ProgramData\zapret-global` içinde de var, indirdiğin klasörü silsen de çalışır.
2. Yönetici (UAC) uyarısında **Evet**'e tıkla.
3. Bir terminal penceresi açılır ve servisin çalıştığını söyler.
4. Kullandığın sürece **pencereyi açık tut** (küçültebilirsin).
5. Durdurmak için **pencereyi kapat** (ya da `Ctrl+C`). Servis otomatik olarak durur.

Global açıkken zapret-custom (ve kuruluysa goodbyedpi-custom) geçici olarak durdurulur (aynı trafik iki kez işlenmesin diye) ve pencereyi kapatınca otomatik olarak tekrar başlar. goodbyedpi-global açıkken başlamaz.

---

## Kaldırma

Çift tıkla (yönetici izni ister):

- `service_custom_remove.cmd` → zapret-custom'ı kaldırır
- `service_global_remove.cmd` → zapret-global'i kaldırır

Bunlar `C:\ProgramData` içindeki kopyaları da siler. Sonra klasörü silebilirsin.

Klasörü zaten sildin mi? Her kurulumun kendi kaldırıcısı da var: `C:\ProgramData\zapret-custom` veya `C:\ProgramData\zapret-global` içindeki `uninstall.cmd`'ye çift tıkla.

---

## Sorun Giderme

- **"Smart App Control blocked a file that may be unsafe" diyor / scriptler açılmıyor** → Windows internetten indirilen dosyaları engelliyor. Ana README'deki [Windows scriptleri engellerse](https://github.com/keremketenci/custom-scripts/blob/main/README.tr.md#windows-scriptleri-engellerse) bölümüne bak.
- **Antivirüs `winws.exe` veya `WinDivert`'i siliyor / engelliyor** → `zapret-win-bundle-master`, `C:\ProgramData\zapret-custom` ve `C:\ProgramData\zapret-global` klasörlerini antivirüs istisnalarına ekle. Yanlış alarm (ağ paketlerine müdahale ettiği için antivirüsler sevmiyor).
- **"WinDivert surucusu yuklenemedi" diyor (hata 1058)** → antivirüs sorunu değil, istisna eklemek işe yaramaz. PC'yi yeniden başlatıp create dosyasını tekrar çalıştır. Devam ederse başka bir DPI aracını (başka zapret paketleri, GoodbyeDPI) kaldır ya da anti-cheat'i (Vanguard, FACEIT) kontrol et.
- **Global penceresi "servisi bulunamadi" diyor** → önce `service_global_create.cmd`'yi çalıştır.
- **"Bu zapret surumu secilen ayari kabul etmiyor" diyor** → başka bir numara seç. Hiçbirini kabul etmiyorsa hazır gelen `zapret-win-bundle-master`'ı kullan.
- **"UYARI: ... Discord sesli sohbet calismayabilir" diyor** → kullandığın zapret sürümünde Discord ses filtresi yok. Web siteleri yine çalışır, ses için hazır gelen `zapret-win-bundle-master`'ı kullan.
- **Site hâlâ açılmıyor** → `list-custom.txt` içinde olduğunu kontrol et, sonra aşağıdaki gibi başka bir ayar dene.
- **Servisler kurulu mu / çalışıyor mu bakmak için** → `Win + R` bas, `services.msc` yaz, `zapret-custom` ve `zapret-global`'i bul.

### Site açılmıyorsa: başka ayar dene

Engel aşma yöntemi internet sağlayıcısına göre değişir. Varsayılan ayar senin sağlayıcında çalışmayabilir. Bu yüzden create dosyalarında hazır alternatifler var:

1. `service_custom_create.cmd`'yi tekrar çalıştır.
2. Menüde **bir sonraki numarayı** yaz (örn. `2`) ve Enter'a bas. Servis birkaç saniyede yeni ayarla kurulur.
3. Siteyi dene. Tarayıcıyı kapatıp açmak ya da `Ctrl+F5` ile yenilemek iyi olur. Açılmazsa 1. adıma dön ve sıradaki numarayı dene.
4. Çalışan ayarı bulunca bir şey yapmana gerek yok, seçim kaydedildi. Global'i kurarken (`service_global_create.cmd`) menüde Enter'a basman yeterli, aynı ayar gelir.

| | Ayar | Ne yapar |
|---|---|---|
| 1 | fake, TTL 7 (varsayılan) | Sahte paket, 7 adım sonra kaybolur |
| 2 | fake, otomatik TTL | Aynısı, ama TTL'yi bağlantına göre kendisi ayarlar. 1 çalışmazsa önce bunu dene |
| 3 | fake, md5sig | Sahte paketi farklı bir yöntemle bozar |
| 4 | fake, badseq | Sahte paketi farklı bir yöntemle bozar |
| 5 | hostfakesplit, md5sig | Site adını bölüp araya sahte ad koyar |
| 6 | multidisorder | Sahte paket göndermez, paketi bölüp karışık sırayla yollar |

Menüdeki ayar sadece web sitelerini (TCP 80/443) etkiler. Discord ses ayarı her seçimde aynı kalır.

Türkiye'deki bir bağlantıda yaptığımız testte (Ekim 2026) 6 ayarın hepsi Discord'u açtı. Engelleme sağlayıcıdan sağlayıcıya değişir, senin bağlantında bazıları çalışmayabilir, bu yüzden birden fazla seçenek var.

### Hiçbiri işe yaramıyorsa: blockcheck

Menüdeki 6 ayarın hiçbiri çalışmazsa senin bağlantında neyin çalıştığını bulmak için:

1. Önce iki servisi de kapat (global penceresini kapat, `services.msc`'den `zapret-custom`'ı durdur).
2. `zapret-win-bundle-master\blockcheck\blockcheck.cmd`'yi çalıştır, test etmek istediğin siteyi gir (örn. `discord.com`).
3. Bitince çalışan yöntemler en sonda, `* SUMMARY` başlığının altında listelenir. `curl_test_https_tls12` (HTTPS) ile başlayan bir satır seç ve ilk `--dpi-desync`'ten satır sonuna kadar olan kısmı kopyala (`--wf-l3` ve `--wf-tcp` kısımlarını alma).
4. `select-profile.cmd`'yi Not Defteri ile aç ve kopyaladığını `PROFILE_ARGS=` satırlarından birine, oradaki ayarın yerine yapıştır. Örneğin 6 numaraya koymak için:
   ```
   if "%SEL%"=="6" set "PROFILE_ARGS=--dpi-desync=fakedsplit --dpi-desync-fooling=md5sig --dpi-desync-split-pos=1"
   ```
5. `service_custom_create.cmd`'yi çalıştır ve o numarayı seç. Script kurmadan önce zapret'in bu ayarı kabul edip etmediğini kontrol eder.
