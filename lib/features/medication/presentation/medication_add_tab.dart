// ==============================================================================
// DOSYA ADI: lib/features/medication/presentation/medication_add_tab.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Ekran 6 (İlaç Ekleme ve Çıkarma / Yönetim) arayüzünü oluşturur.
// - Otomatik tamamlama (DrugAutocompleteField) veya özel form aracılığıyla yeni ilaç tanımlama imkanı sunar.
// - Doz sıklığı (günde 1, 2, 3, 4 kez vb.), saat slotları, aç/tok durumu, stok ve son kullanma tarihini ayarlar.
// - Mükerrer / aynı isimde ilaç eklenmek istendiğinde kullanıcıyı uyaran diyalog görüntüler.
// - Aktif profilin mevcut ilaçlarını listeler ve ilaç silme (pasife alma) işlemini yönetir.
// - Ana Gezinme Ekranı'nın (MainNavigationScreen) 2. sekmesi olarak çalışır.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/drug_item.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/stock_indicator.dart';
import '../../../core/widgets/expiry_badge.dart';
import 'widgets/drug_autocomplete_field.dart';

/// [MedicationAddTab] ilaç arama, yeni ilaç parametrelerini yapılandırma ve ilaç çıkarma sekmesi bileşeni.
class MedicationAddTab extends ConsumerStatefulWidget {
  const MedicationAddTab({super.key});

  @override
  ConsumerState<MedicationAddTab> createState() => _MedicationAddTabState();
}

class _MedicationAddTabState extends ConsumerState<MedicationAddTab> {
  final _formKey = GlobalKey<FormState>();

  // Form State
  String _drugName = '';
  String _source = 'custom';
  String? _barcode;
  String _form = 'Tablet';
  double _doseAmount = 1.0;
  String _doseUnit = 'Tablet';
  String _withFood = 'after'; // 'before' | 'after' | 'none'
  String _frequency = 'Günde 1 kez';
  List<String> _times = ['09:00'];
  final DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  DateTime? _expiryDate;
  int _stockRemaining = 30;
  int _lowThreshold = 5;
  final int _perDose = 1;

  bool _isFormOpen = false;
  bool _isSaving = false;

  final List<String> _formOptions = [
    'Tablet',
    'Kapsül',
    'Şurup',
    'İğne / Ampul',
    'Damla',
    'Merhem / Krem',
    'Sprey',
    'Saşe / Toz',
  ];

  final List<String> _unitOptions = [
    'Tablet',
    'Kapsül',
    'Ölçek',
    'Damla',
    'mg',
    'ml',
    'Doz',
  ];

  final List<String> _frequencyOptions = [
    'Günde 1 kez',
    'Günde 2 kez',
    'Günde 3 kez',
    'Günde 4 kez',
    'Gün aşırı',
    'İhtiyaç halinde',
  ];

  void _onFrequencyChanged(String? val) {
    if (val == null) return;
    setState(() {
      _frequency = val;
      if (val == 'Günde 1 kez') {
        _times = ['09:00'];
      } else if (val == 'Günde 2 kez') {
        _times = ['09:00', '21:00'];
      } else if (val == 'Günde 3 kez') {
        _times = ['08:00', '14:00', '20:00'];
      } else if (val == 'Günde 4 kez') {
        _times = ['08:00', '12:00', '18:00', '22:00'];
      } else if (val == 'Gün aşırı') {
        _times = ['09:00'];
      } else if (val == 'İhtiyaç halinde') {
        _times = ['09:00'];
      }
    });
  }

