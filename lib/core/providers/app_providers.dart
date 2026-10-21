// ==============================================================================
// DOSYA ADI: lib/core/providers/app_providers.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Flutter Riverpod 3 tabanlı merkezi reaktif durum yönetimi (State Management) omurgasıdır.
// - Tema modu (ThemeModeNotifier), Dil seçimi (LocaleNotifier), Profiller (ProfilesNotifier),
//   Aktif profil seçimi (ActiveProfileIdNotifier), İlaçlar (MedicationsNotifier),
//   Doz alım logları (IntakeLogsNotifier) ve Akıllı saat verilerini (HealthDataNotifier) yönetir.
// - Cascade profil silme: Profil silindiğinde ilaç ve logların otomatik silinmesini yürütür.
// - Bugünün İlaçları (TodayTimelineTab), İlaç Ekle (MedicationAddTab), Ayarlar (SettingsTab),
//   ve Akıllı Saat (SmartWatchTab) sayfalarını anlık reaktif güncellemelerle besler.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/profile_model.dart';
import '../models/medication_model.dart';
import '../models/intake_log_model.dart';
import '../models/health_data_model.dart';
import '../services/storage_service.dart';
import '../services/drug_service.dart';

export '../models/profile_model.dart';
export '../models/medication_model.dart';
export '../models/intake_log_model.dart';

// --- Services Providers ---
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
final drugServiceProvider = Provider<DrugService>((ref) => DrugService());

// --- Theme Mode Provider (Riverpod 3 Notifier) ---
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.isDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    ref.read(storageServiceProvider).setDarkMode(next == ThemeMode.dark);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// --- Locale Provider (tr / en) ---
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final storage = ref.watch(storageServiceProvider);
    return Locale(storage.getLanguage());
  }

  void toggle() {
    final nextCode = state.languageCode == 'tr' ? 'en' : 'tr';
    state = Locale(nextCode);
    ref.read(storageServiceProvider).setLanguage(nextCode);
  }

  void setLocale(String code) {
    state = Locale(code);
    ref.read(storageServiceProvider).setLanguage(code);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

// --- Profiles Provider ---
class ProfilesNotifier extends Notifier<List<ProfileModel>> {
  @override
  List<ProfileModel> build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.getProfiles();
  }

  Future<void> addProfile({
    required String name,
    required DateTime birthDate,
    required String gender,
    required String relation,
  }) async {
    final id = 'p_${DateTime.now().millisecondsSinceEpoch}';
    final newProfile = ProfileModel(
      id: id,
      name: name,
      birthDate: birthDate,
      gender: gender,
      relation: relation,
    );
    state = [...state, newProfile];
    await ref.read(storageServiceProvider).saveProfiles(state);
  }

  Future<void> updateProfile(ProfileModel updated) async {
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p
    ];
    await ref.read(storageServiceProvider).saveProfiles(state);
  }

  Future<void> deleteProfile(String profileId) async {
    state = state.where((p) => p.id != profileId).toList();
    await ref.read(storageServiceProvider).saveProfiles(state);

    // Cascade delete medications and logs for this profile
    await ref.read(medicationsProvider.notifier).deleteMedicationsForProfile(profileId);
    await ref.read(intakeLogsProvider.notifier).deleteLogsForProfile(profileId);

    // If the deleted profile was active, switch to another profile
    final activeId = ref.read(activeProfileIdProvider);
    if (activeId == profileId) {
      if (state.isNotEmpty) {
        await ref.read(activeProfileIdProvider.notifier).selectProfile(state.first.id);
      } else {
        await ref.read(activeProfileIdProvider.notifier).selectProfile('');
      }
    }
  }
}

final profilesProvider = NotifierProvider<ProfilesNotifier, List<ProfileModel>>(ProfilesNotifier.new);

// --- Active Profile ID Provider ---
class ActiveProfileIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.getActiveProfileId();
  }

  Future<void> selectProfile(String id) async {
    state = id;
    await ref.read(storageServiceProvider).saveActiveProfileId(id);
  }
}

final activeProfileIdProvider = NotifierProvider<ActiveProfileIdNotifier, String?>(ActiveProfileIdNotifier.new);

final activeProfileProvider = Provider<ProfileModel?>((ref) {
  final profiles = ref.watch(profilesProvider);
  final activeId = ref.watch(activeProfileIdProvider);
  if (profiles.isEmpty) return null;
  if (activeId == null) return profiles.first;
  try {
    return profiles.firstWhere((p) => p.id == activeId);
  } catch (_) {
    return profiles.first;
  }
});

