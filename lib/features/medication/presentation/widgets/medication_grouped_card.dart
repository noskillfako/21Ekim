// ==============================================================================
// DOSYA ADI: lib/features/medication/presentation/widgets/medication_grouped_card.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Günde birden fazla kez kullanılan ilaçların tek bir ana kart altında toplanarak
//   ekranda mükerrer / tekrarlayan kart kirliliği oluşturmasını önleyen gruplanmış ilaç kartıdır.
// - İlaç genel bilgilerini, toplam/alınan doz oranını ve gün içindeki her bir doz saatini (slot) alt alta listeler.
// - Her doz slotu için ayrı ayrı "İçtim", "15 Dk Ertele" ve "Atla" eylemleri sunar.
// - TodayTimelineTab (İlaç Hatırlatma / İlaç Bazlı Görünüm) sekmesi tarafından kullanılır.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/widgets/stock_indicator.dart';
import '../../../../core/widgets/expiry_badge.dart';
import '../../../../core/l10n/app_l10n.dart';

/// [MedicationGroupedCard] günde birden fazla dozu olan bir ilacı tek kart altında slotlar halinde sunan bileşen.
class MedicationGroupedCard extends StatelessWidget {
  final MedicationTodayItem item;
  final void Function(String scheduledTime) onTake;
  final void Function(String scheduledTime) onSnooze;
  final void Function(String scheduledTime) onSkip;
  final VoidCallback? onRefillStock;

  const MedicationGroupedCard({
    super.key,
    required this.item,
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
    final med = item.medication;

    // Get appropriate icon for medicine form
    IconData formIcon;
    final formLower = med.form.toLowerCase();
    if (formLower.contains('şurup') || formLower.contains('surup')) {
      formIcon = Icons.liquor_rounded;
    } else if (formLower.contains('iğne') || formLower.contains('ampul')) {
      formIcon = Icons.vaccines_rounded;
    } else if (formLower.contains('damla')) {
      formIcon = Icons.water_drop_rounded;
    } else if (formLower.contains('krem') || formLower.contains('merhem')) {
      formIcon = Icons.sanitizer_rounded;
    } else {
      formIcon = Icons.medication_rounded;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: item.isAllTaken
              ? const Color(0xFF2E7D32).withOpacity(0.3)
              : theme.colorScheme.onSurface.withOpacity(0.1),
          width: item.isAllTaken ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Form Icon + Med Name + Source/Status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.isAllTaken
                        ? const Color(0xFF2E7D32).withOpacity(0.15)
                        : theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.isAllTaken ? Icons.check_circle_rounded : formIcon,
                    color: item.isAllTaken ? const Color(0xFF2E7D32) : theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${med.doseAmount} ${l10n.formatDoseUnit(med.doseUnit)} • ${l10n.formatForm(med.form)} • ${l10n.formatFrequency(med.frequency)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                if (med.source == 'api' || med.source == 'Global API')
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

            // Stock & Expiry Row (Shown once for the medicine)
            StockIndicator(
              remaining: med.stockRemaining,
              lowThreshold: med.lowThreshold,
              onRefillTap: onRefillStock,
            ),
            if (med.expiryDate != null) ...[
              const SizedBox(height: 8),
              ExpiryBadge(
                expiryDate: med.expiryDate,
                status: med.expiryStatus,
                daysUntil: med.daysUntilExpiry,
              ),
            ],
            const SizedBox(height: 14),

            const Divider(height: 1),
            const SizedBox(height: 10),

            // Today's Doses Header with completion count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dosesToday,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${item.takenCount}/${item.totalCount} ${l10n.statusTaken}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.isAllTaken ? const Color(0xFF2E7D32) : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dose slots list
            Column(
              children: [
                for (int i = 0; i < item.doseSlots.length; i++)
                  _buildDoseSlotTile(context, item.doseSlots[i], i + 1, l10n, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseSlotTile(
    BuildContext context,
    DoseSlot slot,
    int doseIndex,
    AppL10n l10n,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final status = slot.status;
    final isTaken = status == 'taken';
    final isSnoozed = status == 'snoozed';
    final isSkipped = status == 'skipped';

    // Status Badge Details
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
    switch (slot.medication.withFood) {
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

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isTaken
            ? (isDark ? const Color(0xFF142417) : const Color(0xFFE8F5E9).withOpacity(0.5))
            : theme.colorScheme.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTaken
              ? const Color(0xFF2E7D32).withOpacity(0.3)
              : theme.colorScheme.onSurface.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Scheduled Time Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_filled_rounded, size: 13, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      slot.time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Food relation pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(foodIcon, size: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                    const SizedBox(width: 3),
                    Text(
                      foodText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 3),
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

          // Actions Row (if not already taken)
          if (!isTaken) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                // Take button
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 34,
                    child: ElevatedButton.icon(
                      onPressed: () => onTake(slot.time),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text(l10n.actionTake, style: const TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Snooze button
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 34,
                    child: OutlinedButton.icon(
                      onPressed: () => onSnooze(slot.time),
                      icon: const Icon(Icons.snooze_rounded, size: 14),
                      label: Text(l10n.actionSnooze, style: const TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: const Color(0xFFF57C00),
                        side: BorderSide(color: const Color(0xFFF57C00).withOpacity(0.6)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Skip button
                SizedBox(
                  height: 34,
                  width: 38,
                  child: IconButton.outlined(
                    onPressed: () => onSkip(slot.time),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    tooltip: l10n.actionSkip,
                    padding: EdgeInsets.zero,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
