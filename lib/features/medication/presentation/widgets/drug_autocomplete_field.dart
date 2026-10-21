// ==============================================================================
// DOSYA ADI: lib/features/medication/presentation/widgets/drug_autocomplete_field.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Gerçek zamanlı ve gecikmeli (debounced) ilaç arama / tamamlama giriş alanını oluşturur.
// - Yerel Türkiye İlaç Listesi (`turk_ilaclari.json`) ve OpenFDA API sonuçlarını harmanlayarak listeler.
// - Kullanıcı aradığı ilacı bulamazsa özel/manuel ilaç adı ekleme seçeneği sunar.
// - İlaç Ekleme Sekmesi (MedicationAddTab) tarafından doğrudan kullanılır.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/drug_item.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/l10n/app_l10n.dart';

/// [DrugAutocompleteField] yerel ve global veritabanında anlık ilaç arayan otomatik tamamlama bileşeni.
class DrugAutocompleteField extends ConsumerStatefulWidget {
  final ValueChanged<DrugItem> onDrugSelected;
  final ValueChanged<String> onCustomDrugAdd;
  final TextEditingController? controller;

  const DrugAutocompleteField({
    super.key,
    required this.onDrugSelected,
    required this.onCustomDrugAdd,
    this.controller,
  });

  @override
  ConsumerState<DrugAutocompleteField> createState() => _DrugAutocompleteFieldState();
}

class _DrugAutocompleteFieldState extends ConsumerState<DrugAutocompleteField> {
  late final TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  List<DrugItem> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  /// Kullanıcı arama metnini değiştirdiğinde 400ms gecikmeli (debounce) arama başlatır.
  void _onQueryChanged(String query) {
    _currentQuery = query.trim();
    if (_currentQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final drugService = ref.read(drugServiceProvider);
    drugService.searchDebounced(
      _currentQuery,
      durationMs: 400,
      onResults: (results) {
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      },
    );
  }

  /// Arama kutusunu ve arama sonuçlarını temizler.
  void _clearSearch() {
    _textController.clear();
    _onQueryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final localCount = _searchResults.where((d) => d.isLocal).length;
    final apiCount = _searchResults.where((d) => d.isGlobalApi).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Input Box
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          onChanged: _onQueryChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.medSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_textController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: _clearSearch,
                    tooltip: l10n.clear,
                  ),
              ],
            ),
          ),
        ),

        // Autocomplete Results Container
        if (_hasSearched && _currentQuery.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162332) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Results Summary Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isLoading
                              ? l10n.searchingBoth
                              : l10n.searchResultsCount(_searchResults.length, localCount, apiCount),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                      ],
                    ),
                  ),

                  // Results List
                  if (_searchResults.isNotEmpty)
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: theme.colorScheme.onSurface.withOpacity(0.06),
                        ),
                        itemBuilder: (context, index) {
                          final drug = _searchResults[index];
                          return _buildDrugTile(context, drug);
                        },
                      ),
                    )
                  else if (!_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          l10n.noDrugFound(_currentQuery),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),

                  // "Listede yok mu? Yeni ilaç olarak ekle" Button
                  InkWell(
                    onTap: () {
                      widget.onCustomDrugAdd(_currentQuery);
                      _clearSearch();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${l10n.notInListAddCustom}: "$_currentQuery"',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDrugTile(BuildContext context, DrugItem drug) {
    final theme = Theme.of(context);
    final isLocal = drug.isLocal;

    final badgeColor = isLocal ? const Color(0xFF2E7D32) : const Color(0xFF0096C7);
    final badgeText = isLocal ? '🇹🇷 Yerel' : '🌐 OpenFDA';

    return InkWell(
      onTap: () {
        widget.onDrugSelected(drug);
        _clearSearch();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isLocal ? Icons.medication_rounded : Icons.public_rounded,
                size: 18,
                color: badgeColor,
              ),
            ),
            const SizedBox(width: 12),

            // Drug Name & Barcode
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drug.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (drug.barcode != null && drug.barcode!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Barkod: ${drug.barcode}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Source Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
