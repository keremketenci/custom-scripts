# Windows 11 için Custom GoodbyeDPI

🇬🇧 [English version](README.md)

Windows 11'de DPI engellerini aşmak için [GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI) üzerine hazırlanmış birkaç hazır script.

İki GoodbyeDPI sürümü var, **birini seç**:

| Klasör | Sürüm | Varsayılan ayar |
|---|---|---|
| `turkey` | [GoodbyeDPI-Turkey](https://github.com/cagritaskn/GoodbyeDPI-Turkey) (0.2.3rc3) — ValdikSS'in Türkiye için yapılmış forku | `-5` + DNS yönlendirme. Fazladan alternatif ayarları var (çoğu Superonline için). |
| `valdik` | Orijinal [ValdikSS GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI) (0.2.2) | `-5` + DNS yönlendirme |

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

> ℹ️ Create dosyaları gerekli dosyaları `C:\ProgramData\goodbyedpi-custom` ve `C:\ProgramData\goodbyedpi-global` klasörlerine kopyalıyor, servisler oradan çalışıyor. Kurduktan sonra klasörü taşıyabilirsin. Ama site listesini düzenlemek için saklaman iyi olur. Onsuz kaldırmak için o klasörlerdeki `uninstall.cmd`'yi kullan.

### 2. Servisleri kur

GoodbyeDPI klasöründe şu dosyalara **çift tıkla** ve yönetici (UAC) uyarısında **Evet**'e bas:

- `service_custom_create.cmd` → **goodbyedpi-custom** servisini kurar ve başlatır. Artık her PC açılışında otomatik çalışır.
- `service_global_create.cmd` → **goodbyedpi-global** servisini kurar. Başlatmaz, sadece elle başlatılır (aşağıya bak).

İkisi de önce **dil** sorar (`1) English  2) Turkce`), sonra bir **ayar menüsü** gösterir. Türkçe için `2` yaz. Ayarda ne seçeceğini bilmiyorsan **Enter'a bas**, varsayılan ayar kurulur. Seçimlerin kaydedilir (`language.txt`, `profile.txt`) ve bir sonraki kurulumda (global dahil) varsayılan olarak gelir. Kaldırma dosyaları ve global penceresi tekrar sormadan kayıtlı dili kullanır. Sadece dili değiştirmek istersen `select-language.cmd`'ye çift tıkla. (`select-profile.cmd` sadece create dosyaları tarafından kullanılır, doğrudan açarsan sana bunu söyler.) Site açılmazsa ne yapacağın aşağıda, *Sorun Giderme* bölümünde.

`Kuruldu.` / `GoodbyeDPI Global servisi olusturuldu.` yazısını görünce (İngilizce seçtiysen `Installed.` / `GoodbyeDPI Global service created.`) bir tuşa basıp pencereyi kapatabilirsin. Bir şey ters giderse `HATA:` (İngilizce'de `ERROR:`) ile başlayan bir mesaj ve ne yapman gerektiği yazar.

> ℹ️ Eski scriptlerin kurduğu `GoodbyeDPI` ve `GoodbyeDPI-discord` servisleri varsa `service_custom_create.cmd` onları otomatik kaldırır. Aynı trafiği iki kez işlemesinler diye.

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

1. `run-goodbyedpi-global.bat` dosyasına çift tıkla.
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

Çift tıkla (yönetici izni ister):

- `service_custom_remove.cmd` → goodbyedpi-custom'ı kaldırır
- `service_global_remove.cmd` → goodbyedpi-global'i kaldırır

Bunlar `C:\ProgramData` içindeki kopyaları da siler. Turkey ve valdik aynı servis adlarını kullandığı için hangi klasörden çalıştırdığının önemi yok.

Klasörü zaten sildin mi? Her kurulumun kendi kaldırıcısı da var: `C:\ProgramData\goodbyedpi-custom` veya `C:\ProgramData\goodbyedpi-global` içindeki `uninstall.cmd`'ye çift tıkla.

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
| 1 | `-5` + DNS (varsayılan) ✅ | `-5` + DNS (varsayılan) ✅ |
| 2 | `-5 --set-ttl 5` + DNS (forkun kendi varsayılanı) ❌ | `-5 --set-ttl 5` + DNS ✅ |
| 3 | `-5` ✅ | `-6` + DNS ❌ |
| 4 | `--set-ttl 3` ❌ | `--set-ttl 3` + DNS ❌ |
| 5 | `--set-ttl 3` + DNS ❌ | `-1` + DNS ❌ |
| 6 | `-9` + DNS ❌ | `-5` (DNS yok) ✅ |
| 7 | `-9` ❌ | — |

✅ / ❌ = Türkiye'deki bir bağlantıda yaptığımız testte (Ekim 2026) Discord'u açtı / açmadı. Engelleme sağlayıcıdan sağlayıcıya değişir, o yüzden ❌ olan ayarlar senin bağlantında yine de denemeye değer. Turkey'deki 3–7 numaralar, forkun Superonline için hazırladığı alternatif ayarlar.

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
