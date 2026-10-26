# Windows 11 için Custom GoodbyeDPI

🇬🇧 [English version](README.md)

Windows 11'de DPI engellerini aşmak için [GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI) üzerine hazırlanmış birkaç hazır script.

İki GoodbyeDPI sürümü var, **birini seç**:

| Klasör | Sürüm | Varsayılan ayar |
|---|---|---|
| `turkey` | [GoodbyeDPI-Turkey](https://github.com/cagritaskn/GoodbyeDPI-Turkey) (0.2.3rc3) — ValdikSS'in Türkiye için yapılmış forku | `-5 --set-ttl 5` + DNS yönlendirme (Superonline için TTL 7). Fazladan alternatif ayarları var (çoğu Superonline için). |
| `valdik` | Orijinal [ValdikSS GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI) (0.2.2) | `-5 --set-ttl 5` + DNS yönlendirme (Superonline için TTL 7) |

İki klasördeki scriptler aynı. Tek fark, kurulumda çıkan ayar menüsündeki seçenekler (`select-profile.cmd`). Servis adları da aynı, yani birini kurunca diğerinin yerine geçer. İkisi aynı anda kurulu olamaz.

Her sürümde iki mod var:

| Mod | Neyi etkiler | Nasıl çalışır |
|---|---|---|
| **goodbyedpi-custom** | Sadece `list-custom.txt` içindeki siteler (varsayılan: Discord) | Windows servisi, PC her açıldığında **otomatik başlar** |
| **goodbyedpi-global** | PC'deki **tüm** siteler | Sadece terminal penceresi açıkken çalışır. Pencereyi kapatırsan durur |

> ℹ️ Menüde "+ DNS" yazan ayarlarda (varsayılan dahil) DNS istekleri Yandex DNS'e (`77.88.8.8`, port 1253) yönlendirilir. Bu sayede Windows ayarlarından DNS değiştirmene gerek kalmaz. Bu yönlendirme listeden bağımsız olarak **tüm PC'de** geçerlidir.

> ⚠️ **Discord sesli sohbet hakkında:** Liste Discord'un bütün alan adlarını kapsıyor (uygulama, resimler, dosya yükleme, ses sunucuları, Aktiviteler, hediye linkleri...). Ama GoodbyeDPI sadece web trafiğine (TCP) ve DNS'e müdahale edebiliyor. Sesli ve görüntülü görüşmeler UDP ile gidiyor, GoodbyeDPI buna dokunamıyor. Yani sağlayıcın sadece Discord'un alan adlarını engelliyorsa ses de çalışır, ama ses trafiğini de ayrıca engelliyorsa çalışmaz. Yazı çalışıp ses "RTC Bağlanıyor"da takılıyorsa sesi de işleyebilen [zapret](../zapret)'i kullan.

---

## Kurulum

### 0. (İsteğe bağlı) En güncel sürümü indir

Klasörlerde GoodbyeDPI zaten hazır geliyor, **bu adımı atlayabilirsin**. Güncel sürümü kullanmak istersen:

- Turkey: https://github.com/cagritaskn/GoodbyeDPI-Turkey/releases
- Valdik: https://github.com/ValdikSS/GoodbyeDPI/releases

Zip'i indirip çıkar ve aşağıdaki adımlarda hazır gelen klasör yerine bunu kullan. İçinde `x86` ve `x86_64` klasörleri olmalı.

> ℹ️ **Scriptler yeni sürümlere uyum sağlar:** Zip fazladan bir alt klasöre açılsa bile `goodbyedpi.exe`'yi bulur. WinDivert dosyalarını tam adlarıyla değil joker karakterle kopyalar. Kurulumdan birkaç saniye sonra servisin gerçekten çalıştığını kontrol eder. GoodbyeDPI desteklemediği bir ayarda hemen kapanıyor, böyle olursa başka ayar seçmeni söyleyen bir hata mesajı çıkar. Valdik menüsü sadece `-1` … `-6` modlarını kullanıyor, bunları 0.2.2'den beri her sürüm destekliyor.
>
> ⚠️ **Kalan risk:** İleriki bir sürüm `goodbyedpi.exe`'nin adını ya da `x86` / `x86_64` klasör yapısını değiştirirse create dosyaları hata verir. O zaman hazır gelen klasöre geri dön. Klasörü bozarsan yanındaki `.zip` orijinal kopyadır.

### 1. Dosyaları kopyala

Seçtiğin sürümün `custom-files` klasörünün **içindeki her şeyi** aynı sürümün GoodbyeDPI klasörüne kopyala:

| Sürüm | Buradan | Buraya |
|---|---|---|
| Turkey | `turkey\custom-files` | `turkey\goodbyedpi-0.2.3rc3-turkey` |
| Valdik | `valdik\custom-files` | `valdik\goodbyedpi-0.2.2` |

Yani `service_custom_create.cmd` ile `x86_64` klasörü yan yana durmalı.

### 2. Servisleri kur

GoodbyeDPI klasöründe şu dosyalara **çift tıkla** ve yönetici (UAC) uyarısında **Evet**'e bas:

- `service_custom_create.cmd` → **goodbyedpi-custom** servisini kurar ve başlatır. Artık her PC açılışında otomatik çalışır.
- `service_global_create.cmd` → **goodbyedpi-global** servisini kurar. Başlatmaz, sadece elle başlatılır (aşağıya bak).

İkisi de önce **dil** sorar (`1) English  2) Turkce`), sonra bir **ayar menüsü** gösterir. Türkçe için `2` yaz. Ayarda ne seçeceğini bilmiyorsan **Enter'a bas**, varsayılan ayar kurulur. **Superonline kullanıyorsan ayar menüsünde `2` yaz.** Seçimlerin kaydedilir (`language.txt`, `profile.txt`) ve bir sonraki kurulumda (global dahil) varsayılan olarak gelir. Kaldırma dosyaları ve global penceresi tekrar sormadan kayıtlı dili kullanır. Sadece dili değiştirmek istersen `select-language.cmd`'ye çift tıkla. (`select-profile.cmd` sadece create dosyaları tarafından kullanılır, doğrudan açarsan sana bunu söyler.) Site açılmazsa ne yapacağın aşağıda, *Sorun Giderme* bölümünde.

`Kuruldu.` / `GoodbyeDPI Global servisi olusturuldu.` yazısını görünce (İngilizce seçtiysen `Installed.` / `GoodbyeDPI Global service created.`) bir tuşa basıp pencereyi kapatabilirsin. Bir şey ters giderse `HATA:` (İngilizce'de `ERROR:`) ile başlayan bir mesaj ve ne yapman gerektiği yazar.

> ℹ️ Eski scriptlerin kurduğu `GoodbyeDPI` ve `GoodbyeDPI-discord` servisleri varsa `service_custom_create.cmd` onları otomatik kaldırır. Aynı trafiği iki kez işlemesinler diye.

### 3. Kurduktan sonra: indirdiğin klasörü silebilirsin

Create dosyaları servislerin ihtiyacı olan her şeyi `C:\ProgramData` altına kopyalıyor, servisler oradan çalışıyor. İndirdiğin klasöre artık ihtiyacın yok:

| Klasör | İçinde ne var |
|---|---|
| `C:\ProgramData\goodbyedpi-custom` | goodbyedpi-custom'ın dosyaları ve kendi `uninstall.cmd`'si |
| `C:\ProgramData\goodbyedpi-global` | goodbyedpi-global'in dosyaları, `run-goodbyedpi-global.bat` (global'i başlatır) ve kendi `uninstall.cmd`'si |

İndirdiğin klasörü sadece ileride site listesini ya da ayarı değiştirmek istersen sakla: ikisi de oradaki `service_custom_create.cmd`'yi tekrar çalıştırarak yapılıyor. (Sildiysen zip'i tekrar indirmen yeterli.)