  /// Otomatik tamamlama listesinden bir ilaç seçildiğinde form alanlarını ilacın türüne göre otomatik doldurur.
  void _onDrugSelectedFromAutocomplete(DrugItem drug) {
    final l10n = AppL10n.of(context);
    setState(() {
      _drugName = drug.name;
      _source = drug.isLocal ? 'local' : 'api';
      _barcode = drug.barcode;

      // Guess form if present in drug name
      final lower = drug.name.toLowerCase();
      if (lower.contains('surup') || lower.contains('şurup')) {
        _form = 'Şurup';
        _doseUnit = 'Ölçek';
      } else if (lower.contains('damla')) {
        _form = 'Damla';
        _doseUnit = 'Damla';
      } else if (lower.contains('krem') || lower.contains('merhem') || lower.contains('jel')) {
        _form = 'Merhem / Krem';
        _doseUnit = 'Doz';
      } else if (lower.contains('ampul') || lower.contains('flakon') || lower.contains('enj')) {
        _form = 'İğne / Ampul';
        _doseUnit = 'Doz';
      } else if (lower.contains('kap') || lower.contains('kapsul') || lower.contains('kapsül')) {
        _form = 'Kapsül';
        _doseUnit = 'Kapsül';
      } else {
        _form = 'Tablet';
        _doseUnit = 'Tablet';
      }

      _isFormOpen = true;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.selectedDrugInfo(drug.name, drug.source)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCustomDrugAdd(String query) {
    setState(() {
      _drugName = query;
      _source = 'custom';
      _barcode = null;
      _form = 'Tablet';
      _doseUnit = 'Tablet';
      _isFormOpen = true;
    });
  }

  void _addTimeSlot() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      final timeStr = '$hourStr:$minuteStr';
      if (!_times.contains(timeStr)) {
        setState(() {
          _times.add(timeStr);
          _times.sort();
        });
      }
    }
  }

  void _removeTimeSlot(String t) {
    if (_times.length <= 1) return;
    setState(() {
      _times.remove(t);
    });
  }

  /// Yapılandırılan ilacı doğrular, mükerrer kontrolü yapar ve [MedicationsNotifier] üzerinden kaydeder.
  Future<void> _saveMedication() async {
    if (_isSaving) return;
    final activeProfile = ref.read(activeProfileProvider);
    final l10n = AppL10n.of(context);
    if (activeProfile == null) return;

    if (_drugName.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorRequiredField),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check if an active medication with the same name already exists
    final activeMeds = ref.read(activeMedsForCurrentProfileProvider);
    final alreadyExists = activeMeds.any(
      (m) => m.name.trim().toLowerCase() == _drugName.trim().toLowerCase(),
    );

    if (alreadyExists) {
      final shouldAdd = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.duplicateTitle),
          content: Text(l10n.duplicateMedicationWarning(_drugName.trim())),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.add),
            ),
          ],
        ),
      );
      if (shouldAdd != true) return;
    }

    _isSaving = true;
    try {
      final uniqueTimes = _times.toSet().toList()..sort();
      final newMed = MedicationModel(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        profileId: activeProfile.id,
        name: _drugName.trim(),
        source: _source,
        barcode: _barcode,
        form: _form,
        doseAmount: _doseAmount,
        doseUnit: _doseUnit,
        withFood: _withFood,
        times: uniqueTimes.isEmpty ? ['09:00'] : uniqueTimes,
        frequency: _frequency,
        treatmentStartDate: _startDate,
        treatmentEndDate: _endDate,
        expiryDate: _expiryDate,
        stockRemaining: _stockRemaining,
        lowThreshold: _lowThreshold,
        perDose: _perDose,
        active: true,
      );

      await ref.read(medicationsProvider.notifier).addMedication(newMed);

      if (mounted) {
        setState(() {
          _isFormOpen = false;
          _drugName = '';
          _barcode = null;
          _times = ['09:00'];
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.medicationAddedSuccess(newMed.name)),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _isSaving = false;
    }
  }

  /// İlacın tedaviden kaldırılması (pasife alınması) için onay iletişim kutusunu açar.
  void _confirmDeactivateMedication(MedicationModel med) {
    final l10n = AppL10n.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeMedication),
        content: Text(l10n.removeMedConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(medicationsProvider.notifier).deactivateMedication(med.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.medicationDeactivatedSuccess(med.name)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeMeds = ref.watch(activeMedsForCurrentProfileProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title & Search Instruction
            Text(
              l10n.navAddRemove,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.isTr
                  ? 'Türk ilaçları kataloğundan (8500+ kayıt) veya OpenFDA canlı API\'sinden arayarak ilaç ekleyin:'
                  : 'Search from Turkish drug catalog (8500+ items) or live OpenFDA API:',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 14),

            // Autocomplete Field
            DrugAutocompleteField(
              onDrugSelected: _onDrugSelectedFromAutocomplete,
              onCustomDrugAdd: _onCustomDrugAdd,
            ),
            const SizedBox(height: 20),

            // Medication Configuration Form (Collapsible/Dynamic)
            if (_isFormOpen) ...[
              _buildAddMedicationForm(context, l10n, isDark),
              const SizedBox(height: 24),
            ],

            // Current Active Medications Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.currentMedsTitle} (${activeMeds.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Active Medications List
            if (activeMeds.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 48,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noActiveMeds,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeMeds.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final med = activeMeds[index];
                  return _buildRegisteredMedCard(context, med, l10n);
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMedicationForm(BuildContext context, AppL10n l10n, bool isDark) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF14202D) : const Color(0xFFF2F7F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_note_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.customMedFormTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      setState(() {
                        _isFormOpen = false;
                      });
                    },
                    tooltip: l10n.close,
                  ),
                ],
              ),
              const Divider(height: 20),

              // Drug Name Field
              TextFormField(
                initialValue: _drugName,
                decoration: InputDecoration(
                  labelText: l10n.drugNameLabel,
                  prefixIcon: const Icon(Icons.medication_rounded),
                ),
                onChanged: (val) => _drugName = val,
              ),
              if (_barcode != null && _barcode!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Barkod: $_barcode • Kaynak: ${_source == 'local' ? l10n.localSourceBadge : l10n.globalApiBadge}',
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                  ),
                ),
              const SizedBox(height: 14),

              // Form & Dose Unit
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _form,
                      decoration: InputDecoration(labelText: l10n.drugFormLabel),
                      items: _formOptions.map((f) => DropdownMenuItem(value: f, child: Text(l10n.formatForm(f)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _form = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _doseUnit,
                      decoration: InputDecoration(labelText: l10n.doseUnitLabel),
                      items: _unitOptions.map((u) => DropdownMenuItem(value: u, child: Text(l10n.formatDoseUnit(u)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _doseUnit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Dose Amount & Food Relation
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: _doseAmount.toString(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.doseAmountLabel),
                      onChanged: (val) {
                        _doseAmount = double.tryParse(val) ?? 1.0;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _withFood,
                      decoration: InputDecoration(labelText: l10n.foodRelationLabel),
                      items: [
                        DropdownMenuItem(value: 'before', child: Text(l10n.withFoodBefore)),
                        DropdownMenuItem(value: 'after', child: Text(l10n.withFoodAfter)),
                        DropdownMenuItem(value: 'none', child: Text(l10n.withFoodNone)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _withFood = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Frequency & Times
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: InputDecoration(labelText: l10n.frequencyLabel),
                items: _frequencyOptions.map((f) => DropdownMenuItem(value: f, child: Text(l10n.formatFrequency(f)))).toList(),
                onChanged: _onFrequencyChanged,
              ),
              const SizedBox(height: 12),

              // Times Chip List
              Text(
                l10n.timesLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _times)
                    Chip(
                      avatar: const Icon(Icons.access_time_rounded, size: 16),
                      label: Text(t),
                      onDeleted: _times.length > 1 ? () => _removeTimeSlot(t) : null,
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 16),
                    label: Text(l10n.addTime),
                    onPressed: _addTimeSlot,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stock Management: Remaining & Low Threshold
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _stockRemaining.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.stockRemainingLabel,
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                      ),
                      onChanged: (val) => _stockRemaining = int.tryParse(val) ?? 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _lowThreshold.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.lowThresholdLabel,
                        prefixIcon: const Icon(Icons.warning_amber_rounded),
                      ),
                      onChanged: (val) => _lowThreshold = int.tryParse(val) ?? 5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Expiry Date (SKT) Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded),
                title: Text(l10n.expiryDateLabel),
                subtitle: Text(
                  _expiryDate == null
                      ? l10n.notSelected
                      : DateFormat('MM/yyyy').format(_expiryDate!),
                  style: TextStyle(
                    color: _expiryDate == null ? Colors.grey : theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2040),
                    );
                    if (picked != null) {
                      setState(() => _expiryDate = picked);
                    }
                  },
                  child: Text(l10n.selectDate),
                ),
              ),
              const SizedBox(height: 16),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.medicalDisclaimer,
                        style: const TextStyle(fontSize: 10, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveMedication,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l10n.saveMedicationButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredMedCard(BuildContext context, MedicationModel med, AppL10n l10n) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.formatForm(med.form)} • ${med.doseAmount} ${l10n.formatDoseUnit(med.doseUnit)} • ${med.times.join(", ")}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Deactivate / Remove button
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDeactivateMedication(med),
                  tooltip: l10n.removeMedication,
                ),
              ],
            ),
            const SizedBox(height: 10),
            StockIndicator(
              remaining: med.stockRemaining,
              lowThreshold: med.lowThreshold,
            ),
            if (med.expiryDate != null) ...[
              const SizedBox(height: 6),
              ExpiryBadge(
                expiryDate: med.expiryDate,
                status: med.expiryStatus,
                daysUntil: med.daysUntilExpiry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