// --- Medications Provider ---
class MedicationsNotifier extends Notifier<List<MedicationModel>> {
  @override
  List<MedicationModel> build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.getMedications();
  }

  Future<void> addMedication(MedicationModel med) async {
    state = [...state, med];
    await ref.read(storageServiceProvider).saveMedications(state);
  }

  Future<void> updateMedication(MedicationModel updated) async {
    state = [
      for (final m in state)
        if (m.id == updated.id) updated else m
    ];
    await ref.read(storageServiceProvider).saveMedications(state);
  }

  /// Soft delete per ilaccikarmaskill: sets active = false
  Future<void> deactivateMedication(String id) async {
    state = [
      for (final m in state)
        if (m.id == id) m.copyWith(active: false) else m
    ];
    await ref.read(storageServiceProvider).saveMedications(state);
  }

  /// Reactivate previously past medication
  Future<void> reactivateMedication(String id) async {
    state = [
      for (final m in state)
        if (m.id == id) m.copyWith(active: true) else m
    ];
    await ref.read(storageServiceProvider).saveMedications(state);
  }

  /// Decrement stock when medicine is taken
  Future<void> decrementStock(String medId, int amount) async {
    state = [
      for (final m in state)
        if (m.id == medId)
          m.copyWith(
            stockRemaining: (m.stockRemaining - amount).clamp(0, 99999),
          )
        else
          m
    ];
    await ref.read(storageServiceProvider).saveMedications(state);
  }

  /// Refill stock
  Future<void> refillStock(String medId, int amount) async {
    state = [
      for (final m in state)
        if (m.id == medId)
          m.copyWith(
            stockRemaining: m.stockRemaining + amount,
          )
        else
          m
    ];
    await ref.read(storageServiceProvider).saveMedications(state);
  }

  /// Remove all medications for a deleted profile
  Future<void> deleteMedicationsForProfile(String profileId) async {
    state = state.where((m) => m.profileId != profileId).toList();
    await ref.read(storageServiceProvider).saveMedications(state);
  }
}

final medicationsProvider = NotifierProvider<MedicationsNotifier, List<MedicationModel>>(MedicationsNotifier.new);

// --- Active & Past Meds Filtered by Current Profile ---
final activeMedsForCurrentProfileProvider = Provider<List<MedicationModel>>((ref) {
  final allMeds = ref.watch(medicationsProvider);
  final activeProfile = ref.watch(activeProfileProvider);
  if (activeProfile == null) return [];
  return allMeds.where((m) => m.profileId == activeProfile.id && m.active).toList();
});

final pastMedsForCurrentProfileProvider = Provider<List<MedicationModel>>((ref) {
  final allMeds = ref.watch(medicationsProvider);
  final activeProfile = ref.watch(activeProfileProvider);
  if (activeProfile == null) return [];
  return allMeds.where((m) => m.profileId == activeProfile.id && !m.active).toList();
});

// --- Intake Logs Provider ---
class IntakeLogsNotifier extends Notifier<List<IntakeLogModel>> {
  @override
  List<IntakeLogModel> build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.getIntakeLogs();
  }

  Future<void> logAction({
    required String medicationId,
    required String profileId,
    required String scheduledTime,
    required String status, // 'taken' | 'snoozed' | 'skipped'
  }) async {
    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final logId = '${medicationId}_${dateKey}_$scheduledTime';

    final newLog = IntakeLogModel(
      id: logId,
      medicationId: medicationId,
      profileId: profileId,
      dateKey: dateKey,
      scheduledTime: scheduledTime,
      takenAt: status == 'taken' ? now : null,
      status: status,
    );

    // Replace if exists, else append
    final existingIndex = state.indexWhere((l) => l.id == logId);
    if (existingIndex >= 0) {
      final updated = List<IntakeLogModel>.from(state);
      updated[existingIndex] = newLog;
      state = updated;
    } else {
      state = [...state, newLog];
    }
    await ref.read(storageServiceProvider).saveIntakeLogs(state);
  }

  /// Remove all intake logs for a deleted profile
  Future<void> deleteLogsForProfile(String profileId) async {
    state = state.where((l) => l.profileId != profileId).toList();
    await ref.read(storageServiceProvider).saveIntakeLogs(state);
  }
}

final intakeLogsProvider = NotifierProvider<IntakeLogsNotifier, List<IntakeLogModel>>(IntakeLogsNotifier.new);

