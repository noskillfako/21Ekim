// ==============================================================================
// DOSYA ADI: lib/core/widgets/app_top_bar.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Tüm sayfalarda kullanılan ortak, standart üst başlık çubuğudur (AppBar).
// - Sayfa başlığı, aktif profil avatarı ve ismi, hızlı tema değiştirici (Güneş/Ay)
//   ve hızlı dil değiştirici (TR/EN) butonlarını barındırır.
// - Kullanıcı profilinin tek bir yerde, en üst barda derli toplu kalmasını sağlar.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import 'profile_avatar.dart';

/// Standart üst çubuk (AppBar) bileşeni.
class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showProfileAvatar;
  final VoidCallback? onProfileTap;
  final List<Widget>? extraActions;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBackPressed,
    this.showProfileAvatar = true,
    this.onProfileTap,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final activeProfile = ref.watch(activeProfileProvider);

    final isDark = themeMode == ThemeMode.dark;
    final isTr = locale.languageCode == 'tr';

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
              tooltip: isTr ? 'Geri' : 'Back',
            )
          : (showProfileAvatar && activeProfile != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Center(
                    child: ProfileAvatar(
                      avatarKey: activeProfile.avatarKey,
                      radius: 18,
                      onTap: onProfileTap,
                    ),
                  ),
                )
              : null),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontWeight: FontWeight.normal,
              ),
            )
          else if (showProfileAvatar && activeProfile != null)
            Text(
              activeProfile.name,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      actions: [
        ...?extraActions,

        // Theme Toggle Button
        IconButton(
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggle();
          },
          tooltip: isDark
              ? (isTr ? 'Aydınlık Mod' : 'Light Mode')
              : (isTr ? 'Karanlık Mod' : 'Dark Mode'),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              color: isDark ? const Color(0xFFFFD166) : theme.colorScheme.primary,
              size: 22,
            ),
          ),
        ),

        // Language Toggle Button (TR / EN)
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 4),
          child: InkWell(
            onTap: () {
              ref.read(localeProvider.notifier).toggle();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isTr ? '🇹🇷 TR' : '🇬🇧 EN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
