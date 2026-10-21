// ==============================================================================
// DOSYA ADI: lib/features/medication/presentation/today_timeline_tab.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Ekran 5 (Günün İlaç Hatırlatma / Zaman Çizelgesi ve İlaç Bazlı Takip) ana sekmesini oluşturur.
// - Aktif profile ait bugünkü dozları iki farklı görünüm kipinde sunar:
//   1. İlaç Bazlı (Grouped View): Çoklu dozu olan ilaçları tek kart altında slotlar halinde listeler (mükerrerliği önler).
//   2. Zaman Çizelgesi (Timeline View): Günün saatlerine göre kronolojik olarak sıralı tekil doz kartları gösterir.
// - "İçtim" (stok düşürme ve loglama), "Ertele" (snooze) ve "Atla" (skip) kritik eylemlerini yönetir.
// - Stok takviye / yenileme (refill dialog) penceresini açar.
// - Ana Gezinme Ekranı'nın (MainNavigationScreen) 1. sekmesi (varsayılan açılış sayfası) olarak çalışır.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_l10n.dart';
import 'widgets/medication_card.dart';
import 'widgets/medication_grouped_card.dart';

/// [TodayTimelineTab] günün ilaç hatırlatma ve zaman çizelgesi sekmesi bileşeni.
class TodayTimelineTab extends ConsumerStatefulWidget {
  final VoidCallback? onSwitchProfile;
  final VoidCallback? onNavigateToAdd;

  const TodayTimelineTab({
    super.key,
    this.onSwitchProfile,
    this.onNavigateToAdd,
  });

  @override
  ConsumerState<TodayTimelineTab> createState() => _TodayTimelineTabState();
}

class _TodayTimelineTabState extends ConsumerState<TodayTimelineTab> {
  // Default to Grouped View so medications with multiple doses are not duplicated
  bool _isGroupedView = true;

