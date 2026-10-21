// ==============================================================================
// DOSYA ADI: lib/core/l10n/app_l10n.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Uygulamanın tüm sayfalarında (Giriş, Hatırlatıcı, İlaç Yönetimi, Saat Entegrasyonu,
//   Profil Yönetimi ve Ayarlar) kullanılan metinlerin çift dilli (Türkçe 🇹🇷 / İngilizce 🇬🇧)
//   merkezi yerelleştirme (Localization) motorudur.
// - İlaç sıklıkları (Günde 1 kez -> Once daily), ilaç formları (Şurup -> Syrup) ve
//   doz birimleri (Ölçek -> Spoon) gibi dinamik verileri seçili dile göre dönüştürür.
// - Stok ve son kullanma tarihi rozetleri ile tüm kullanıcı bildirimlerini yerelleştirir.
// ==============================================================================

import 'package:flutter/material.dart';

/// Tüm uygulama boyunca metinlerin Türkçe/İngilizce karşılıklarını sağlayan sınıf.
class AppL10n {
  final Locale locale;
  AppL10n(this.locale);

  /// Verilen BuildContext üzerinden aktif AppL10n örneğini döndürür.
  static AppL10n of(BuildContext context) {
    final l10n = Localizations.of<AppL10n>(context, AppL10n);
    return l10n ?? AppL10n(const Locale('tr'));
  }

  /// Aktif dilin Türkçe olup olmadığını belirten yardımcı bayrak.
  bool get isTr => locale.languageCode == 'tr';

  // General & Top Bar
  String get appTitle => isTr ? 'İlaç Takip Sistemi' : 'Medication Tracker';
  String get medicalDisclaimer => isTr
      ? '⚠️ Bu uygulama tıbbi tavsiye niteliğinde değildir. İlaç kullanımı ve dozajları için mutlaka doktorunuza veya eczacınıza danışınız.'
      : '⚠️ This application is not medical advice. Always consult your doctor or pharmacist for medication and dosage.';
  String get disclaimerShort => isTr ? 'Tıbbi tavsiye değildir' : 'Not medical advice';

  // Navigation
  String get navReminder => isTr ? 'İlaç Hatırlatma' : 'Reminders';
  String get navAddRemove => isTr ? 'İlaç Ekle / Çıkar' : 'Manage Meds';
  String get navWatch => isTr ? 'Akıllı Saat' : 'Smart Watch';
  String get navSettings => isTr ? 'Ayarlar' : 'Settings';

  // Auth
  String get loginTitle => isTr ? 'Giriş Yap' : 'Sign In';
  String get loginSubtitle => isTr ? 'Ailenizin ilaç takibine devam edin' : 'Continue managing family medications';
  String get emailLabel => isTr ? 'E-posta Adresi' : 'Email Address';
  String get passwordLabel => isTr ? 'Şifre' : 'Password';
  String get confirmPasswordLabel => isTr ? 'Şifre Tekrar' : 'Confirm Password';
  String get forgotPassword => isTr ? 'Şifremi Unuttum' : 'Forgot Password?';
  String get loginButton => isTr ? 'Giriş Yap' : 'Sign In';
  String get registerButton => isTr ? 'Kayıt Ol' : 'Sign Up';
  String get dontHaveAccount => isTr ? 'Hesabınız yok mu?' : "Don't have an account?";
  String get alreadyHaveAccount => isTr ? 'Zaten hesabınız var mı?' : 'Already have an account?';
  String get registerTitle => isTr ? 'Yeni Hesap Oluştur' : 'Create New Account';
  String get registerSubtitle => isTr ? 'Tüm aileniz için akıllı sağlık asistanı' : 'Smart health assistant for the whole family';
  String get kvkkConsent => isTr
      ? 'KVKK Açık Rıza Metnini ve Gizlilik Politikasını okudum, sağlık verilerimin işlenmesini onaylıyorum.'
      : 'I have read and agree to the Privacy Policy and consent to health data processing.';
  String get resetPasswordTitle => isTr ? 'Şifre Sıfırlama' : 'Reset Password';
  String get resetPasswordDesc => isTr
      ? 'Kayıtlı e-posta adresinizi giriniz. Şifre sıfırlama bağlantısı gönderilecektir.'
      : 'Enter your registered email address. A password reset link will be sent.';
  String get sendResetLink => isTr ? 'Sıfırlama Bağlantısı Gönder' : 'Send Reset Link';
  String get backToLogin => isTr ? 'Giriş Ekranına Dön' : 'Back to Sign In';
  String get resetEmailSent => isTr ? 'Sıfırlama e-postası başarıyla gönderildi.' : 'Reset email sent successfully.';

