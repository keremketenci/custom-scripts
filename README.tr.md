# custom-scripts

🇬🇧 [English version](README.md)

Hazır script ve kurulumlardan oluşan bir koleksiyon. Her proje kendi klasöründe, diğerlerinden bağımsız çalışıyor ve adım adım anlatan kendi README'si var.

## Projeler

| Proje | Ne yapar | İndir | Platform |
|---|---|---|---|
| [Deep Packet Inspection (DPI)](Deep%20Packet%20Inspection%20%28DPI%29) | zapret ya da GoodbyeDPI ile DPI engellerini (örn. Türkiye'deki Discord engelini) aşar. Çift tıklamayla kurulum, farklı internet sağlayıcıları için ayar menüsü, İngilizce / Türkçe. | En yeni **DPI bypass scripts** sürümünden `zapret.zip` ya da `goodbyedpi.zip` | Windows 11 |
| [Default Audio Device Guard](default-audio-device-guard) | Windows'un varsayılan ses cihazlarını kendi kendine değiştirmesini engeller. (README İngilizce) | `DefaultAudioDeviceGuard.zip` | Windows 10 / 11 |
| [Discord Screen Share Echo Fix](discord-screenshare-echo-fix) | Sanal ses mikseri kullanırken Discord'da sesli ekran paylaşımında izleyenlerin duyduğu yankıyı düzeltir. (README İngilizce) | `DiscordScreenShareEchoFix.zip` | Windows 10 / 11 |

## Nasıl kullanılır

1. [Releases](https://github.com/keremketenci/custom-scripts/releases) sayfasını aç ve ihtiyacın olan projenin en yeni sürümünden zip'ini indir (yukarıdaki tabloya bak). Her zip'te sadece o proje var.
2. Çıkarmadan önce zip'e sağ tıkla → **Özellikler** → **Engellemeyi kaldır**'ı işaretle → **Tamam** ([aşağıda](#windows-scriptleri-engellerse) anlatıldı), sonra zip'i çıkar.
3. Çıkan klasördeki README'yi takip et.

Kurduktan sonra çıkardığın klasörü silebilirsin: her proje ihtiyacı olan dosyaları, kendi kaldırıcısı dahil, bilgisayarındaki bir kurulum klasörüne kopyalar. Nerede olduğu projenin README'sinde yazıyor.

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

## Başkalarının yazılımları

Bazı projeler başkalarının yaptığı programları içeriyor (her zaman resmi sürümlerinin değiştirilmemiş kopyaları). Yazarları ve lisansları her projenin README'sinde ve klasörlerinde yazıyor.

Kullanım sorumluluğu sana ait.
