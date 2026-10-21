// ==============================================================================
// DOSYA ADI: lib/core/widgets/profile_avatar.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Profil yaş ve cinsiyetine göre hesaplanan 6 farklı avatar rolünü (Kız/Erkek Çocuk, Kadın/Erkek Yetişkin, Yaşlı Kadın/Erkek) görselleştirir.
// - SVG/Emoji ve renkli daire tabanlı görselleştirme sağlar.
// - Üst Çubuk (AppTopBar), Profil Seçimi (ProfileSelectionScreen), Profil Değiştirici (ProfileSwitcherSheet)
//   ve Ayarlar (SettingsTab) ekranlarını doğrudan etkiler.
// ==============================================================================

import 'package:flutter/material.dart';

/// Profil avatarlarını otomatik rol anahtarına göre çizen widget.
class ProfileAvatar extends StatelessWidget {
  final String avatarKey;
  final double radius;
  final bool showBorder;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.avatarKey,
    this.radius = 24,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final avatarData = _getAvatarData(avatarKey, isDark);

    Widget avatarContent = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [avatarData.bgGradientStart, avatarData.bgGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: showBorder
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.6),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: avatarData.bgGradientStart.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          avatarData.emoji,
          style: TextStyle(fontSize: radius * 1.05),
        ),
      ),
    );

    if (onTap != null) {
      avatarContent = InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  _AvatarData _getAvatarData(String key, bool isDark) {
    switch (key.toLowerCase()) {
      case 'child_female':
        return _AvatarData(
          emoji: '👧',
          label: 'Kız Çocuk',
          bgGradientStart: isDark ? const Color(0xFF6B2A4A) : const Color(0xFFFCE4EC),
          bgGradientEnd: isDark ? const Color(0xFF880E4F) : const Color(0xFFF8BBD0),
        );
      case 'child_male':
        return _AvatarData(
          emoji: '👦',
          label: 'Erkek Çocuk',
          bgGradientStart: isDark ? const Color(0xFF1A3B5C) : const Color(0xFFE1F5FE),
          bgGradientEnd: isDark ? const Color(0xFF0277BD) : const Color(0xFFB3E5FC),
        );
      case 'adult_female':
        return _AvatarData(
          emoji: '👩',
          label: 'Yetişkin Kadın',
          bgGradientStart: isDark ? const Color(0xFF4A148C) : const Color(0xFFF3E5F5),
          bgGradientEnd: isDark ? const Color(0xFF7B1FA2) : const Color(0xFFE1BEE7),
        );
      case 'adult_male':
        return _AvatarData(
          emoji: '👨',
          label: 'Yetişkin Erkek',
          bgGradientStart: isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9),
          bgGradientEnd: isDark ? const Color(0xFF2E7D32) : const Color(0xFFC8E6C9),
        );
      case 'elder_female':
        return _AvatarData(
          emoji: '👵',
          label: 'Yaşlı Kadın',
          bgGradientStart: isDark ? const Color(0xFF4E342E) : const Color(0xFFEFEBE9),
          bgGradientEnd: isDark ? const Color(0xFF6D4C41) : const Color(0xFFD7CCC8),
        );
      case 'elder_male':
        return _AvatarData(
          emoji: '👴',
          label: 'Yaşlı Erkek',
          bgGradientStart: isDark ? const Color(0xFF263238) : const Color(0xFFECEFF1),
          bgGradientEnd: isDark ? const Color(0xFF37474F) : const Color(0xFFCFD8DC),
        );
      default:
        return _AvatarData(
          emoji: '👤',
          label: 'Profil',
          bgGradientStart: isDark ? const Color(0xFF263238) : const Color(0xFFE0E0E0),
          bgGradientEnd: isDark ? const Color(0xFF37474F) : const Color(0xFFBDBDBD),
        );
    }
  }
}

class _AvatarData {
  final String emoji;
  final String label;
  final Color bgGradientStart;
  final Color bgGradientEnd;

  _AvatarData({
    required this.emoji,
    required this.label,
    required this.bgGradientStart,
    required this.bgGradientEnd,
  });
}