  // Profiles
  String get selectProfileTitle => isTr ? 'Profil Seçiniz' : 'Select Profile';
  String get selectProfileSubtitle => isTr
      ? 'Hangi profilin ilaçlarını takip etmek istiyorsunuz?'
      : 'Whose medications do you want to track?';
  String get addNewProfile => isTr ? 'Yeni Profil Ekle' : 'Add New Profile';
  String get createProfileTitle => isTr ? 'Yeni Profil Oluştur' : 'Create Profile';
  String get profileNameLabel => isTr ? 'Ad Soyad' : 'Full Name';
  String get birthDateLabel => isTr ? 'Doğum Tarihi' : 'Date of Birth';
  String get genderLabel => isTr ? 'Cinsiyet' : 'Gender';
  String get genderFemale => isTr ? 'Kadın' : 'Female';
  String get genderMale => isTr ? 'Erkek' : 'Male';
  String get relationLabel => isTr ? 'Yakınlık Derecesi' : 'Relation';
  String get relationSelf => isTr ? 'Kendisi' : 'Self';
  String get relationMother => isTr ? 'Anne' : 'Mother';
  String get relationFather => isTr ? 'Baba' : 'Father';
  String get relationChild => isTr ? 'Çocuk' : 'Child';
  String get saveProfileButton => isTr ? 'Profili Kaydet' : 'Save Profile';
  String get switchProfile => isTr ? 'Profili Değiştir' : 'Switch Profile';
  String get editProfile => isTr ? 'Profili Düzenle' : 'Edit Profile';
  String get deleteProfile => isTr ? 'Profili Sil' : 'Delete Profile';
  String get deleteProfileTitle => isTr ? 'Profili Sil' : 'Delete Profile';
  String deleteProfileConfirm(String name) => isTr
      ? '"$name" profilini ve bu profile ait tüm ilaçları ve geçmiş kayıtları silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'
      : 'Are you sure you want to delete "$name" and all associated medications and history logs? This action cannot be undone.';
  String get deleteProfileMinWarning => isTr
      ? 'Hesapta en az bir profil bulunmalıdır. Bu profili silmeden önce lütfen yeni bir profil ekleyin.'
      : 'At least one profile must exist in the account. Please create another profile before deleting this one.';
  String profileDeletedSuccess(String name) => isTr
      ? '"$name" profili başarıyla silindi.'
      : '"$name" profile deleted successfully.';

  // Avatar Roles
  String get avatarChildFemale => isTr ? 'Kız Çocuk' : 'Child (Girl)';
  String get avatarChildMale => isTr ? 'Erkek Çocuk' : 'Child (Boy)';
  String get avatarAdultFemale => isTr ? 'Yetişkin Kadın' : 'Adult (Female)';
  String get avatarAdultMale => isTr ? 'Yetişkin Erkek' : 'Adult (Male)';
  String get avatarElderFemale => isTr ? 'Yaşlı Kadın' : 'Senior (Female)';
  String get avatarElderMale => isTr ? 'Yaşlı Erkek' : 'Senior (Male)';

