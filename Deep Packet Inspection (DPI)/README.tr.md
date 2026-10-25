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

1. Depoyu indir (**Code → Download ZIP**). Çıkarmadan önce zip'in engelini ana README'deki [Windows scriptleri engellerse](../README.tr.md#windows-scriptleri-engellerse) bölümünde anlatıldığı gibi kaldır, sonra zip'i çıkar ve `Deep Packet Inspection (DPI)` klasörünü aç.
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

## Antivirüs uyarıları

İki araç da ağ paketlerine WinDivert sürücüsüyle müdahale ederek çalışıyor, antivirüsler bunu sık sık yanlışlıkla tehdit olarak görüyor. Antivirüsün dosyaları silerse ya da engellerse aracın klasörünü ve `C:\ProgramData\...` klasörünü (her README'de adı yazıyor) istisnalara ekle.

## Emeği geçenler

Engel aşma araçlarını başkaları yaptı, bu depo sadece onların etrafına kurulum scriptleri ve rehberler ekliyor. İçindeki programlar resmi sürümlerinin değiştirilmemiş kopyaları, lisansları kendi klasörlerinde.

- [zapret](https://github.com/bol-van/zapret) / [zapret-win-bundle](https://github.com/bol-van/zapret-win-bundle) — bol-van
- [GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI) — ValdikSS
- [GoodbyeDPI-Turkey](https://github.com/cagritaskn/GoodbyeDPI-Turkey) — cagritaskn
- [WinDivert](https://github.com/basil00/WinDivert) — basil00

Kullanım sorumluluğu sana ait, ülkendeki yasaları kontrol et.