  /// İlaç dozu "İçtim" olarak işaretlendiğinde:
  /// 1. Alım günlüğünü (IntakeLog) "taken" olarak kaydeder.
  /// 2. İlacın kalan stok miktarını doz adedi kadar azaltır.
  /// 3. Kullanıcıya güncel stok bilgisi içeren onay bildirimi sunar.
  Future<void> _handleTake(String medId, String medName, int perDose, int currentStock, String scheduledTime) async {
    final activeProfile = ref.read(activeProfileProvider);
    final l10n = AppL10n.of(context);
    if (activeProfile == null) return;

    // 1. Log action
    await ref.read(intakeLogsProvider.notifier).logAction(
          medicationId: medId,
          profileId: activeProfile.id,
          scheduledTime: scheduledTime,
          status: 'taken',
        );

    // 2. Decrement stock
    await ref.read(medicationsProvider.notifier).decrementStock(
          medId,
          perDose,
        );

    if (mounted) {
      final remaining = (currentStock - perDose).clamp(0, 99999);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.medicationTakenSuccess(medName, remaining)),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// İlaç dozu ertelendiğinde alım kaydını "snoozed" yapar ve belirlenen süre kadar erteleme bildirimi gösterir.
  Future<void> _handleSnooze(String medId, String scheduledTime) async {
    final activeProfile = ref.read(activeProfileProvider);
    final l10n = AppL10n.of(context);
    if (activeProfile == null) return;

    final snoozeMins = ref.read(storageServiceProvider).getSnoozeMinutes();
    await ref.read(intakeLogsProvider.notifier).logAction(
          medicationId: medId,
          profileId: activeProfile.id,
          scheduledTime: scheduledTime,
          status: 'snoozed',
        );

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.medicationSnoozed(snoozeMins)),
          backgroundColor: const Color(0xFFF57C00),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// İlaç dozu atlandığında alım kaydını "skipped" yapar ve gri bilgi bildirimi verir.
  Future<void> _handleSkip(String medId, String scheduledTime) async {
    final activeProfile = ref.read(activeProfileProvider);
    final l10n = AppL10n.of(context);
    if (activeProfile == null) return;

    await ref.read(intakeLogsProvider.notifier).logAction(
          medicationId: medId,
          profileId: activeProfile.id,
          scheduledTime: scheduledTime,
          status: 'skipped',
        );

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.medicationSkipped),
          backgroundColor: Colors.grey,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// İlaç bittiğinde veya azaldığında stok ekleme iletişim kutusunu görüntüler.
  void _showRefillDialog(MedicationModel medication) {
    final messenger = ScaffoldMessenger.of(context);
    final currentL10n = AppL10n.of(context);
    int addedCount = 30;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(currentL10n.refillTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentL10n.refillPrompt(medication.name)),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: currentL10n.refillAmountLabel,
                hintText: '30',
              ),
              onChanged: (val) {
                addedCount = int.tryParse(val) ?? 30;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(currentL10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(medicationsProvider.notifier).refillStock(medication.id, addedCount);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) {
                messenger.clearSnackBars();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(currentL10n.refillSuccess(medication.name, medication.stockRemaining + addedCount)),
                    backgroundColor: const Color(0xFF2E7D32),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(currentL10n.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final timelineSlots = ref.watch(todayTimelineProvider);
    final groupedMeds = ref.watch(todayGroupedMedicationsProvider);
    final now = DateTime.now();

    final dateStr = DateFormat('EEEE, d MMMM yyyy', l10n.isTr ? 'tr_TR' : 'en_US').format(now);
    final isEmpty = timelineSlots.isEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Date & Title Header (Profile card removed; profile is only in top bar)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.todayTimelineTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      // Dose Stats Badge
                      if (!isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${timelineSlots.where((s) => s.status == 'taken').length}/${timelineSlots.length} ${l10n.statusTaken}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // View Mode Toggle (İlaç Bazlı / Zaman Çizelgesi)
                  if (!isEmpty)
                    Row(
                      children: [
                        SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment<bool>(
                              value: true,
                              icon: const Icon(Icons.view_agenda_rounded, size: 16),
                              label: Text(l10n.viewModeMedication),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              icon: const Icon(Icons.timeline_rounded, size: 16),
                              label: Text(l10n.viewModeTimeline),
                            ),
                          ],
                          selected: {_isGroupedView},
                          onSelectionChanged: (val) {
                            setState(() {
                              _isGroupedView = val.first;
                            });
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Medications List or Empty State
          if (isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noMedsForToday,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.isTr
                            ? 'Bu profile ait aktif ilaç eklemek için "İlaç Ekle" sekmesine gidebilirsiniz.'
                            : 'Go to the "Manage Meds" tab to schedule medications for this profile.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      if (widget.onNavigateToAdd != null) ...[
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: widget.onNavigateToAdd,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.navAddRemove),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else if (_isGroupedView)
            // Grouped by Medication: Each medicine is displayed ONCE with its daily doses
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = groupedMeds[index];
                    return MedicationGroupedCard(
                      item: item,
                      onTake: (time) => _handleTake(
                        item.medication.id,
                        item.medication.name,
                        item.medication.perDose,
                        item.medication.stockRemaining,
                        time,
                      ),
                      onSnooze: (time) => _handleSnooze(item.medication.id, time),
                      onSkip: (time) => _handleSkip(item.medication.id, time),
                      onRefillStock: () => _showRefillDialog(item.medication),
                    );
                  },
                  childCount: groupedMeds.length,
                ),
              ),
            )
          else
            // Chronological Timeline View: Sorted by hour
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final slot = timelineSlots[index];
                    return MedicationCard(
                      medication: slot.medication,
                      scheduledTime: slot.time,
                      log: slot.log,
                      onTake: () => _handleTake(
                        slot.medication.id,
                        slot.medication.name,
                        slot.medication.perDose,
                        slot.medication.stockRemaining,
                        slot.time,
                      ),
                      onSnooze: () => _handleSnooze(slot.medication.id, slot.time),
                      onSkip: () => _handleSkip(slot.medication.id, slot.time),
                      onRefillStock: () => _showRefillDialog(slot.medication),
                    );
                  },
                  childCount: timelineSlots.length,
                ),
              ),
            ),

          // Medical Disclaimer Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.medicalDisclaimer,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