  // Today Timeline (Sekme 1)
  String get todayTimelineTitle => isTr ? 'Bugünün İlaçları' : "Today's Schedule";
  String get noMedsForToday => isTr
      ? 'Bugün için planlanmış ilaç bulunmuyor.'
      : 'No medications scheduled for today.';
  String get actionTake => isTr ? 'İçtim' : 'Take';
  String get actionSnooze => isTr ? 'Ertele' : 'Snooze';
  String get actionSkip => isTr ? 'Atla' : 'Skip';
  String get statusPending => isTr ? 'Bekliyor' : 'Pending';
  String get statusTaken => isTr ? 'İçildi' : 'Taken';
  String get statusSnoozed => isTr ? 'Ertelendi (10 dk)' : 'Snoozed (10m)';
  String get statusSkipped => isTr ? 'Atlandı' : 'Skipped';
  String get statusMissed => isTr ? 'Kaçırıldı' : 'Missed';
  String get withFoodBefore => isTr ? 'Aç Karna' : 'Before Meal';
  String get withFoodAfter => isTr ? 'Tok Karna' : 'After Meal';
  String get withFoodNone => isTr ? 'Farketmez' : 'Anytime';
  String get stockRemainingText => isTr ? 'Kalan' : 'Remaining';
  String get lowStockWarning => isTr ? 'Kutu Azaldı!' : 'Low Stock!';
  String get outOfStockWarning => isTr ? 'Kutu Bitti!' : 'Out of Stock!';
  String get refillStock => isTr ? 'Kutu Yenile' : 'Refill';

  // Medication Add / Remove (Sekme 2)
  String get medSearchHint => isTr
      ? 'İlaç adı veya barkod arayın (örn. Aspirin, Parol, Cipro)...'
      : 'Search drug name or barcode (e.g. Aspirin, Parol)...';
  String get searchingBoth => isTr
      ? 'İlaç kataloğu taranıyor...'
      : 'Searching medication catalog...';
  String get localSourceBadge => isTr ? 'Yerel Katalog' : 'Local Catalog';
  String get globalApiBadge => isTr ? 'Global API (OpenFDA)' : 'Global API';
  String get notInListAddCustom => isTr
      ? 'Listede yok mu? Yeni İlaç Olarak Ekle'
      : 'Not in list? Add as Custom Medicine';
  String get customMedFormTitle => isTr ? 'İlaç Bilgileri' : 'Medication Details';
  String get drugNameLabel => isTr ? 'İlaç Adı' : 'Medicine Name';
  String get drugFormLabel => isTr ? 'Formu' : 'Form';
  String get doseAmountLabel => isTr ? 'Doz Miktarı' : 'Dose Amount';
  String get doseUnitLabel => isTr ? 'Doz Birimi' : 'Dose Unit';
  String get frequencyLabel => isTr ? 'Kullanım Sıklığı' : 'Frequency';
  String get timesLabel => isTr ? 'Kullanım Saatleri' : 'Intake Times';
  String get addTime => isTr ? 'Saat Ekle' : 'Add Time';
  String get stockRemainingLabel => isTr ? 'Başlangıç Stok Adedi' : 'Initial Stock';
  String get lowThresholdLabel => isTr ? 'Kutu Azaldı Eşiği' : 'Low Stock Threshold';
  String get perDoseLabel => isTr ? 'Doz Başına Düşecek Adet' : 'Amount Per Dose';
  String get expiryDateLabel => isTr ? 'Son Kullanma Tarihi (SKT)' : 'Expiration Date';
  String get treatmentDatesLabel => isTr ? 'Tedavi Süresi' : 'Treatment Duration';
  String get startDateLabel => isTr ? 'Başlangıç Tarihi' : 'Start Date';
  String get endDateLabel => isTr ? 'Bitiş Tarihi (Opsiyonel)' : 'End Date (Optional)';
  String get saveMedicationButton => isTr ? 'İlacı Kaydet' : 'Save Medication';
  String get currentMedsTitle => isTr ? 'Kayıtlı İlaçlar' : 'Registered Medications';
  String get removeMedication => isTr ? 'İlacı Çıkar' : 'Deactivate Medicine';
  String get removeMedConfirm => isTr
      ? 'Bu ilacı aktif kullanımdan çıkarmak istiyor musunuz? İlaç geçmiş kayıtlarda saklanacaktır.'
      : 'Do you want to deactivate this medication? It will be preserved in history.';
  String get noActiveMeds => isTr
      ? 'Henüz eklenmiş aktif bir ilaç yok. Yukarıdaki arama kutusundan ekleyebilirsiniz.'
      : 'No active medications yet. Search above to add one.';

