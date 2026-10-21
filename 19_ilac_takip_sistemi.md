# İlaç Takip Sistemi

## 1. Proje Özeti
Kullanıcıların kendisi ve yakınları (anne, baba, çocuklar) için düzenli kullanılan ilaçların saatlerini, dozajlarını ve kalan stok durumunu takip eden, akıllı saatten gelen sağlık verilerini de bir araya getiren çok profilli bir sağlık asistanı mobil uygulamasıdır. Tek bir e-posta hesabı altında birden fazla kişi profili oluşturulabilir. Uygulama aydınlık/karanlık tema ve Türkçe/İngilizce dil desteğine sahiptir.

## 2. Proje Amacı
- İlaç kullanımının unutulmasını engellemek ve tedaviye uyumu artırmak
- Bitmek üzere olan ilaçlar için önceden uyarı vermek
- Aile bireylerinin ilaçlarını tek hesaptan, ayrı profillerle yönetebilmek
- Akıllı saat sağlık verilerini ilaç takibiyle aynı yerde görebilmek

## 3. Tahmini Ekran ve Sayfa Sayısı
8 ekran: 4 giriş/profil ekranı + 4 ana sekme

| # | Ekran | Grup |
|---|-------|------|
| 1 | Giriş Ekranı | Kimlik doğrulama |
| 2 | Şifremi Unuttum | Kimlik doğrulama |
| 3 | Kayıt Ol | Kimlik doğrulama |
| 4 | Profil Seçme / Profil Oluşturma | Profil |
| 5 | İlaç Hatırlatma (Ana Sayfa) | Ana sekme 1 |
| 6 | İlaç Ekleme / Çıkarma | Ana sekme 2 |
| 7 | Akıllı Saat | Ana sekme 3 |
| 8 | Ayarlar | Ana sekme 4 |

## 4. Temel Özellikler

### 4.1. Giriş ve Hesap
- E-posta + şifre ile giriş ve kayıt
- "Şifremi unuttum" ile e-posta üzerinden şifre sıfırlama
- Kayıt işleminden sonra profil seçme ekranına yönlendirme

### 4.2. Çoklu Profil
- Tek e-posta ile birden fazla profil: **kendisi, anne, baba, çocuklar**
- Profil bilgileri: ad, yaş (doğum tarihi), cinsiyet, yakınlık
- Her profilin ilaçları, geçmişi ve sağlık verileri birbirinden ayrıdır
- Profil değişimi ayarlardan ve profil seçme ekranından yapılabilir

### 4.3. Otomatik Avatar
Yaş ve cinsiyete göre 6 avatar otomatik atanır:

| Yaş Grubu | Kadın | Erkek |
|-----------|-------|-------|
| Çocuk | Çocuk kadın avatar | Çocuk erkek avatar |
| Yetişkin | Yetişkin kadın avatar | Yetişkin erkek avatar |
| Yaşlı | Yaşlı kadın avatar | Yaşlı erkek avatar |

Yaş sınırları (varsayım): 0-17 çocuk, 18-59 yetişkin, 60+ yaşlı.

### 4.4. İlaç Hatırlatma
- Seçili profilin bugünkü ilaçları saat sırasına göre listelenir
- Bildirim ve kart üzerinde **İçtim / Ertele / Atla** aksiyonları
- Aç/tok karna kullanım bilgisi
- Kullanılan ilacın takibi (içildi, atlandı, kaçırıldı durumları)
- Kalan hap sayacı ve "Kutu Azaldı" uyarısı

### 4.5. İlaç Ekleme / Çıkarma
- Veritabanı ve API'den çekilen ilaç listesinden arayarak ilaç seçme
- Listede olmayan ilacı **sisteme yeni ilaç olarak ekleme**
- Doz, form, saat, sıklık, aç/tok, stok adedi, başlangıç-bitiş tarihi girişi
- İlaç çıkarma (pasife alma, geçmişte saklanır)

### 4.6. Akıllı Saat
- Akıllı saat bağlandığında saatteki sağlık verilerinin (nabız, adım, uyku, vb.) uygulamaya aktarılması
- Verilerin profil bazında görüntülenmesi
- Saat bağlı değilse bağlantı yönlendirme ekranı

### 4.7. Ayarlar
- Kullanıcının **geçmişte kullandığı ve aktif kullandığı ilaçların** takibi
- Profil ve hesap değişimi
- Bildirim ve ertele süresi ayarları

### 4.8. Tema ve Dil (Tüm Sayfalarda)
- Sağ üst köşede **karanlık mod** ve **Türkçe/İngilizce** geçiş butonları, her sayfada görünür
- Seçimler kalıcı olarak saklanır

## 5. Hedef Kitle
Düzenli ilaç kullanan bireyler, yaşlı ebeveynlerinin ilaçlarını takip eden yetişkin çocuklar, çocuğunun ilaç saatlerini yöneten ebeveynler ve akıllı saat kullanıcıları.

---

## 6. Öğrenci Çalışma ve Detay Alanı

### 6.1. Kullanılacak Teknolojiler & Kütüphaneler
- **Frontend:** Flutter (Dart), Material 3, çoklu tema (aydınlık/karanlık), yerelleştirme (TR/EN)
- **Backend / Veri Depolama:** Firebase Authentication, Cloud Firestore, Cloud Functions, Firebase Cloud Messaging
- **Ek Kütüphaneler / API'ler:** *(API, veritabanı ve paket seçimleri sonraki aşamada netleştirilecek)*
  - Bildirim: `flutter_local_notifications`
  - State yönetimi ve yönlendirme: Riverpod, go_router
  - Akıllı saat verisi: HealthKit / Health Connect üzerinden okuma
  - İlaç verisi: harici ilaç API'si / listesi + kendi ilaç koleksiyonu

