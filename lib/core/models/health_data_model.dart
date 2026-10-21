// ==============================================================================
// DOSYA ADI: lib/core/models/health_data_model.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Akıllı saat (Apple HealthKit / Google Health Connect) entegrasyonu sağlık verilerini temsil eden modeldir.
// - Nabız (bpm), Günlük Adım, Uyku Süresi (saat), Kandaki Oksijen (SpO2) ve bağlantı durumunu saklar.
// - Akıllı Saat sekmesini (SmartWatchTab) ve HealthMetricCard bileşenlerini doğrudan etkiler.
// ==============================================================================

/// Seçili profile ait akıllı saat sağlık metriklerini temsil eden veri modeli.
class HealthDataModel {
  final String id;
  final String profileId;
  final int heartRate; // bpm (nabız)
  final int steps; // adım
  final double sleepHours; // uyku saati
  final int spo2; // kan oksijen yüzdesi (%)
  final DateTime recordedAt;
  final bool isWatchConnected;

  const HealthDataModel({
    required this.id,
    required this.profileId,
    required this.heartRate,
    required this.steps,
    required this.sleepHours,
    required this.spo2,
    required this.recordedAt,
    this.isWatchConnected = false,
  });

  HealthDataModel copyWith({
    String? id,
    String? profileId,
    int? heartRate,
    int? steps,
    double? sleepHours,
    int? spo2,
    DateTime? recordedAt,
    bool? isWatchConnected,
  }) {
    return HealthDataModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      heartRate: heartRate ?? this.heartRate,
      steps: steps ?? this.steps,
      sleepHours: sleepHours ?? this.sleepHours,
      spo2: spo2 ?? this.spo2,
      recordedAt: recordedAt ?? this.recordedAt,
      isWatchConnected: isWatchConnected ?? this.isWatchConnected,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'profileId': profileId,
        'heartRate': heartRate,
        'steps': steps,
        'sleepHours': sleepHours,
        'spo2': spo2,
        'recordedAt': recordedAt.toIso8601String(),
        'isWatchConnected': isWatchConnected,
      };

  factory HealthDataModel.fromJson(Map<String, dynamic> json) => HealthDataModel(
        id: json['id'] as String,
        profileId: json['profileId'] as String,
        heartRate: json['heartRate'] as int? ?? 72,
        steps: json['steps'] as int? ?? 6540,
        sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 7.5,
        spo2: json['spo2'] as int? ?? 98,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        isWatchConnected: json['isWatchConnected'] as bool? ?? false,
      );
}
