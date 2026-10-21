// ==============================================================================
// DOSYA ADI: lib/features/medication/presentation/widgets/medication_card.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Zaman çizelgesindeki (TodayTimelineTab) her bir ilaç dozu kartını oluşturur.
// - İlacın adı, dozu, formu, aç/tok kullanım durumu ve planlanan saati gösterir.
// - Stok durumunu (StockIndicator) ve son kullanma tarihi rozetini (ExpiryBadge) içerir.
// - Doz aksiyon butonlarını (İçtim, 15 dk Ertele, Dozu Atla) barındırır ve geri bildirim sağlar.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/models/medication_model.dart';
import '../../../../core/models/intake_log_model.dart';
import '../../../../core/widgets/stock_indicator.dart';
import '../../../../core/widgets/expiry_badge.dart';
import '../../../../core/l10n/app_l10n.dart';

/// [MedicationCard] tekil ilaç dozu ve alım eylemleri (içtim/ertele/atla) kartı bileşeni.
class MedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final String scheduledTime;
  final IntakeLogModel? log;
  final VoidCallback onTake;
  final VoidCallback onSnooze;
  final VoidCallback onSkip;
  final VoidCallback? onRefillStock;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.scheduledTime,
    this.log,
    required this.onTake,
    required this.onSnooze,
    required this.onSkip,
    this.onRefillStock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final status = log?.status ?? 'pending';
    final isTaken = status == 'taken';
    final isSnoozed = status == 'snoozed';
    final isSkipped = status == 'skipped';

    // Status Badge Info
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (isTaken) {
      statusColor = const Color(0xFF2E7D32);
      statusLabel = l10n.statusTaken;
      statusIcon = Icons.check_circle_rounded;
    } else if (isSnoozed) {
      statusColor = const Color(0xFFF57C00);
      statusLabel = l10n.statusSnoozed;
      statusIcon = Icons.snooze_rounded;
    } else if (isSkipped) {
      statusColor = const Color(0xFF757575);
      statusLabel = l10n.statusSkipped;
      statusIcon = Icons.do_not_disturb_on_rounded;
    } else {
      statusColor = theme.colorScheme.primary;
      statusLabel = l10n.statusPending;
      statusIcon = Icons.schedule_rounded;
    }

    // Food info
    String foodText;
    IconData foodIcon;
    switch (medication.withFood) {
      case 'before':
        foodText = l10n.withFoodBefore;
        foodIcon = Icons.restaurant_rounded;
        break;
      case 'after':
        foodText = l10n.withFoodAfter;
        foodIcon = Icons.dinner_dining_rounded;
        break;
      case 'none':
      default:
        foodText = l10n.withFoodNone;
        foodIcon = Icons.all_inclusive_rounded;
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Time, Food Condition, Status Badge
            Row(
              children: [
                // Time Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_filled_rounded, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        scheduledTime,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Food Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(foodIcon, size: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        foodText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Medicine Name & Dose
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medication.doseAmount} ${l10n.formatDoseUnit(medication.doseUnit)} • ${l10n.formatForm(medication.form)} • ${l10n.formatFrequency(medication.frequency)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (medication.source == 'api' || medication.source == 'Global API')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0096C7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OpenFDA',
                      style: TextStyle(fontSize: 10, color: Color(0xFF0096C7), fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Stock Indicator & Expiry Badge
            StockIndicator(
              remaining: medication.stockRemaining,
              lowThreshold: medication.lowThreshold,
              onRefillTap: onRefillStock,
            ),

            if (medication.expiryDate != null) ...[
              const SizedBox(height: 8),
              ExpiryBadge(
                expiryDate: medication.expiryDate,
                status: medication.expiryStatus,
                daysUntil: medication.daysUntilExpiry,
              ),
            ],

            const SizedBox(height: 14),

            // Action Buttons: İçtim / Ertele / Atla
            Row(
              children: [
                // İçtim Button
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: isTaken ? null : onTake,
                    icon: Icon(
                      isTaken ? Icons.check_circle_rounded : Icons.check_rounded,
                      size: 18,
                    ),
                    label: Text(isTaken ? l10n.statusTaken : l10n.actionTake),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTaken
                          ? (isDark ? const Color(0xFF1E3A24) : const Color(0xFFE8F5E9))
                          : theme.colorScheme.primary,
                      foregroundColor: isTaken ? const Color(0xFF2E7D32) : Colors.white,
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Ertele Button
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: isTaken ? null : onSnooze,
                    icon: const Icon(Icons.snooze_rounded, size: 16),
                    label: Text(l10n.actionSnooze),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF57C00),
                      side: BorderSide(
                        color: isTaken
                            ? theme.colorScheme.onSurface.withOpacity(0.1)
                            : const Color(0xFFF57C00).withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Atla Button
                IconButton.outlined(
                  onPressed: isTaken ? null : onSkip,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  tooltip: l10n.actionSkip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
