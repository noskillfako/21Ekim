// ==============================================================================
// DOSYA ADI: lib/core/models/intake_log_model.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - İlaç içilme, ertelenme, atlanma ve kaçırılma eylemlerini gün ve saat bazında kaydeden log modelidir.
// - Bugünün İlaçları sekmesindeki (TodayTimelineTab) doz rozetlerini, buton durumlarını ve
//   saat bazlı ilerleme yüzdelerini (ör. 3/4 İçildi) doğrudan etkiler.
// - Bir profil silindiğinde o profile ait tüm geçmiş kayıtların cascade temizlenmesinde kullanılır.
// ==============================================================================

/// Bir ilacın planlanan dozuna ait kullanım hareketini temsil eden veri modeli.
class IntakeLogModel {
  final String id;
  final String medicationId;
  final String profileId;
  final String dateKey; // YYYY-MM-DD
  final String scheduledTime; // e.g. "08:00"
  final DateTime? takenAt;
  final String status; // 'pending' | 'taken' | 'snoozed' | 'skipped' | 'missed'

  const IntakeLogModel({
    required this.id,
    required this.medicationId,
    required this.profileId,
    required this.dateKey,
    required this.scheduledTime,
    this.takenAt,
    required this.status,
  });

  bool get isTaken => status == 'taken';
  bool get isSnoozed => status == 'snoozed';
  bool get isSkipped => status == 'skipped';
  bool get isMissed => status == 'missed';
  bool get isPending => status == 'pending';

  IntakeLogModel copyWith({
    String? id,
    String? medicationId,
    String? profileId,
    String? dateKey,
    String? scheduledTime,
    DateTime? takenAt,
    String? status,
  }) {
    return IntakeLogModel(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      profileId: profileId ?? this.profileId,
      dateKey: dateKey ?? this.dateKey,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenAt: takenAt ?? this.takenAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicationId': medicationId,
        'profileId': profileId,
        'dateKey': dateKey,
        'scheduledTime': scheduledTime,
        'takenAt': takenAt?.toIso8601String(),
        'status': status,
      };

  factory IntakeLogModel.fromJson(Map<String, dynamic> json) => IntakeLogModel(
        id: json['id'] as String,
        medicationId: json['medicationId'] as String,
        profileId: json['profileId'] as String,
        dateKey: json['dateKey'] as String,
        scheduledTime: json['scheduledTime'] as String,
        takenAt: json['takenAt'] != null ? DateTime.parse(json['takenAt'] as String) : null,
        status: json['status'] as String,
      );
}