  // SKT / Expiry
  String get expiryValid => isTr ? 'SKT Geçerli' : 'Expiry OK';
  String get expirySoon => isTr ? 'SKT Yaklaşıyor' : 'Expiring Soon';
  String get expiryExpired => isTr ? 'SKT Dolmuş' : 'Expired';
  String expiryBadgeValid(String date) => isTr ? 'SKT: $date' : 'EXP: $date';
  String expiryBadgeSoon(String date, int days) => isTr ? 'SKT Yakında ($date - $days gün)' : 'Expiring Soon ($date - $days days)';
  String expiryBadgeExpired(String date) => isTr ? 'SKT Dolmuş ($date)' : 'Expired ($date)';

  // Smart Watch (Sekme 3)
  String get watchTabTitle => isTr ? 'Akıllı Saat Entegrasyonu' : 'Smart Watch Sync';
  String get watchStatusConnected => isTr ? 'Akıllı Saat Bağlı' : 'Smart Watch Connected';
  String get watchStatusDisconnected => isTr ? 'Akıllı Saat Bağlı Değil' : 'No Watch Connected';
  String get connectWatch => isTr ? 'Akıllı Saati Bağla' : 'Connect Smart Watch';
  String get disconnectWatch => isTr ? 'Bağlantıyı Kes' : 'Disconnect Watch';
  String get metricHeartRate => isTr ? 'Nabız / Kalp Atışı' : 'Heart Rate';
  String get metricSteps => isTr ? 'Günlük Adım' : 'Daily Steps';
  String get metricSleep => isTr ? 'Uyku Süresi' : 'Sleep Duration';
  String get metricSpo2 => isTr ? 'Kandaki Oksijen (SpO2)' : 'Oxygen (SpO2)';
  String get watchGuideTitle => isTr ? 'Saat Bağlantı Rehberi' : 'Watch Pairing Guide';
  String get watchGuideDesc => isTr
      ? 'Apple HealthKit veya Google Health Connect üzerinden akıllı saatinizdeki nabız, uyku ve adım verilerini profilinizle senkronize edebilirsiniz.'
      : 'Sync heart rate, sleep, and steps from Apple HealthKit or Google Health Connect with your profile.';
  String get liveHealthMetrics => isTr ? 'Canlı Sağlık Göstergeleri' : 'Live Health Metrics';
  String forProfileHealthData(String name) => isTr ? '$name için sağlık verileri' : 'Health metrics for $name';
  String get privacyDisclaimer => isTr
      ? 'Sağlık verileri KVKK kapsamında gizli tutulur ve yalnızca seçili profil altında görüntülenir.'
      : 'Health data is kept private in accordance with GDPR/KVKK and only visible for the selected profile.';

  // Settings (Sekme 4)
  String get activeMedsSection => isTr ? 'Aktif İlaçlar' : 'Active Medications';
  String get pastMedsSection => isTr ? 'Geçmiş / Pasif İlaçlar' : 'Past Medications';
  String get reactivateMed => isTr ? 'Yeniden Aktif Et' : 'Reactivate';
  String get noPastMeds => isTr ? 'Geçmiş ilaç kaydı bulunmuyor.' : 'No past medications.';
  String get notificationSettings => isTr ? 'Bildirim Tercihleri' : 'Notification Preferences';
  String get snoozeDurationLabel => isTr ? 'Erteleme Süresi' : 'Snooze Duration';
  String get missedThresholdLabel => isTr ? 'Kaçırıldı İşaretleme Süresi' : 'Mark as Missed After';
  String get minutes => isTr ? 'dakika' : 'minutes';
  String get minShort => isTr ? 'dk' : 'min';
  String get hoursShort => isTr ? 'saat' : 'hrs';
  String get accountSection => isTr ? 'Hesap ve Profil' : 'Account & Profile';
  String get switchAccount => isTr ? 'Hesap Değiştir' : 'Switch Account';
  String get logoutButton => isTr ? 'Çıkış Yap' : 'Sign Out';
  String get appVersion => isTr ? 'Sürüm 1.0.0 (Hibrit API & Yerel Veri)' : 'Version 1.0.0 (Hybrid API & Local)';
  String get logoutConfirmMessage => isTr
      ? 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?'
      : 'Are you sure you want to log out?';