---

## Kullanım

### goodbyedpi-custom (belirli siteler, sürekli açık)

Hiçbir şey yapmana gerek yok, arka planda hep çalışıyor.

Site eklemek veya çıkarmak için `list-custom.txt` dosyasını düzenle. Her satıra bir domain yaz, örneğin:

```
nonexistent.domain
discord.com
discord.gg
ornek.com
```

İlk satırdaki `nonexistent.domain`'e dokunma, olduğu gibi kalsın.

Sonra `service_custom_create.cmd`'yi tekrar çalıştır. Yeni listeyi kopyalar ve servisi yeniden başlatır.

### goodbyedpi-global (tüm PC, istediğinde)

1. `C:\ProgramData\goodbyedpi-global` içindeki `run-goodbyedpi-global.bat` dosyasına çift tıkla (indirdiğin klasördeki de aynı işi yapar).
2. Yönetici (UAC) uyarısında **Evet**'e tıkla.
3. Bir terminal penceresi açılır ve servisin çalıştığını söyler.
4. Kullandığın sürece **pencereyi açık tut** (küçültebilirsin).
5. Durdurmak için **pencereyi kapat** (ya da `Ctrl+C`). Servis otomatik olarak durur.

Global açıkken `goodbyedpi-custom` ve `zapret-custom` geçici olarak durdurulur, pencereyi kapatınca otomatik olarak tekrar başlar. Bunun sebebi aynı trafiğin iki kez işlenmemesi.

