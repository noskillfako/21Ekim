// ==============================================================================
// DOSYA ADI: lib/features/main_nav/presentation/main_navigation_screen.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Uygulamanın ana kabuk (shell/scaffold) ekranını oluşturur.
// - Alt gezinme çubuğu (Bottom Navigation Bar) ile 4 temel sekmeyi barındırır:
//   1. İlaç Hatırlatma / Zaman Çizelgesi (TodayTimelineTab)
//   2. İlaç Ekle / Çıkar (MedicationAddTab)
//   3. Akıllı Saat (SmartWatchTab)
//   4. Ayarlar & Geçmiş (SettingsTab)
// - Üst barda (AppTopBar) aktif profil avatarı ve profil değiştirici modalini (ProfileSwitcherSheet) yönetir.
// - Oturum kapatma (LoginScreen'e yönlendirme) ve profil seçim ekranı geçişlerini kontrol eder.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../medication/presentation/today_timeline_tab.dart';
import '../../medication/presentation/medication_add_tab.dart';
import '../../health/presentation/smart_watch_tab.dart';
import '../../settings/presentation/settings_tab.dart';
import '../../profile/presentation/widgets/profile_switcher_sheet.dart';
import '../../profile/presentation/profile_selection_screen.dart';
import '../../auth/presentation/login_screen.dart';

/// [MainNavigationScreen] 4 ana sekmenin durumunu (IndexedStack) ve alt gezinme menüsünü yöneten ana ekran.
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  /// Profil değiştirici alt sayfasını (ProfileSwitcherSheet) açar.
  void _onSwitchProfile() {
    ProfileSwitcherSheet.show(context);
  }

  /// Kullanıcı oturumunu kapatır ve tüm gezinme yığınını temizleyerek LoginScreen'e yönlendirir.
  void _onLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /// Tüm profillerin listelendiği ProfileSelectionScreen ekranına geçiş yapar.
  void _onNavigateToProfileSelect() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    String getTabTitle(int index) {
      switch (index) {
        case 0:
          return l10n.navReminder;
        case 1:
          return l10n.navAddRemove;
        case 2:
          return l10n.navWatch;
        case 3:
          return l10n.navSettings;
        default:
          return l10n.appTitle;
      }
    }

    final pages = [
      TodayTimelineTab(
        onSwitchProfile: _onSwitchProfile,
        onNavigateToAdd: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const MedicationAddTab(),
      const SmartWatchTab(),
      SettingsTab(
        onLogout: _onLogout,
        onNavigateToProfileSelect: _onNavigateToProfileSelect,
      ),
    ];

    return Scaffold(
      appBar: AppTopBar(
        title: getTabTitle(_currentIndex),
        showProfileAvatar: true,
        onProfileTap: _onSwitchProfile,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.alarm_outlined),
            selectedIcon: const Icon(Icons.alarm_rounded),
            label: l10n.navReminder,
          ),
          NavigationDestination(
            icon: const Icon(Icons.medication_outlined),
            selectedIcon: const Icon(Icons.medication_rounded),
            label: l10n.navAddRemove,
          ),
          NavigationDestination(
            icon: const Icon(Icons.watch_outlined),
            selectedIcon: const Icon(Icons.watch_rounded),
            label: l10n.navWatch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