  // Language & Theme Settings
  String get languageSection => isTr ? 'Uygulama Dili' : 'Application Language';
  String get languageOptionTurkish => isTr ? 'Türkçe' : 'Turkish';
  String get languageOptionEnglish => isTr ? 'İngilizce' : 'English';
  String get themeSection => isTr ? 'Görünüm & Tema' : 'Appearance & Theme';
  String get themeDark => isTr ? 'Karanlık Mod' : 'Dark Mode';
  String get themeLight => isTr ? 'Aydınlık Mod' : 'Light Mode';

  // Common Units & Actions
  String get cancel => isTr ? 'Vazgeç' : 'Cancel';
  String get confirm => isTr ? 'Onayla' : 'Confirm';
  String get delete => isTr ? 'Sil' : 'Delete';
  String get close => isTr ? 'Kapat' : 'Close';
  String get add => isTr ? 'Ekle' : 'Add';
  String get change => isTr ? 'Değiştir' : 'Change';
  String get selectDate => isTr ? 'Tarih Seç' : 'Select Date';
  String get notSelected => isTr ? 'Seçilmedi (Opsiyonel)' : 'Not selected (Optional)';
  String get units => isTr ? 'adet' : 'units';
  String get yearsOld => isTr ? 'yaşında' : 'years old';
  String get ageYears => isTr ? 'yaş' : 'yrs';
  String get passive => isTr ? 'Pasif' : 'Inactive';
  String get active => isTr ? 'Aktif' : 'Active';
  String get clear => isTr ? 'Temizle' : 'Clear';
  String get foodRelationLabel => isTr ? 'Açlık / Tokluk Durumu' : 'Meal Relation';
  String get automaticAvatarLabel => isTr ? 'Otomatik Avatar' : 'Automatic Avatar';

  // Stock Indicator strings
  String stockPiecesLeft(int count) => isTr ? '$count adet kaldı' : '$count units remaining';
  String stockLowAlert(int count) => isTr ? 'Kutu Azaldı ($count kaldı)' : 'Low Stock ($count remaining)';
  String get stockEmptyAlert => isTr ? 'Kutu Bitti!' : 'Out of Stock!';
  String get stockRefillAction => isTr ? '+ Kutu Yenile' : '+ Refill';

  // Refill Dialog
  String get refillTitle => isTr ? 'Kutu Yenile' : 'Refill Stock';
  String refillPrompt(String medName) => isTr ? '$medName için eklenecek adet miktarını giriniz:' : 'Enter amount to add for $medName:';
  String get refillAmountLabel => isTr ? 'Eklenecek Adet' : 'Amount to Add';
  String refillSuccess(String name, int newTotal) => isTr ? '$name kutusu yenilendi! (Yeni stok: $newTotal)' : '$name stock refilled! (New total: $newTotal)';

  // View Modes & Timeline
  String get viewModeMedication => isTr ? 'İlaç Bazlı' : 'By Medicine';
  String get viewModeTimeline => isTr ? 'Zaman Çizelgesi' : 'Timeline';
  String get dosesToday => isTr ? 'Bugünün Dozları' : "Today's Doses";
  String doseNumber(int num) => isTr ? '$num. Doz' : 'Dose $num';

