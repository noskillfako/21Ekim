// ==============================================================================
// DOSYA ADI: lib/core/widgets/expiry_badge.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - İlaçların Son Kullanma Tarihi (SKT / EXP) durumunu renkli ve ikonlu rozet olarak görüntüler.
// - Durumlar: 'valid' (Yeşil / Geçerli), 'expiringSoon' (Turuncu / Yakında Dolacak), 'expired' (Kırmızı / Tarihi Geçti).
// - Bugünün İlaçları (MedicationGroupedCard / MedicationCard) ve İlaç Ekle/Çıkar ekranlarını etkiler.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_l10n.dart';

/// Son kullanma tarihi durumunu gösteren rozet widget'ı.
class ExpiryBadge extends StatelessWidget {
  final DateTime? expiryDate;
  final String status; // 'valid' | 'expiringSoon' | 'expired'
  final int? daysUntil;

  const ExpiryBadge({
    super.key,
    required this.expiryDate,
    required this.status,
    this.daysUntil,
  });

  @override
  Widget build(BuildContext context) {
    if (expiryDate == null) return const SizedBox.shrink();

    final l10n = AppL10n.of(context);
    final formattedDate = DateFormat('MM/yyyy').format(expiryDate!);

    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'expired':
        color = const Color(0xFFD32F2F);
        icon = Icons.cancel_outlined;
        label = l10n.expiryBadgeExpired(formattedDate);
        break;
      case 'expiringSoon':
        color = const Color(0xFFF57C00);
        icon = Icons.access_time_rounded;
        label = l10n.expiryBadgeSoon(formattedDate, daysUntil ?? 0);
        break;
      case 'valid':
      default:
        color = const Color(0xFF2E7D32);
        icon = Icons.check_circle_outline_rounded;
        label = l10n.expiryBadgeValid(formattedDate);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
