# Windows için DPI engeli aşma scriptleri

🇬🇧 [English version](README.md)

Windows 11'de DPI engellerini (örneğin Türkiye'deki Discord engelini) aşmak için hazır scriptler. İki bilinen aracın üzerine kurulu: **zapret** ve **GoodbyeDPI**. Çift tıkla kur, menüden bir ayar seç, bu kadar. Komut satırı bilmene gerek yok.

## Hangisini kullanmalıyım?

| | [zapret](zapret) | [GoodbyeDPI](goodbyedpi) |
|---|---|---|
| Web siteleri (Discord vb.) | ✅ | ✅ |
| Discord sesli / görüntülü görüşme | ✅ her zaman işlenir | ⚠️ sadece sağlayıcın ses trafiğini ayrıca engellemiyorsa |
| Menüdeki yöntem sayısı | 6 | 6–7 (iki sürüm: orijinali ve Türkiye için yapılmış bir fork) |
| Testimizde (Türkiye'de bir bağlantı, Ekim 2026) | 6 ayarın hepsi çalıştı | 7'den 3'ü (turkey), 6'dan 3'ü (valdik) çalıştı |

**Emin değilsen [zapret](zapret) ile başla.** Senin bağlantında çalışmazsa [GoodbyeDPI](goodbyedpi)'ı dene.

## Scriptler ne yapıyor?

İki araçta da aynı scriptler var:

- **İki mod**
  - **custom:** sadece bir listedeki siteler (varsayılan olarak Discord'un bütün alan adları). Windows servisi olarak kurulur, her açılışta otomatik başlar.
  - **global:** PC'deki bütün trafik. Sadece penceresi açıkken çalışır, pencereyi kapatınca durur.
- **Ayar menüsü:** Engelleme internet sağlayıcısına göre değişiyor, bu yüzden kurulumda birkaç yöntem sunuluyor. Site açılmazsa kurulumu tekrar çalıştırıp sıradaki numarayı seçersin.
- **İngilizce / Türkçe:** Kurulum önce dili sorar (varsayılan İngilizce, Türkçe için `2`).
- **Aynı anda tek araç:** Bir aracın custom (ya da global) modunu kurmak diğer aracınkini kaldırır, böylece ikisi aynı trafiği iki kez işlemez.
- **Yeni sürümlerle çalışır:** Scriptler buldukları sürümün dosyalarını ve ayarlarını kontrol eder, desteklenmeyen bir şey varsa açıkça söyler.

## Hızlı başlangıç

1. Depoyu indir (**Code → Download ZIP**). Çıkarmadan önce zip'e sağ tıkla → **Özellikler** → **Engellemeyi kaldır**'ı işaretle → **Tamam** ([aşağıda](#windows-scriptleri-engellerse) anlatıldı), sonra zip'i çıkar ve `Deep Packet Inspection (DPI)` klasörünü aç.
2. [zapret](zapret) ya da [GoodbyeDPI](goodbyedpi) klasörünü aç ve içindeki README'yi takip et. Kısaca: `custom-files` içindekileri aracın klasörüne kopyala ve `service_custom_create.cmd`'ye çift tıkla.

## Klasör yapısı

```
zapret\
├─ custom-files\                 ← scriptler
├─ zapret-win-bundle-master\     ← zapret'in kendisi
└─ README.md
goodbyedpi\
├─ turkey\                       ← GoodbyeDPI-Turkey forku + scriptleri
├─ valdik\                       ← orijinal GoodbyeDPI + scriptleri
└─ README.md
```

## Windows scriptleri engellerse

Windows internetten indirilen dosyaları işaretliyor, **Akıllı Uygulama Denetimi** (Smart App Control) ya da SmartScreen de bu yüzden scriptleri çalıştırmayabiliyor (*"Smart App Control blocked a file that may be unsafe"*). Zip'i **çıkarmadan önce** işareti kaldır:

1. İndirdiğin zip'e sağ tıkla → **Özellikler**.
2. **Genel** sekmesinin altındaki **Engellemeyi kaldır** kutusunu işaretle → **Tamam**. (Bu kutu yoksa dosya işaretli değil, devam et.)
3. Zip'i çıkar. Çıkan dosyalar engellenmez.

### Engelini kaldırmadan çıkardıysan

Çıkardığın dosyalarda da aynı işaret var. Düzeltmenin iki yolu var:

**A yolu, tekrar çıkar (en kolayı):**

1. Çıkardığın klasörü sil.
2. Zip'e yukarıdaki 1–2. adımları uygula (**Özellikler** → **Engellemeyi kaldır** → **Tamam**).
3. Zip'i tekrar çıkar.

**B yolu, çıkardığın klasörün engelini kaldır (tekrar çıkarmadan):**

1. Çıkardığın klasörü aç.
2. İçinde boş bir yere sağ tıkla → **Terminalde aç**.
3. Şu satırı yapıştır ve **Enter**'a bas:
   ```
   Get-ChildItem -Recurse | Unblock-File
   ```
4. Pencereyi kapat. Bu klasördeki ve alt klasörlerindeki bütün scriptler artık çalışır.

Bunun için Akıllı Uygulama Denetimi'ni kapatma: Birçok Windows sürümünde bir kez kapatınca Windows'u yeniden kurmadan tekrar açılamıyor.

## Antivirüs uyarıları

İki araç da ağ paketlerine WinDivert sürücüsüyle müdahale ederek çalışıyor, antivirüsler bunu sık sık yanlışlıkla tehdit olarak görüyor. Antivirüsün dosyaları silerse ya da engellerse aracın klasörünü ve `C:\ProgramData\...` klasörünü (her README'de adı yazıyor) istisnalara ekle.

## Emeği geçenler

Engel aşma araçlarını başkaları yaptı, bu depo sadece onların etrafına kurulum scriptleri ve rehberler ekliyor. İçindeki programlar resmi sürümlerinin değiştirilmemiş kopyaları, lisansları kendi klasörlerinde.

- [zapret](https://github.com/bol-van/zapret) / [zapret-win-bundle](https://github.com/bol-van/zapret-win-bundle) — bol-van
- [GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI) — ValdikSS
- [GoodbyeDPI-Turkey](https://github.com/cagritaskn/GoodbyeDPI-Turkey) — cagritaskn
- [WinDivert](https://github.com/basil00/WinDivert) — basil00

Kullanım sorumluluğu sana ait, ülkendeki yasaları kontrol et.
