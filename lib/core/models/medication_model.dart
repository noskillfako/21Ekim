// ==============================================================================
// DOSYA ADI: lib/core/models/medication_model.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Sisteme eklenen tüm ilaçların merkezi veri modelidir.
// - İlaç adı, kaynak (Yerel/OpenFDA/Özel), barkod, form (tablet/şurup/kapsül), doz miktarı ve birimi,
//   açlık/tokluk durumu, saatleri, sıklığı, stok miktarı, kritik eşik ve SKT (Son Kullanma Tarihi) bilgilerini tutar.
// - Bugünün İlaçları (TodayTimelineTab), İlaç Ekleme/Çıkarma (MedicationAddTab) ve
//   Ayarlar (SettingsTab) ekranlarındaki tüm aktif/geçmiş ilaç listelemelerini doğrudan yönetir.
// ==============================================================================

/// Profile kayıtlı bir ilacı ve tüm tedavi parametrelerini temsil eden ana veri modeli.
class MedicationModel {
  final String id;
  final String profileId;
  final String name;
  final String source; // 'api' | 'local' | 'custom'
  final String? barcode;
  final String form; // 'Tablet', 'Kapsül', 'Şurup', 'İğne', 'Damla', 'Merhem', 'Sprey'
  final double doseAmount;
  final String doseUnit; // 'Adet', 'Ölçek', 'Damla', 'mg', 'ml', 'Doz'
  final String withFood; // 'before' (Aç), 'after' (Tok), 'none' (Farketmez)
  final List<String> times; // e.g. ['08:00', '20:00']
  final String frequency; // 'Günde 1 kez', 'Günde 2 kez', etc.
  final DateTime treatmentStartDate;
  final DateTime? treatmentEndDate;
  final DateTime? expiryDate; // SKT
  final int stockRemaining;
  final int lowThreshold;
  final int perDose;
  final bool active; // true: aktif, false: geçmiş ilaç (soft delete)

  const MedicationModel({
    required this.id,
    required this.profileId,
    required this.name,
    this.source = 'custom',
    this.barcode,
    this.form = 'Tablet',
    this.doseAmount = 1.0,
    this.doseUnit = 'Adet',
    this.withFood = 'after',
    required this.times,
    this.frequency = 'Günde 1 kez',
    required this.treatmentStartDate,
    this.treatmentEndDate,
    this.expiryDate,
    this.stockRemaining = 30,
    this.lowThreshold = 5,
    this.perDose = 1,
    this.active = true,
  });

  bool get isOutOfStock => stockRemaining <= 0;
  bool get isLowStock => stockRemaining > 0 && stockRemaining <= lowThreshold;

  /// Expiry status according to ilactarihkontrolskill:
  /// 'valid', 'expiringSoon' (30 days or less), 'expired'
  String get expiryStatus {
    if (expiryDate == null) return 'valid';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);

    if (expiry.isBefore(today)) {
      return 'expired';
    }
    final difference = expiry.difference(today).inDays;
    if (difference <= 30) {
      return 'expiringSoon';
    }
    return 'valid';
  }

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiry.difference(today).inDays;
  }

  MedicationModel copyWith({
    String? id,
    String? profileId,
    String? name,
    String? source,
    String? barcode,
    String? form,
    double? doseAmount,
    String? doseUnit,
    String? withFood,
    List<String>? times,
    String? frequency,
    DateTime? treatmentStartDate,
    DateTime? treatmentEndDate,
    DateTime? expiryDate,
    int? stockRemaining,
    int? lowThreshold,
    int? perDose,
    bool? active,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      source: source ?? this.source,
      barcode: barcode ?? this.barcode,
      form: form ?? this.form,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      withFood: withFood ?? this.withFood,
      times: times ?? this.times,
      frequency: frequency ?? this.frequency,
      treatmentStartDate: treatmentStartDate ?? this.treatmentStartDate,
      treatmentEndDate: treatmentEndDate ?? this.treatmentEndDate,
      expiryDate: expiryDate ?? this.expiryDate,
      stockRemaining: stockRemaining ?? this.stockRemaining,
      lowThreshold: lowThreshold ?? this.lowThreshold,
      perDose: perDose ?? this.perDose,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'profileId': profileId,
        'name': name,
        'source': source,
        'barcode': barcode,
        'form': form,
        'doseAmount': doseAmount,
        'doseUnit': doseUnit,
        'withFood': withFood,
        'times': times,
        'frequency': frequency,
        'treatmentStartDate': treatmentStartDate.toIso8601String(),
        'treatmentEndDate': treatmentEndDate?.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'stockRemaining': stockRemaining,
        'lowThreshold': lowThreshold,
        'perDose': perDose,
        'active': active,
      };

  factory MedicationModel.fromJson(Map<String, dynamic> json) => MedicationModel(
        id: json['id'] as String,
        profileId: json['profileId'] as String,
        name: json['name'] as String,
        source: json['source'] as String? ?? 'custom',
        barcode: json['barcode'] as String?,
        form: json['form'] as String? ?? 'Tablet',
        doseAmount: (json['doseAmount'] as num?)?.toDouble() ?? 1.0,
        doseUnit: json['doseUnit'] as String? ?? 'Adet',
        withFood: json['withFood'] as String? ?? 'after',
        times: (json['times'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['08:00'],
        frequency: json['frequency'] as String? ?? 'Günde 1 kez',
        treatmentStartDate: DateTime.parse(json['treatmentStartDate'] as String),
        treatmentEndDate: json['treatmentEndDate'] != null ? DateTime.parse(json['treatmentEndDate'] as String) : null,
        expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : null,
        stockRemaining: json['stockRemaining'] as int? ?? 30,
        lowThreshold: json['lowThreshold'] as int? ?? 5,
        perDose: json['perDose'] as int? ?? 1,
        active: json['active'] as bool? ?? true,
      );
}
