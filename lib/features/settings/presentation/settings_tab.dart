// ==============================================================================
// DOSYA ADI: lib/features/settings/presentation/settings_tab.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Ekran 8 (Ayarlar, Tercihler ve Tedavisi Biten İlaçlar) arayüzünü oluşturur.
// - Aktif profil bilgilerini gösterir, profil değiştirme ve profil silme işlemlerini tetikler.
// - Dil tercihi (Türkçe / İngilizce) ve Tema modu (Aydınlık / Karanlık) seçimini yönetir.
// - Hatırlatma erteleme süresi (10, 15, 30 dk) ve bildirim ses/titreşim ayarlarını yapılandırır.
// - Geçmiş / pasife alınmış ilaçları listeler ve tekrar aktif tedaviye geri alma seçeneği sunar.
// - Oturumu sonlandırma (Logout) ve KVKK & Gizlilik politikasını içerir.
// - Ana Gezinme Ekranı'nın (MainNavigationScreen) 4. sekmesi olarak çalışır.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../profile/presentation/widgets/profile_switcher_sheet.dart';

/// [SettingsTab] uygulama ayarları, dil/tema tercihleri ve geçmiş ilaçlar sekmesi bileşeni.
class SettingsTab extends ConsumerWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onNavigateToProfileSelect;

  const SettingsTab({
    super.key,
    this.onLogout,
    this.onNavigateToProfileSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    final activeProfile = ref.watch(activeProfileProvider);
    final activeMeds = ref.watch(activeMedsForCurrentProfileProvider);
    final pastMeds = ref.watch(pastMedsForCurrentProfileProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Screen Title
          Text(
            l10n.navSettings,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 16),

          // 1. Current Profile Card & Switcher
          if (activeProfile != null)
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ProfileAvatar(
                      avatarKey: activeProfile.avatarKey,
                      radius: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeProfile.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${activeProfile.age} ${l10n.yearsOld} • ${_getRelationText(activeProfile.relation, l10n)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onPressed: () {
                            ProfileSwitcherSheet.show(context);
                          },
                          child: Text(l10n.switchProfile),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                          tooltip: l10n.deleteProfile,
                          onPressed: () => _confirmDeleteProfile(context, ref, activeProfile, l10n),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),

          // 2. Language & Theme Section (Dil ve Görünüm Ayarları)
          _buildSectionHeader(context, l10n.languageSection, Icons.language_rounded),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            child: Column(
              children: [
                // Language Selection Segmented Control
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.translate_rounded, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.languageSection,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLanguagePill(
                              context: context,
                              ref: ref,
                              code: 'tr',
                              flag: '🇹🇷',
                              label: 'TR',
                              isSelected: ref.watch(localeProvider).languageCode == 'tr',
                            ),
                            _buildLanguagePill(
                              context: context,
                              ref: ref,
                              code: 'en',
                              flag: '🇬🇧',
                              label: 'EN',
                              isSelected: ref.watch(localeProvider).languageCode == 'en',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.08)),

                // Theme Toggle Tile (Aydınlık / Karanlık Mod)
                SwitchListTile(
                  secondary: Icon(
                    ref.watch(themeModeProvider) == ThemeMode.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: ref.watch(themeModeProvider) == ThemeMode.dark
                        ? const Color(0xFFFFD166)
                        : theme.colorScheme.primary,
                  ),
                  title: Text(
                    l10n.themeSection,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    ref.watch(themeModeProvider) == ThemeMode.dark
                        ? l10n.themeDark
                        : l10n.themeLight,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  value: ref.watch(themeModeProvider) == ThemeMode.dark,
                  onChanged: (isDark) {
                    ref.read(themeModeProvider.notifier).toggle();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Active Medications Overview
          _buildSectionHeader(context, l10n.activeMedsSection, Icons.medication_rounded),
          const SizedBox(height: 8),
          if (activeMeds.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.noActiveMeds,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            )
          else
            Card(
              elevation: 0,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeMeds.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: theme.colorScheme.onSurface.withOpacity(0.08),
                ),
                itemBuilder: (context, index) {
                  final med = activeMeds[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                      child: Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 20),
                    ),
                    title: Text(med.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('${med.times.join(", ")} • ${l10n.stockRemainingText}: ${med.stockRemaining} ${l10n.units}'),
                    trailing: Text(
                      l10n.formatForm(med.form),
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),

          // 4. Past Medications Section (with Reactivate action)
          _buildSectionHeader(context, l10n.pastMedsSection, Icons.history_rounded),
          const SizedBox(height: 8),
          if (pastMeds.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.noPastMeds,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            )
          else
            Card(
              elevation: 0,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pastMeds.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: theme.colorScheme.onSurface.withOpacity(0.08),
                ),
                itemBuilder: (context, index) {
                  final med = pastMeds[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.withOpacity(0.15),
                      child: const Icon(Icons.archive_outlined, color: Colors.grey, size: 20),
                    ),
                    title: Text(
                      med.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text('${l10n.passive} • ${l10n.formatForm(med.form)}'),
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(l10n.reactivateMed),
                      onPressed: () async {
                        await ref.read(medicationsProvider.notifier).reactivateMedication(med.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.medicationReactivatedSuccess(med.name)),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),

          // 5. Notification Preferences
          _buildSectionHeader(context, l10n.notificationSettings, Icons.notifications_active_outlined),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.snooze_rounded),
                  title: Text(l10n.snoozeDurationLabel),
                  trailing: DropdownButton<int>(
                    value: ref.watch(storageServiceProvider).getSnoozeMinutes(),
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 5, child: Text('5 ${l10n.minShort}')),
                      DropdownMenuItem(value: 10, child: Text('10 ${l10n.minShort}')),
                      DropdownMenuItem(value: 15, child: Text('15 ${l10n.minShort}')),
                      DropdownMenuItem(value: 30, child: Text('30 ${l10n.minShort}')),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        await ref.read(storageServiceProvider).setSnoozeMinutes(val);
                        // Trigger UI update
                        (context as Element).markNeedsBuild();
                      }
                    },
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.08)),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(l10n.missedThresholdLabel),
                  trailing: DropdownButton<int>(
                    value: ref.watch(storageServiceProvider).getMissedThresholdMinutes(),
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 30, child: Text('30 ${l10n.minShort}')),
                      DropdownMenuItem(value: 60, child: Text('60 ${l10n.minShort}')),
                      DropdownMenuItem(value: 120, child: Text('2 ${l10n.hoursShort}')),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        await ref.read(storageServiceProvider).setMissedThresholdMinutes(val);
                        // Trigger UI update
                        (context as Element).markNeedsBuild();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 6. Account & Auth Actions
          _buildSectionHeader(context, l10n.accountSection, Icons.manage_accounts_outlined),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.people_alt_outlined),
                  title: Text(l10n.selectProfileTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: onNavigateToProfileSelect,
                ),
                Divider(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.08)),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F)),
                  title: Text(
                    l10n.logoutButton,
                    style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    _showLogoutDialog(context, l10n, onLogout);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Version & Medical Disclaimer
          Center(
            child: Column(
              children: [
                Text(
                  l10n.appVersion,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.medicalDisclaimer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AppL10n l10n, VoidCallback? onLogout) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logoutButton),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (onLogout != null) onLogout();
            },
            child: Text(l10n.logoutButton),
          ),
        ],
      ),
    );
  }

  String _getRelationText(String relation, AppL10n l10n) {
    switch (relation.toLowerCase()) {
      case 'mother':
        return l10n.relationMother;
      case 'father':
        return l10n.relationFather;
      case 'child':
        return l10n.relationChild;
      case 'self':
      default:
        return l10n.relationSelf;
    }
  }

  Widget _buildLanguagePill({
    required BuildContext context,
    required WidgetRef ref,
    required String code,
    required String flag,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            ref.read(localeProvider.notifier).setLocale(code);
          }
        },
        borderRadius: BorderRadius.circular(19),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(19),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ayarlar sekmesi üzerinden seçili profili silmek istendiğinde onay diyaloğunu açar.
  /// Sistemde kalan son profilin silinmesini engelleyerek kullanıcıyı uyarır.
  void _confirmDeleteProfile(BuildContext context, WidgetRef ref, ProfileModel profile, AppL10n l10n) {
    final profiles = ref.read(profilesProvider);
    if (profiles.length <= 1) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.deleteProfileMinWarning),
          backgroundColor: const Color(0xFFF57C00),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(l10n.deleteProfileTitle),
          ],
        ),
        content: Text(l10n.deleteProfileConfirm(profile.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(profilesProvider.notifier).deleteProfile(profile.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.profileDeletedSuccess(profile.name)),
                    backgroundColor: const Color(0xFFD32F2F),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
