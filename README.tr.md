# custom-scripts

🇬🇧 [English version](README.md)

Hazır script ve kurulumlardan oluşan bir koleksiyon. Her proje kendi klasöründe, diğerlerinden bağımsız çalışıyor ve adım adım anlatan kendi README'si var.

## Projeler

| Proje | Ne yapar | Platform |
|---|---|---|
| [Deep Packet Inspection (DPI)](Deep%20Packet%20Inspection%20%28DPI%29) | zapret ya da GoodbyeDPI ile DPI engellerini (örn. Türkiye'deki Discord engelini) aşar. Çift tıklamayla kurulum, farklı internet sağlayıcıları için ayar menüsü, İngilizce / Türkçe. | Windows 11 |

## Nasıl kullanılır

1. Depoyu indir: **Code → Download ZIP**. Çıkarmadan önce zip'e sağ tıkla → **Özellikler** → **Engellemeyi kaldır**'ı işaretle → **Tamam** ([aşağıda](#windows-scriptleri-engellerse) anlatıldı), sonra zip'i çıkar.
2. İhtiyacın olan projenin klasörünü aç ve içindeki README'yi takip et.

Sadece kullandığın projenin klasörüne ihtiyacın var, diğerlerini görmezden gelebilir ya da silebilirsin.

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