  // Notifications & Alerts
  String get duplicateTitle => isTr ? 'Mevcut İlaç Uyarısı' : 'Medication Already Exists';
  String duplicateMedicationWarning(String name) => isTr
      ? '"$name" zaten kayıtlı ilaçlarınız arasında bulunuyor. Yine de eklemek istiyor musunuz?'
      : '"$name" is already in your registered medications. Do you want to add it anyway?';
  String medicationAddedSuccess(String name) => isTr ? '$name başarıyla eklendi!' : '$name added successfully!';
  String medicationReactivatedSuccess(String name) => isTr ? '$name tekrar aktif ilaçlara eklendi!' : '$name reactivated successfully!';
  String medicationDeactivatedSuccess(String name) => isTr ? '$name geçmiş ilaçlara taşındı.' : '$name moved to past medications.';
  String medicationTakenSuccess(String name, int remaining) => isTr
      ? '$name içildi olarak kaydedildi. (Kalan stok: $remaining)'
      : '$name recorded as taken. (Remaining: $remaining)';
  String medicationSnoozed(int mins) => isTr ? 'İlaç $mins dakika ertelendi.' : 'Medication snoozed for $mins minutes.';
  String get medicationSkipped => isTr
      ? 'Doz atlandı olarak işaretlendi (stok düşülmedi).'
      : 'Dose marked as skipped (stock not decremented).';
  String profileCreatedSuccess(String name) => isTr ? '$name profili başarıyla oluşturuldu!' : '$name profile created successfully!';
  String selectedDrugInfo(String name, String source) => isTr ? 'Seçildi: $name ($source)' : 'Selected: $name ($source)';
  String searchResultsCount(int total, int local, int api) => isTr
      ? (api > 0 ? '$total sonuç ($local Yerel, $api OpenFDA)' : '$total sonuç ($local Yerel Katalog)')
      : (api > 0 ? '$total results ($local Local, $api OpenFDA)' : '$total results ($local Local Catalog)');
  String noDrugFound(String query) => isTr
      ? '"$query" için eşleşen ilaç bulunamadı.'
      : 'No medications found for "$query".';



  // Medication Attributes Formatting
  String formatFrequency(String frequency) {
    if (isTr) return frequency;
    final lower = frequency.toLowerCase().trim();
    if (lower.contains('1 kez') || lower == 'günde 1' || lower == 'once daily') {
      return 'Once daily';
    } else if (lower.contains('2 kez') || lower == 'günde 2' || lower == 'twice daily') {
      return 'Twice daily';
    } else if (lower.contains('3 kez') || lower == 'günde 3') {
      return '3 times daily';
    } else if (lower.contains('4 kez') || lower == 'günde 4') {
      return '4 times daily';
    } else if (lower.contains('gün aşırı') || lower.contains('every other day')) {
      return 'Every other day';
    } else if (lower.contains('ihtiyaç') || lower.contains('as needed')) {
      return 'As needed';
    }
    return frequency;
  }

  String formatDoseUnit(String unit) {
    if (isTr) return unit;
    final lower = unit.toLowerCase().trim();
    if (lower == 'adet' || lower == 'tane') return 'Unit';
    if (lower == 'ölçek' || lower == 'olcek') return 'Spoon';
    if (lower == 'damla') return 'Drop';
    if (lower == 'doz') return 'Dose';
    if (lower == 'tablet') return 'Tablet';
    if (lower == 'kapsül' || lower == 'kapsul') return 'Capsule';
    return unit;
  }

  String formatForm(String form) {
    if (isTr) return form;
    final lower = form.toLowerCase().trim();
    if (lower == 'tablet') return 'Tablet';
    if (lower == 'kapsül' || lower == 'kapsul') return 'Capsule';
    if (lower == 'şurup' || lower == 'surup') return 'Syrup';
    if (lower.contains('iğne') || lower.contains('igne') || lower.contains('ampul') || lower.contains('enj')) return 'Injection';
    if (lower == 'damla') return 'Drops';
    if (lower.contains('merhem') || lower.contains('krem') || lower.contains('jel')) return 'Ointment / Cream';
    if (lower == 'sprey') return 'Spray';
    return form;
  }

  // Error Messages
  String get errorGeneric => isTr ? 'Bir hata oluştu. Lütfen tekrar deneyin.' : 'An error occurred. Please try again.';
  String get errorEmptyQuery => isTr ? 'Lütfen aramak için bir ilaç adı yazın.' : 'Please enter a drug name to search.';
  String get errorRequiredField => isTr ? 'Bu alan zorunludur' : 'This field is required';
}

class AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const AppL10nDelegate();

  @override
  bool isSupported(Locale locale) => ['tr', 'en'].contains(locale.languageCode);

  @override
  Future<AppL10n> load(Locale locale) async => AppL10n(locale);

  @override
  bool shouldReload(AppL10nDelegate old) => true;
}
