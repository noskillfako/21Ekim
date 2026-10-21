// ==============================================================================
// DOSYA ADI: lib/features/profile/presentation/profile_selection_screen.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Ekran 4 (Profil Seçimi ve Profil Yönetimi) arayüzünü oluşturur.
// - Mevcut kullanıcı profillerini (yaş, cinsiyet avatarı, yakınlık derecesi) ızgara (grid) olarak listeler.
// - Kullanıcı bir profile tıkladığında aktif profili günceller ve MainNavigationScreen'e aktarır.
// - Yeni profil ekleme (ProfileCreateScreen) ve profil silme onay diyaloğunu yönetir.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/profile_avatar.dart';
import 'profile_create_screen.dart';
import '../../main_nav/presentation/main_navigation_screen.dart';

/// [ProfileSelectionScreen] profil seçme, değiştirme ve silme ekranı.
class ProfileSelectionScreen extends ConsumerWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final profiles = ref.watch(profilesProvider);
    final activeId = ref.watch(activeProfileIdProvider);

    return Scaffold(
      appBar: AppTopBar(
        title: l10n.selectProfileTitle,
        showProfileAvatar: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.selectProfileSubtitle,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),

              // Profiles Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: profiles.length + 1, // +1 for "Add New Profile" card
                  itemBuilder: (context, index) {
                    if (index < profiles.length) {
                      final p = profiles[index];
                      final isSelected = p.id == activeId;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: Card(
                              elevation: 0,
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(0.12)
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withOpacity(0.1),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  await ref.read(activeProfileIdProvider.notifier).selectProfile(p.id);
                                  if (context.mounted) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const MainNavigationScreen(),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ProfileAvatar(
                                        avatarKey: p.avatarKey,
                                        radius: 36,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        p.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _getRelationText(p.relation, l10n),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${p.age} ${l10n.ageYears}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (profiles.length > 1)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                tooltip: l10n.deleteProfile,
                                onPressed: () => _confirmDeleteProfile(context, ref, p, l10n),
                              ),
                            ),
                        ],
                      );
                    } else {
                      // "+ Yeni Profil Ekle" Card
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.4),
                            style: BorderStyle.solid,
                            width: 1.5,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileCreateScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 32,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.addNewProfile,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
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
