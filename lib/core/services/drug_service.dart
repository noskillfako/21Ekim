// ==============================================================================
// DOSYA ADI: lib/core/services/drug_service.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Hibrit İlaç Arama Motorudur.
// - 1) Yerel Veritabanı: `assets/data/turk_ilaclari.json` dosyasındaki 8504 adet Türk ilacını belleğe yükler ve Türkçe karakter duyarlı arar.
// - 2) Global API: Canlı OpenFDA API'sine paralel istek atarak yabancı/uluslararası ilaçları bulur.
// - İlaç Ekleme Sekmesi (MedicationAddTab) ve Arama Alanı (DrugAutocompleteField) bileşenlerini doğrudan besler.
// ==============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/drug_item.dart';

/// Hibrit yerel ve küresel ilaç arama işlemlerini yöneten servis sınıfı.
class DrugService {
  static final DrugService _instance = DrugService._internal();
  factory DrugService() => _instance;
  DrugService._internal();

  /// Canlı dış API entegrasyon kontrolü.
  /// Varsayılan olarak kapalıdır (`false`); uygulama API mimarisine hazır ve entegre
  /// şekilde durur ancak sorgularda yalnızca yerel `turk_ilaclari.json` verisini kullanır.
  static bool enableExternalApi = false;

  List<DrugItem> _localDrugs = [];
  bool _isInitialized = false;
  bool _isLoadingLocal = false;

  /// Timer for handling debounce if needed by callers directly
  Timer? _debounceTimer;

  /// Ensures local Turkish drug database is loaded into memory
  Future<void> init() async {
    if (_isInitialized || _isLoadingLocal) return;
    _isLoadingLocal = true;

    try {
      final jsonString = await rootBundle.loadString('assets/data/turk_ilaclari.json');
      final dynamic decoded = json.decode(jsonString);

      if (decoded is List) {
        _localDrugs = decoded
            .map((item) => DrugItem.fromLocalJson(item as Map<String, dynamic>))
            .where((item) => item.name.isNotEmpty)
            .toList();
        _isInitialized = true;
        debugPrint('[DrugService] Loaded ${_localDrugs.length} Turkish drugs into memory.');
      }
    } catch (e) {
      debugPrint('[DrugService] Error loading local drugs: $e');
    } finally {
      _isLoadingLocal = false;
    }
  }

  /// Normalizes Turkish characters for robust case-insensitive substring searching
  static String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'c')
        .trim();
  }

  /// Searches local database with Turkish character normalization, returning up to [limit] results.
  List<DrugItem> searchLocal(String query, {int limit = 30}) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final normalizedQuery = normalize(trimmed);
    final lowerQuery = trimmed.toLowerCase();

    final results = <DrugItem>[];
    for (final drug in _localDrugs) {
      final lowerName = drug.name.toLowerCase();
      final barcode = drug.barcode?.toLowerCase() ?? '';

      // Match by exact lower or normalized or barcode
      if (lowerName.contains(lowerQuery) ||
          normalize(drug.name).contains(normalizedQuery) ||
          (barcode.isNotEmpty && barcode.contains(lowerQuery))) {
        results.add(drug);
        if (results.length >= limit) break;
      }
    }
    return results;
  }

  /// Queries the OpenFDA Drug Label API for brand names matching [query].
  /// Isolated with try-catch so network issues, timeouts, or 404s never break the app.
  /// [enableExternalApi] false olduğunda harici ağ çağrısı yapmadan doğrudan boş liste döner.
  Future<List<DrugItem>> searchOpenFda(String query, {int limit = 10}) async {
    if (!enableExternalApi) return [];

    final trimmed = query.trim();
    // Per skill rules: Only trigger external API when at least 3 letters are entered
    if (trimmed.length < 3) return [];

    try {
      final encoded = Uri.encodeComponent(trimmed);
      final uri = Uri.parse(
        'https://api.fda.gov/drug/label.json?search=openfda.brand_name:"$encoded"&limit=$limit',
      );

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? rawResults = data['results'];
        if (rawResults == null) return [];

        final Set<String> brandNames = {};
        final List<DrugItem> apiDrugs = [];

        for (final item in rawResults) {
          if (item is Map<String, dynamic>) {
            final openFda = item['openfda'];
            if (openFda is Map<String, dynamic>) {
              final brandList = openFda['brand_name'];
              if (brandList is List) {
                for (final brand in brandList) {
                  final brandStr = brand.toString().trim();
                  if (brandStr.isNotEmpty && brandNames.add(brandStr.toLowerCase())) {
                    apiDrugs.add(DrugItem.fromFda(brandStr));
                  }
                }
              }
            }
          }
        }
        return apiDrugs;
      } else {
        // 404 or other status code: OpenFDA returns 404 when no records match.
        return [];
      }
    } catch (e) {
      // Safe fallback: Log error, return empty list, do not fail
      debugPrint('[DrugService] OpenFDA API request error (continuing with local results): $e');
      return [];
    }
  }

  /// Main search method:
  /// API mimarisine tam entegredir. [enableExternalApi] pasifken yalnızca yerel JSON
  /// kataloğunu (`assets/data/turk_ilaclari.json`) sorgular.
  Future<List<DrugItem>> searchDrugs(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // Ensure database is ready
    if (!_isInitialized) {
      await init();
    }

    // Harici API kapalıysa doğrudan yerel JSON kataloğunu kullanır
    if (!enableExternalApi) {
      return searchLocal(trimmed);
    }

    // Run local search and API request in parallel
    final Future<List<DrugItem>> localSearchFuture = Future.sync(() => searchLocal(trimmed));
    final Future<List<DrugItem>> openFdaFuture = searchOpenFda(trimmed);

    final results = await Future.wait([
      localSearchFuture,
      openFdaFuture,
    ]);

    final List<DrugItem> localResults = results[0];
    final List<DrugItem> apiResults = results[1];

    // Combine results, keeping track of unique names
    final Set<String> seenNames = {};
    final List<DrugItem> combined = [];

    for (final item in localResults) {
      if (seenNames.add(normalize(item.name))) {
        combined.add(item);
      }
    }

    for (final item in apiResults) {
      if (seenNames.add(normalize(item.name))) {
        combined.add(item);
      }
    }

    return combined;
  }

  /// Debounced search helper: cancels previous pending request and waits [durationMs] (default 400ms)
  void searchDebounced(
    String query, {
    int durationMs = 400,
    required void Function(List<DrugItem> results) onResults,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: durationMs), () async {
      final results = await searchDrugs(query);
      onResults(results);
    });
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