// --- Dose Slot View Model for Today's Timeline ---
class DoseSlot {
  final MedicationModel medication;
  final String time;
  final IntakeLogModel? log;

  DoseSlot({
    required this.medication,
    required this.time,
    this.log,
  });

  String get status => log?.status ?? 'pending';
}

final todayTimelineProvider = Provider<List<DoseSlot>>((ref) {
  final activeMeds = ref.watch(activeMedsForCurrentProfileProvider);
  final logs = ref.watch(intakeLogsProvider);
  final now = DateTime.now();
  final dateKey = DateFormat('yyyy-MM-dd').format(now);

  final List<DoseSlot> slots = [];

  for (final med in activeMeds) {
    for (final time in med.times) {
      final logId = '${med.id}_${dateKey}_$time';
      IntakeLogModel? matchingLog;
      try {
        matchingLog = logs.firstWhere((l) => l.id == logId);
      } catch (_) {
        matchingLog = null;
      }
      slots.add(DoseSlot(
        medication: med,
        time: time,
        log: matchingLog,
      ));
    }
  }

  // Sort slots by time (e.g. 08:00 before 20:00)
  slots.sort((a, b) => a.time.compareTo(b.time));
  return slots;
});

// --- Medication Today Grouped Item View Model ---
class MedicationTodayItem {
  final MedicationModel medication;
  final List<DoseSlot> doseSlots;

  MedicationTodayItem({
    required this.medication,
    required this.doseSlots,
  });

  bool get isAllTaken => doseSlots.isNotEmpty && doseSlots.every((s) => s.status == 'taken');
  int get takenCount => doseSlots.where((s) => s.status == 'taken').length;
  int get totalCount => doseSlots.length;
}

final todayGroupedMedicationsProvider = Provider<List<MedicationTodayItem>>((ref) {
  final activeMeds = ref.watch(activeMedsForCurrentProfileProvider);
  final logs = ref.watch(intakeLogsProvider);
  final now = DateTime.now();
  final dateKey = DateFormat('yyyy-MM-dd').format(now);

  final List<MedicationTodayItem> items = [];

  for (final med in activeMeds) {
    final List<DoseSlot> slots = [];
    for (final time in med.times) {
      final logId = '${med.id}_${dateKey}_$time';
      IntakeLogModel? matchingLog;
      try {
        matchingLog = logs.firstWhere((l) => l.id == logId);
      } catch (_) {
        matchingLog = null;
      }
      slots.add(DoseSlot(
        medication: med,
        time: time,
        log: matchingLog,
      ));
    }
    slots.sort((a, b) => a.time.compareTo(b.time));
    items.add(MedicationTodayItem(medication: med, doseSlots: slots));
  }

  return items;
});

// --- Smart Watch Health Data Provider ---
class HealthDataNotifier extends Notifier<List<HealthDataModel>> {
  @override
  List<HealthDataModel> build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.getHealthDataList();
  }

  Future<void> toggleWatchConnection(String profileId) async {
    final now = DateTime.now();
    final index = state.indexWhere((h) => h.profileId == profileId);

    if (index >= 0) {
      final current = state[index];
      final updated = current.copyWith(
        isWatchConnected: !current.isWatchConnected,
        recordedAt: now,
      );
      final list = List<HealthDataModel>.from(state);
      list[index] = updated;
      state = list;
    } else {
      final newModel = HealthDataModel(
        id: 'h_${profileId}_${now.millisecondsSinceEpoch}',
        profileId: profileId,
        heartRate: 72,
        steps: 6850,
        sleepHours: 7.4,
        spo2: 98,
        recordedAt: now,
        isWatchConnected: true,
      );
      state = [...state, newModel];
    }
    await ref.read(storageServiceProvider).saveHealthDataList(state);
  }
}

final healthDataListProvider = NotifierProvider<HealthDataNotifier, List<HealthDataModel>>(HealthDataNotifier.new);

final currentProfileHealthDataProvider = Provider<HealthDataModel?>((ref) {
  final activeProfile = ref.watch(activeProfileProvider);
  if (activeProfile == null) return null;
  final list = ref.watch(healthDataListProvider);
  try {
    return list.firstWhere((h) => h.profileId == activeProfile.id);
  } catch (_) {
    return HealthDataModel(
      id: 'default_${activeProfile.id}',
      profileId: activeProfile.id,
      heartRate: 72,
      steps: 5400,
      sleepHours: 7.0,
      spo2: 98,
      recordedAt: DateTime.now(),
      isWatchConnected: false,
    );
  }
});
