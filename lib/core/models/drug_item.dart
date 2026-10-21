// ==============================================================================
// DOSYA ADI: lib/core/models/drug_item.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - İlaç arama ve otomatik tamamlama (DrugAutocompleteField) sonuçlarını temsil eden veri modelidir.
// - 8500+ kayıtlı Yerel Türk İlaç Veritabanı ve canlı OpenFDA Global API sonuçlarını tek tip nesnede birleştirir.
// - İlaç Ekleme Sekmesi (MedicationAddTab) ve arama açılır kutusunu doğrudan etkiler.
// ==============================================================================

/// Arama sonuçlarında listelenen ilaç modelini tanımlar.
class DrugItem {
  final String name;
  final String? barcode;
  final String source; // 'Yerel' veya 'Global API'

  const DrugItem({
    required this.name,
    this.barcode,
    required this.source,
  });

  bool get isLocal => source == 'Yerel';
  bool get isGlobalApi => source == 'Global API';

  factory DrugItem.fromLocalJson(Map<String, dynamic> json) {
    return DrugItem(
      name: (json['name'] ?? '').toString().trim(),
      barcode: json['barcode']?.toString().trim(),
      source: 'Yerel',
    );
  }

  factory DrugItem.fromFda(String brandName) {
    return DrugItem(
      name: brandName.trim(),
      barcode: null,
      source: 'Global API',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'barcode': barcode,
      'source': source,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrugItem &&
          runtimeType == other.runtimeType &&
          name.toLowerCase() == other.name.toLowerCase() &&
          source == other.source;

  @override
  int get hashCode => name.toLowerCase().hashCode ^ source.hashCode;

  @override
  String toString() => 'DrugItem(name: $name, barcode: $barcode, source: $source)';
}