---

## zapret ile birlikte kullanma

GoodbyeDPI ve zapret aynı işi yapıyor. İkisi aynı anda açık olursa siteler açılmayabilir. Bu yüzden **her modda sadece bir araç kurulu olabilir**:

- `service_custom_create.cmd` → zapret'in custom servisini (`zapret-custom`) **tamamen kaldırır** ve sonra kendini kurar. zapret'in create dosyası da GoodbyeDPI'ınkini aynı şekilde kaldırır.
- `service_global_create.cmd` → global tarafta aynısını yapar (`zapret-global` ↔ `goodbyedpi-global`).
- Turkey ve valdik zaten aynı servis adlarını kullanıyor, biri kurulunca diğerinin yerine geçer.

Yani hangi aracın create dosyasını en son çalıştırdıysan o kurulu kalır. Diğerine dönmek için onun create dosyasını çalıştırman yeterli.

Custom ve global farklı araçlardan olabilir (örn. custom zapret, global GoodbyeDPI). Global penceresi açılınca çalışan custom servisi duraklatır, kapanınca geri başlatır.

---

## Kaldırma

Kaldırmak istediğinin `uninstall.cmd`'sine çift tıkla (yönetici izni ister):

- `C:\ProgramData\goodbyedpi-custom\uninstall.cmd` → goodbyedpi-custom'ı kaldırır
- `C:\ProgramData\goodbyedpi-global\uninstall.cmd` → goodbyedpi-global'i kaldırır

İndirdiğin klasör hâlâ duruyorsa oradaki `service_custom_remove.cmd` ve `service_global_remove.cmd` de aynı işi yapar. Turkey ve valdik aynı servis adlarını kullandığı için hangi klasörden çalıştırdığının önemi yok.

Servisi ve `C:\ProgramData` içindeki klasörünü kaldırırlar. WinDivert sürücüsü PC yeniden başlayana kadar yüklü kalabildiği için klasörde `WinDivert64.sys` kalabilir; PC'yi yeniden başlatıp kalanı sil.

---

## Sorun Giderme

- **"Smart App Control blocked a file that may be unsafe" diyor / scriptler açılmıyor** → Windows internetten indirilen dosyaları engelliyor. Ana README'deki [Windows scriptleri engellerse](https://github.com/keremketenci/custom-scripts/blob/main/README.tr.md#windows-scriptleri-engellerse) bölümüne bak.
- **Antivirüs `goodbyedpi.exe` veya `WinDivert`'i siliyor / engelliyor** → `goodbyedpi` klasörünü, `C:\ProgramData\goodbyedpi-custom` ve `C:\ProgramData\goodbyedpi-global` klasörlerini antivirüs istisnalarına ekle. Bu yanlış alarm, ağ paketlerine müdahale ettiği için antivirüsler sevmiyor.
- **Global penceresi "servisi bulunamadi" diyor** → önce `service_global_create.cmd`'yi çalıştır.
- **"Servis olusturuldu ama calismiyor" / "baslar baslamaz durdu" diyor** → create dosyasını tekrar çalıştırıp başka bir ayar seç, kullandığın GoodbyeDPI sürümü seçilen ayarı desteklemiyor olabilir. Hiçbiri olmazsa antivirüsünü kontrol et.
- **Site hâlâ açılmıyor** → `list-custom.txt` içinde olduğunu kontrol et, sonra aşağıdaki gibi başka bir ayar dene.
- **Valdik sürümünde servis başlamıyor (antivirüs engellemiyorsa)** → Valdik eski bir WinDivert sürücüsü (1.4) kullanıyor. Windows 11'in *Çekirdek yalıtımı / Bellek bütünlüğü* özelliği bunu engelleyebilir. Turkey sürümünü kullan, onun sürücüsü güncel.
- **Discord yazı çalışıyor ama ses "RTC Bağlanıyor"da takılıyor** → sağlayıcın ses trafiğini (UDP) de engelliyor, GoodbyeDPI buna müdahale edemiyor. Zapret'i kullan.
- **Servisler kurulu mu / çalışıyor mu bakmak için** → `Win + R` bas, `services.msc` yaz, `goodbyedpi-custom` ve `goodbyedpi-global`'i bul.

