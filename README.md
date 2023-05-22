# MATLAB ile PDF'ten Özelleştirilmiş Ekran Görüntüsü Alma

Sözkonusu proje yerden ısıtma sistemleri tasarladğımız bir firmada hayata geçirdiğim bir yazılımdır. Isı hesaplarını 
yaptığımız programdan elde ettiğimiz PDF dosyalarındaki belirli tabloları teknik çizim çıktılarına koymak için PDF dosyalarının 
içerisinden gerekli tabloların yerlerini OCR ile tespit eden ve otamatik olarak kesip resim dosyası olarak dışarı aktaran MATLAB kodunun 
genel hatlarını aşağıda aşamaları ile anlattım:

ImgExtractor.m ve PDFtoImg.m dosyalarındaki MATLAB kodları, PDF dosyalarından resimleri çıkarmak ve bunları analiz etmek için yazılmıştır. Kodların genel hatları şöyledir:

- ImgExtractor.m dosyası, PDFtoImg.m dosyasını çağırarak PDF dosyalarını resimlere dönüştürür.

- ImgExtractor.m dosyası, resimleri gri tonlamaya çevirir ve ikili görüntülere dönüştürür.

- ImgExtractor.m dosyası, OCR (optik karakter tanıma) fonksiyonunu kullanarak resimlerdeki metinleri tanır ve belirli kelimeleri arar.

- ImgExtractor.m dosyası, resimleri belirli oranlara göre kırparak istenen bölümleri alır. Bu bölümler WB (Warmtebalans) ve Rollen olarak adlandırılır.

- ImgExtractor.m dosyası, alınan bölümleri PNG formatında kaydeder.

Bu kodlar, MATLAB'ın matris işleme, grafik çizme ve OCR gibi güçlü özelliklerini kullanarak verileri 
hızlı ve etkili bir şekilde işlemek için yazılmıştır. Uygulama basit bir arayüz tasarımına sahiptir. Kullanıcıların PDF dosyalarını ve çıkartma yolunu belirteceği
iki adet buton bulunur. "Tabloları Çıkart" butonu ile ise MATLAB kodu çalışır ve PDF'ten istenen tablolar ayıklanıp istenilen dosya yoluna çıkartılır. Eskiden saatler alan işlemi dakikalar hatta saniyeler içerisinde sonuca ulaştırarak zamandan kazanç sağlar.