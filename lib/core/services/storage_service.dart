// ==============================================================================
// DOSYA ADI: lib/core/services/storage_service.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - SharedPreferences tabanlı yerel kalıcı veri depolama (Local Persistence) servisidir.
// - İlk kurulumda örnek gerçekçi profilleri, ilaçları, doz saatlerini ve sağlık verilerini tohumlar (Seed Data).
// - Profilleri, ilaçları, doz kullanım loglarını, aktif profil seçimini, dil ve tema tercihlerini
//   cihaz hafızasında JSON formatında saklar ve tüm uygulamanın veri bütünlüğünü sağlar.
// ==============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import '../models/medication_model.dart';
import '../models/intake_log_model.dart';
import '../models/health_data_model.dart';

/// SharedPreferences tabanlı yerel depolama işlemlerini yürüten servis sınıfı.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
    await _seedInitialDataIfNeeded();
  }

  // --- Seed Data ---
  Future<void> _seedInitialDataIfNeeded() async {
    final hasSeeded = _prefs?.getBool('has_seeded_v1') ?? false;
    if (!hasSeeded) {
      // 1. Initial Profiles
      final initialProfiles = [
        ProfileModel(
          id: 'p1',
          name: 'Ahmet Yılmaz',
          birthDate: DateTime(1984, 5, 12), // 42 years old -> adult_male
          gender: 'male',
          relation: 'self',
        ),
        ProfileModel(
          id: 'p2',
          name: 'Fatma Yılmaz',
          birthDate: DateTime(1956, 3, 20), // 70 years old -> elder_female
          gender: 'female',
          relation: 'mother',
        ),
      ];
      await saveProfiles(initialProfiles);
      await saveActiveProfileId('p1');

      // 2. Initial Medications for Ahmet (p1)
      final now = DateTime.now();
      final initialMedsP1 = [
        MedicationModel(
          id: 'm1',
          profileId: 'p1',
          name: 'ASPIRIN 100 MG 20 TB',
          source: 'local',
          barcode: '8699546010028',
          form: 'Tablet',
          doseAmount: 1,
          doseUnit: 'Tablet',
          withFood: 'after',
          times: ['08:00'],
          frequency: 'Günde 1 kez',
          treatmentStartDate: now.subtract(const Duration(days: 10)),
          treatmentEndDate: now.add(const Duration(days: 60)),
          expiryDate: now.add(const Duration(days: 365)),
          stockRemaining: 18,
          lowThreshold: 5,
          perDose: 1,
          active: true,
        ),
        MedicationModel(
          id: 'm2',
          profileId: 'p1',
          name: 'LIPITOR 20 MG 30 FTB',
          source: 'local',
          barcode: '8699532095015',
          form: 'Tablet',
          doseAmount: 1,
          doseUnit: 'Tablet',
          withFood: 'after',
          times: ['20:00'],
          frequency: 'Günde 1 kez',
          treatmentStartDate: now.subtract(const Duration(days: 20)),
          expiryDate: now.add(const Duration(days: 20)), // Expiring soon (<30 days)
          stockRemaining: 4, // Low stock! (<5)
          lowThreshold: 5,
          perDose: 1,
          active: true,
        ),
      ];

      // Medications for Fatma (p2)
      final initialMedsP2 = [
        MedicationModel(
          id: 'm3',
          profileId: 'p2',
          name: 'CORASPIN 100 MG 30 TB',
          source: 'local',
          barcode: '8699546130238',
          form: 'Tablet',
          doseAmount: 1,
          doseUnit: 'Tablet',
          withFood: 'before',
          times: ['09:00'],
          frequency: 'Günde 1 kez',
          treatmentStartDate: now.subtract(const Duration(days: 30)),
          expiryDate: now.add(const Duration(days: 400)),
          stockRemaining: 24,
          lowThreshold: 6,
          perDose: 1,
          active: true,
        ),
        MedicationModel(
          id: 'm4',
          profileId: 'p2',
          name: 'GLIFOR 1000 MG 100 FTB',
          source: 'local',
          barcode: '8699569090717',
          form: 'Tablet',
          doseAmount: 1,
          doseUnit: 'Tablet',
          withFood: 'after',
          times: ['09:00', '21:00'],
          frequency: 'Günde 2 kez',
          treatmentStartDate: now.subtract(const Duration(days: 15)),
          expiryDate: now.add(const Duration(days: 500)),
          stockRemaining: 42,
          lowThreshold: 10,
          perDose: 1,
          active: true,
        ),
      ];

      await saveMedications([...initialMedsP1, ...initialMedsP2]);

      // 3. Initial Smart Watch Health Data
      final initialHealth = [
        HealthDataModel(
          id: 'h1',
          profileId: 'p1',
          heartRate: 74,
          steps: 8420,
          sleepHours: 7.2,
          spo2: 98,
          recordedAt: now,
          isWatchConnected: true,
        ),
        HealthDataModel(
          id: 'h2',
          profileId: 'p2',
          heartRate: 68,
          steps: 4210,
          sleepHours: 6.8,
          spo2: 97,
          recordedAt: now,
          isWatchConnected: false,
        ),
      ];
      await saveHealthDataList(initialHealth);

      await _prefs?.setBool('has_seeded_v1', true);
    }
  }

  // --- Profiles ---
  List<ProfileModel> getProfiles() {
    final raw = _prefs?.getString('app_profiles');
    if (raw == null) return [];
    try {
      final List<dynamic> list = json.decode(raw);
      return list.map((e) => ProfileModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[StorageService] Error reading profiles: $e');
      return [];
    }
  }

  Future<void> saveProfiles(List<ProfileModel> profiles) async {
    final raw = json.encode(profiles.map((p) => p.toJson()).toList());
    await _prefs?.setString('app_profiles', raw);
  }

  String? getActiveProfileId() {
    return _prefs?.getString('active_profile_id');
  }

  Future<void> saveActiveProfileId(String id) async {
    await _prefs?.setString('active_profile_id', id);
  }

  // --- Medications ---
  List<MedicationModel> getMedications() {
    final raw = _prefs?.getString('app_medications');
    if (raw == null) return [];
    try {
      final List<dynamic> list = json.decode(raw);
      return list.map((e) => MedicationModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[StorageService] Error reading medications: $e');
      return [];
    }
  }

  Future<void> saveMedications(List<MedicationModel> meds) async {
    final raw = json.encode(meds.map((m) => m.toJson()).toList());
    await _prefs?.setString('app_medications', raw);
  }

  // --- Intake Logs ---
  List<IntakeLogModel> getIntakeLogs() {
    final raw = _prefs?.getString('app_intake_logs');
    if (raw == null) return [];
    try {
      final List<dynamic> list = json.decode(raw);
      return list.map((e) => IntakeLogModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[StorageService] Error reading intake logs: $e');
      return [];
    }
  }

  Future<void> saveIntakeLogs(List<IntakeLogModel> logs) async {
    final raw = json.encode(logs.map((l) => l.toJson()).toList());
    await _prefs?.setString('app_intake_logs', raw);
  }

  // --- Health Data ---
  List<HealthDataModel> getHealthDataList() {
    final raw = _prefs?.getString('app_health_data');
    if (raw == null) return [];
    try {
      final List<dynamic> list = json.decode(raw);
      return list.map((e) => HealthDataModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[StorageService] Error reading health data: $e');
      return [];
    }
  }

  Future<void> saveHealthDataList(List<HealthDataModel> list) async {
    final raw = json.encode(list.map((h) => h.toJson()).toList());
    await _prefs?.setString('app_health_data', raw);
  }

  // --- Settings: Theme, Language, Snooze ---
  bool isDarkMode() {
    return _prefs?.getBool('app_dark_mode') ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    await _prefs?.setBool('app_dark_mode', isDark);
  }

  String getLanguage() {
    return _prefs?.getString('app_language') ?? 'tr';
  }

  Future<void> setLanguage(String lang) async {
    await _prefs?.setString('app_language', lang);
  }

  int getSnoozeMinutes() {
    return _prefs?.getInt('app_snooze_minutes') ?? 10;
  }

  Future<void> setSnoozeMinutes(int minutes) async {
    await _prefs?.setInt('app_snooze_minutes', minutes);
  }

  int getMissedThresholdMinutes() {
    return _prefs?.getInt('app_missed_minutes') ?? 60;
  }

  Future<void> setMissedThresholdMinutes(int minutes) async {
    await _prefs?.setInt('app_missed_minutes', minutes);
  }

  bool isLoggedIn() {
    return _prefs?.getBool('app_is_logged_in') ?? true;
  }

  Future<void> setLoggedIn(bool val) async {
    await _prefs?.setBool('app_is_logged_in', val);
  }
}