### Site açılmıyorsa: başka ayar dene

Engel aşma yöntemi internet sağlayıcısına göre değişir. Varsayılan ayar senin sağlayıcında çalışmayabilir. Bu yüzden create dosyalarında hazır alternatifler var:

1. `service_custom_create.cmd`'yi tekrar çalıştır.
2. Menüde **bir sonraki numarayı** yaz (örn. `2`) ve Enter'a bas. Servis birkaç saniyede yeni ayarla kurulur.
3. Siteyi dene. Tarayıcıyı kapatıp açmak ya da `Ctrl+F5` ile yenilemek iyi olur. Açılmazsa 1. adıma dön ve sıradaki numarayı dene.
4. Çalışan ayarı bulunca bir şey yapmana gerek yok, seçim kaydedildi. Global'i kurarken (`service_global_create.cmd`) menüde Enter'a basman yeterli, aynı ayar gelir.

| | Turkey menüsü | Valdik menüsü |
|---|---|---|
| 1 | `-5 --set-ttl 5` + DNS (varsayılan, Türk Telekom ve çoğu sağlayıcı) ❌ | `-5 --set-ttl 5` + DNS (varsayılan, Türk Telekom ve çoğu sağlayıcı) ✅ |
| 2 | `-5 --set-ttl 7` + DNS (**Superonline kullanıyorsan bunu seç**) | `-5 --set-ttl 7` + DNS (**Superonline kullanıyorsan bunu seç**) |
| 3 | `-5` + DNS (otomatik TTL, 1 de 2 de çalışmazsa) ✅ | `-5` + DNS (otomatik TTL, 1 de 2 de çalışmazsa) ✅ |
| 4 | `-5` ✅ | `-6` + DNS ❌ |
| 5 | `--set-ttl 3` ❌ | `--set-ttl 3` + DNS ❌ |
| 6 | `--set-ttl 3` + DNS ❌ | `-1` + DNS ❌ |
| 7 | `-9` + DNS ❌ | `-5` (DNS yok) ✅ |
| 8 | `-9` ❌ | — |

✅ / ❌ = Türkiye'deki bir bağlantıda yaptığımız testte (Ekim 2026) Discord'u açtı / açmadı. 2 numara sonradan eklendi, o testte yoktu. Engelleme sağlayıcıdan sağlayıcıya değişir, o yüzden ❌ olan ayarlar senin bağlantında yine de denemeye değer. 1 ve 2'deki TTL değerleri bu sağlayıcılarda çalışan değerlerden geliyor. Turkey'deki 4–8 numaralar, forkun Superonline için hazırladığı alternatif ayarlar.

Hiçbiri çalışmazsa diğer sürüme geç (turkey ↔ valdik) ya da daha fazla yöntemi olan [zapret](../zapret)'i dene.

---

## Klasör yapısı

```
goodbyedpi\
├─ turkey\
│  ├─ custom-files\                    ← bu scriptler
│  ├─ goodbyedpi-0.2.3rc3-turkey\      ← forkun kendi dosyaları
│  └─ goodbyedpi-0.2.3rc3-turkey.zip   ← orijinal yedek
└─ valdik\
   ├─ custom-files\
   ├─ goodbyedpi-0.2.2\
   └─ goodbyedpi-0.2.2.zip
```