### 6.2. Sayfa Hiyerarşisi ve Akış Planı

```
Uygulama Açılışı
├── Giriş Ekranı ──┬── Şifremi Unuttum
│                  └── Kayıt Ol
└── Profil Seçme / Oluşturma
      └── Ana Yapı (Alt Gezinme Çubuğu)
            ├── 1. İlaç Hatırlatma
            ├── 2. İlaç Ekle / Çıkar
            ├── 3. Akıllı Saat
            └── 4. Ayarlar
Her sayfada sağ üst: [Karanlık Mod] [TR/EN]
```

- [ ] Sayfa 1: **Giriş Ekranı:** e-posta, şifre, giriş butonu, "Şifremi unuttum", "Kayıt ol" bağlantıları
- [ ] Sayfa 2: **Şifremi Unuttum:** e-posta girişi, sıfırlama bağlantısı gönderme, geri dönüş
- [ ] Sayfa 3: **Kayıt Ol:** e-posta, şifre, şifre tekrar, kayıt sonrası profil oluşturmaya yönlendirme
- [ ] Sayfa 4: **Profil Seçme:** mevcut profiller (avatarlı kartlar), yeni profil ekleme (ad, yaş, cinsiyet, yakınlık: kendisi/anne/baba/çocuk)
- [ ] Sayfa 5: **İlaç Hatırlatma:** seçili profilin bugünkü ilaç zaman çizelgesi, İçtim/Ertele/Atla, kalan stok göstergesi, aktif profil avatarı
- [ ] Sayfa 6: **İlaç Ekle / Çıkar:** arama (veritabanı + API), listeden seçme, yeni ilaç tanımlama formu, mevcut ilaç listesi ve çıkarma
- [ ] Sayfa 7: **Akıllı Saat:** bağlantı durumu, saat bağlama, saatten gelen sağlık verisi kartları
- [ ] Sayfa 8: **Ayarlar:** geçmiş ve aktif ilaçlar, profil/hesap değişimi, bildirim ayarları, çıkış yap

### 6.3. Veri Modeli ve Bileşen Tasarımı

**Firestore taslağı**

```
users/{uid}
  email, createdAt, language, themeMode
  └── profiles/{profileId}
        name, birthDate, gender, relation (self|mother|father|child),
        avatarKey (otomatik: örn. adult_female)
        ├── medications/{medId}
        │     name, source (api|custom), form, doseAmount, doseUnit,
        │     withFood (before|after|none),
        │     schedule { type, times[], days[] },
        │     startDate, endDate,
        │     stock { remaining, lowThreshold, perDose },
        │     active
        ├── intakeLogs/{logId}
        │     medId, scheduledAt, takenAt,
        │     status (taken|snoozed|skipped|missed)
        └── healthData/{recordId}
              type (heartRate|steps|sleep|...), value, unit, recordedAt, source

medicines/{medicineId}        (ortak ilaç kataloğu: veritabanı + API'den aktarılan)
  name, activeIngredient, form, strength, barcode?
```

**Temel bileşenler**
- `ThemeToggleButton`, `LanguageToggleButton` (tüm AppBar'larda ortak)
- `ProfileAvatar` (yaş + cinsiyetten avatar seçer)
- `MedicationCard` (İçtim / Ertele / Atla)
- `StockIndicator`
- `HealthMetricCard`
- `ProfileSwitcherSheet`

**Avatar seçim kuralı:** `ageGroup(birthDate)` + `gender` → `avatarKey` (örn. `elder_male`)

**Tasarım Teması**

| | Aydınlık Mod | Karanlık Mod |
|---|---|---|
| Arka plan | Beyaz, sade | Siyah |
| Ana renk | Doğa yeşili | Okyanus mavisi |
| Buton | Açık yeşil | Okyanus mavisi tonları |
| Metin | Koyu gri/siyah | Beyaz/açık gri |

Renk kodları tasarım aşamasında belirlenir ve tek bir tema dosyasında tutulur.

### 6.4. Proje Takvimi ve Teslim Aşamaları
- **Aşama 1 (Tasarım & Wireframe):** Kullanıcı akışı, 8 ekranın wireframe'i, tema renkleri, veri modeli, Firebase kurulumu
- **Aşama 2 (Temel Fonksiyonlar & Arayüz):** Giriş/kayıt/şifre sıfırlama, çoklu profil ve otomatik avatar, ilaç ekleme, hatırlatma ve bildirimler, stok takibi, tema ve dil geçişi
- **Aşama 3 (Test & İyileştirme):** İlaç API/veritabanı entegrasyonu, akıllı saat bağlantısı, gerçek cihazda bildirim testi, ayarlar (geçmiş/aktif ilaçlar), hata düzeltme
- **Aşama 4 (Final Teslim):** Cilalama, dokümantasyon, demo

### 6.5. Notlar & Karşılaşılan Zorluklar
- Sağlık verisi KVKK kapsamında özel nitelikli kişisel veridir: Firestore güvenlik kuralları ve açık rıza metni gerekir
- Uygulamada "tıbbi tavsiye değildir, doktorunuza danışın" uyarısı bulunmalıdır
- Android'de tam zamanlı alarm izni ve pil optimizasyonu, iOS'ta yerel bildirim sayısı sınırı dikkate alınmalıdır
- Akıllı saat verisi platforma göre değişir (HealthKit / Health Connect)

### 6.6. Açık Noktalar (Sonraki Promptlarda Tartışılacak)
- İlaç API'si / veri kaynağı seçimi
- Veritabanı yapısının netleştirilmesi
- Yaş grubu sınırları ve avatar tasarımları
- Akıllı saat için hedeflenen platform (Apple Watch, Wear OS, ikisi)
