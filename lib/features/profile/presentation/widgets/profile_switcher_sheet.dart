// ==============================================================================
// DOSYA ADI: lib/features/profile/presentation/widgets/profile_switcher_sheet.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Ekranın altından açılan modal profil değiştirici (Bottom Sheet) bileşenidir.
// - Kullanıcının kayıtlı profiller arasında anında geçiş yapmasını sağlar.
// - Yeni profil ekleme ekranına (ProfileCreateScreen) geçiş düğmesi içerir.
// - Profilleri silme onay iletişimini tetikleyebilir.
// - AppTopBar üzerindeki profil avatarına veya profil kartına tıklandığında açılır.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../profile_create_screen.dart';

/// [ProfileSwitcherSheet] hızlı profil değiştirme ve yönetme alt sayfası.
class ProfileSwitcherSheet extends ConsumerWidget {
  const ProfileSwitcherSheet({super.key});

  /// Profil seçim modalini ekranın altından yukarı doğru açar.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const ProfileSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final profiles = ref.watch(profilesProvider);
    final activeId = ref.watch(activeProfileIdProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.switchProfile,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileCreateScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.addNewProfile),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Profiles List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profiles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final p = profiles[index];
                final isSelected = p.id == activeId;

                return Card(
                  elevation: 0,
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.12)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.08),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      ref.read(activeProfileIdProvider.notifier).selectProfile(p.id);
                      Navigator.of(context).pop();
                    },
                    leading: ProfileAvatar(
                      avatarKey: p.avatarKey,
                      radius: 20,
                    ),
                    title: Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${p.age} ${l10n.yearsOld} • ${_getRelationText(p.relation, l10n)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
                        if (profiles.length > 1) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            tooltip: l10n.deleteProfile,
                            onPressed: () => _confirmDeleteProfile(context, ref, p, l10n),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Profil silme onayı isteyen iletişim kutusunu (AlertDialog) görüntüler.
  /// Sistemde en az bir profil kalmasını denetler, aksi halde uyarı bildirimi gösterir.
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
}
