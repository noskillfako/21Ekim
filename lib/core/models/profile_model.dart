// ==============================================================================
// DOSYA ADI: lib/core/models/profile_model.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Tek bir hesap altında birden fazla aile bireyini (Kendisi, Anne, Baba, Çocuk) temsil eden profil modelidir.
// - Doğum tarihine ve cinsiyete göre otomatik yaş ve avatar (Çocuk, Yetişkin, Yaşlı) hesaplar.
// - Üst Gezinme Çubuğu (AppTopBar), Profil Seçim Ekranı (ProfileSelectionScreen),
//   Profil Oluşturma (ProfileCreateScreen), Profil Değiştirici (ProfileSwitcherSheet) ve
//   Ayarlar (SettingsTab) ekranlarını doğrudan etkiler.
// ==============================================================================

/// Tek bir kullanıcı hesabındaki bir bireyin profilini temsil eden veri modeli.
class ProfileModel {
  final String id;
  final String name;
  final DateTime birthDate;
  final String gender; // 'female' | 'male'
  final String relation; // 'self' | 'mother' | 'father' | 'child'
  final String avatarKey;

  ProfileModel({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.relation,
    String? avatarKey,
  }) : avatarKey = avatarKey ?? computeAvatarKey(birthDate, gender);

  /// Calculates current age based on birthDate
  int get age {
    final now = DateTime.now();
    int calculatedAge = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      calculatedAge--;
    }
    return calculatedAge < 0 ? 0 : calculatedAge;
  }

  /// Categorizes age into groups according to avatarskill.md:
  /// 0-17: child, 18-59: adult, 60+: elder
  String get ageGroup {
    final currentAge = age;
    if (currentAge <= 17) return 'child';
    if (currentAge <= 59) return 'adult';
    return 'elder';
  }

  /// Computes avatarKey = `<ageGroup>_<gender>`
  static String computeAvatarKey(DateTime birthDate, String gender) {
    final now = DateTime.now();
    int currentAge = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      currentAge--;
    }
    final group = currentAge <= 17
        ? 'child'
        : (currentAge <= 59 ? 'adult' : 'elder');
    final g = gender.toLowerCase() == 'male' || gender.toLowerCase() == 'erkek'
        ? 'male'
        : 'female';
    return '${group}_$g';
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? relation,
    String? avatarKey,
  }) {
    final newBirthDate = birthDate ?? this.birthDate;
    final newGender = gender ?? this.gender;
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: newBirthDate,
      gender: newGender,
      relation: relation ?? this.relation,
      avatarKey: avatarKey ?? computeAvatarKey(newBirthDate, newGender),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'gender': gender,
        'relation': relation,
        'avatarKey': avatarKey,
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        gender: json['gender'] as String,
        relation: json['relation'] as String,
        avatarKey: json['avatarKey'] as String?,
      );
}
