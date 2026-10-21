// ==============================================================================
// DOSYA ADI: lib/features/health/presentation/smart_watch_tab.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Ekran 7 (Akıllı Saat Entegrasyonu ve Canlı Sağlık Takibi) arayüzünü oluşturur.
// - Seçili aktif profile ait akıllı saat bağlantı durumunu (Wear OS / Apple Watch) kontrol eder.
// - Nabız (BPM), günlük adım, uyku süresi ve SpO2 (Kandaki Oksijen) canlı metrik kartlarını listeler.
// - [HealthDataListNotifier] üzerinden saat bağlantısını bağlama/koparma işlemlerini yönetir.
// - Ana Gezinme Ekranı'nın (MainNavigationScreen) 3. sekmesi olarak görüntülenir.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/health_metric_card.dart';

/// [SmartWatchTab] akıllı saat sağlık verileri ve bağlantı durumu sekmesi bileşeni.
/// Profil bazlı kalp atış hızı, adım, uyku ve SpO2 göstergelerini sunar.
class SmartWatchTab extends ConsumerWidget {
  const SmartWatchTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final activeProfile = ref.watch(activeProfileProvider);
    final healthData = ref.watch(currentProfileHealthDataProvider);

    final isConnected = healthData?.isWatchConnected ?? false;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Active Profile
            Text(
              l10n.watchTabTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              activeProfile != null
                  ? '${activeProfile.name} ${l10n.isTr ? "için sağlık verileri" : "health metrics"}'
                  : '',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),

            // Connection Status Banner
            Card(
              elevation: 0,
              color: isConnected
                  ? const Color(0xFF2E7D32).withOpacity(0.1)
                  : theme.colorScheme.onSurface.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isConnected
                      ? const Color(0xFF2E7D32).withOpacity(0.4)
                      : theme.colorScheme.onSurface.withOpacity(0.12),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? const Color(0xFF2E7D32).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isConnected ? Icons.watch_rounded : Icons.watch_off_rounded,
                        color: isConnected ? const Color(0xFF2E7D32) : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected ? l10n.watchStatusConnected : l10n.watchStatusDisconnected,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isConnected ? const Color(0xFF2E7D32) : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isConnected
                                ? (l10n.isTr
                                    ? 'Apple Watch / Wear OS bağlı'
                                    : 'Apple Watch / Wear OS connected')
                                : (l10n.isTr
                                    ? 'Sağlık verilerini eşitlemek için saatinizi bağlayın'
                                    : 'Connect watch to sync health data'),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isConnected
                            ? const Color(0xFFD32F2F)
                            : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (activeProfile != null) {
                          ref.read(healthDataListProvider.notifier).toggleWatchConnection(activeProfile.id);
                        }
                      },
                      child: Text(isConnected ? l10n.disconnectWatch : l10n.connectWatch),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Health Metric Cards Grid
            if (isConnected && healthData != null) ...[
              Text(
                l10n.isTr ? 'Canlı Sağlık Göstergeleri' : 'Live Health Metrics',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  // 1. Heart Rate
                  HealthMetricCard(
                    title: l10n.metricHeartRate,
                    value: '${healthData.heartRate}',
                    unit: 'bpm',
                    icon: Icons.favorite_rounded,
                    accentColor: const Color(0xFFE63946),
                    subtitle: l10n.isTr ? 'Normal dinlenme nabzı' : 'Normal resting rate',
                  ),

                  // 2. Daily Steps
                  HealthMetricCard(
                    title: l10n.metricSteps,
                    value: '${healthData.steps}',
                    unit: '/ 10.000',
                    icon: Icons.directions_walk_rounded,
                    accentColor: const Color(0xFF2A9D8F),
                    progress: healthData.steps / 10000.0,
                    subtitle: l10n.isTr ? 'Hedefe %${(healthData.steps / 100).round()} ulaşıldı' : '${(healthData.steps / 100).round()}% of goal',
                  ),

                  // 3. Sleep
                  HealthMetricCard(
                    title: l10n.metricSleep,
                    value: '${healthData.sleepHours}',
                    unit: 'saat',
                    icon: Icons.bedtime_rounded,
                    accentColor: const Color(0xFF7209B7),
                    progress: healthData.sleepHours / 8.0,
                    subtitle: l10n.isTr ? 'Derin & Verimli uyku' : 'Deep & restful sleep',
                  ),

                  // 4. SpO2 (Oxygen)
                  HealthMetricCard(
                    title: l10n.metricSpo2,
                    value: '%${healthData.spo2}',
                    unit: 'SpO2',
                    icon: Icons.air_rounded,
                    accentColor: const Color(0xFF0077B6),
                    subtitle: l10n.isTr ? 'Kandaki oksijen seviyesi iyi' : 'Oxygen level optimal',
                  ),
                ],
              ),
            ] else ...[
              // Disconnected Guide Card
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.health_and_safety_outlined,
                        size: 56,
                        color: theme.colorScheme.primary.withOpacity(0.7),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.watchGuideTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.watchGuideDesc,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (activeProfile != null) {
                            ref.read(healthDataListProvider.notifier).toggleWatchConnection(activeProfile.id);
                          }
                        },
                        icon: const Icon(Icons.sync_rounded),
                        label: Text(l10n.connectWatch),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Health Data & Medication Note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.isTr
                          ? 'Sağlık verileri KVKK kapsamında gizli tutulur ve yalnızca seçili profil altında görüntülenir.'
                          : 'Health data is kept private in accordance with GDPR/KVKK and only visible for the selected profile.',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
