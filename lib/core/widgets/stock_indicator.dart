// ==============================================================================
// DOSYA ADI: lib/core/widgets/stock_indicator.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - İlacın kalan kutu stoğunu ve kritik azalma seviyesini görsel progress bar ve uyarı yazısıyla sunar.
// - Kutu azaldığında veya bittiğinde "+ Kutu Yenile" aksiyon butonu sunarak hızlı stok yenileme diyalogunu açar.
// - Bugünün İlaçları (MedicationGroupedCard / MedicationCard) ve İlaç Ekleme listesini doğrudan etkiler.
// ==============================================================================

import 'package:flutter/material.dart';
import '../l10n/app_l10n.dart';

/// İlaç stok seviyesini renkli ilerleme çubuğu ve uyarıyla gösteren widget.
class StockIndicator extends StatelessWidget {
  final int remaining;
  final int lowThreshold;
  final int maxStock;
  final VoidCallback? onRefillTap;

  const StockIndicator({
    super.key,
    required this.remaining,
    required this.lowThreshold,
    this.maxStock = 30,
    this.onRefillTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final effectiveMax = maxStock > 0 ? maxStock : 30;
    final progress = (remaining / effectiveMax).clamp(0.0, 1.0);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (remaining <= 0) {
      statusColor = const Color(0xFFD32F2F);
      statusText = l10n.stockEmptyAlert;
      statusIcon = Icons.error_outline_rounded;
    } else if (remaining <= lowThreshold) {
      statusColor = const Color(0xFFF57C00);
      statusText = l10n.stockLowAlert(remaining);
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = const Color(0xFF2E7D32);
      statusText = l10n.stockPiecesLeft(remaining);
      statusIcon = Icons.inventory_2_outlined;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            if (remaining <= lowThreshold && onRefillTap != null)
              InkWell(
                onTap: onRefillTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    l10n.stockRefillAction,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
