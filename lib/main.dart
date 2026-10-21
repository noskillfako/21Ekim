// ==============================================================================
// DOSYA ADI: lib/main.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Uygulamanın ana giriş noktasıdır (Entry Point).
// - Yerel depolama (StorageService) ve 8500+ Türk ilaç kataloğunu (DrugService) başlatır.
// - Riverpod ProviderScope ile tüm uygulamanın durum yönetimini (State Management) sarar.
// - Tema modu (Aydınlık/Karanlık) ve Dil desteğini (Türkçe/İngilizce) MaterialApp seviyesinde dinamik olarak yönetir.
// - Doğrudan başlangıç sayfası olarak MainNavigationScreen (Ana Gezinme Ekranı) yükler.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_l10n.dart';
import 'core/services/storage_service.dart';
import 'core/services/drug_service.dart';
import 'core/providers/app_providers.dart';
import 'features/main_nav/presentation/main_navigation_screen.dart';

/// Uygulamanın başlangıç fonksiyonu.
/// SharedPreferences tabanlı depolamayı ve arka plan ilaç servisini asenkron olarak ayağa kaldırır.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage Service and pre-seed sample data if first run
  final storageService = StorageService();
  await storageService.init();

  // Pre-load Turkish drugs catalog into memory asynchronously in background
  final drugService = DrugService();
  unawaited(drugService.init());

  runApp(
    const ProviderScope(
      child: IlacTakipApp(),
    ),
  );
}

void unawaited(Future<void> future) {}

/// Kök Uygulama Widget'ı.
/// Riverpod sağlayıcılarını dinleyerek aktif tema (Aydınlık/Karanlık) ve dili anlık günceller.
class IlacTakipApp extends ConsumerWidget {
  const IlacTakipApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'İlaç Takip Sistemi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppL10nDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainNavigationScreen(),
    );
  }
}
