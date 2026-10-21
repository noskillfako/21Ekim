// ==============================================================================
// DOSYA ADI: lib/core/widgets/health_metric_card.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Akıllı saatten gelen tekil bir sağlık metriğini (Nabız, Adım, Uyku, SpO2) modern kart tasarımıyla görüntüler.
// - İlerleme çubuğu, vurgu rengi ve birim göstergesi barındırır.
// - Akıllı Saat sekmesini (SmartWatchTab) doğrudan etkiler.
// ==============================================================================

import 'package:flutter/material.dart';

/// Tek bir sağlık göstergesini görselleştiren metrik kartı widget'ı.
class HealthMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;
  final double? progress; // 0.0 - 1.0

  const HealthMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
    this.subtitle,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress!.clamp(0.0, 1.0),
                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  minHeight: 6,
                ),
              ),
            ],
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
