import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilactakip/main.dart';
import 'package:flutter/material.dart';
import 'package:ilactakip/core/models/drug_item.dart';
import 'package:ilactakip/core/models/profile_model.dart';
import 'package:ilactakip/core/models/medication_model.dart';
import 'package:ilactakip/core/services/drug_service.dart';
import 'package:ilactakip/core/l10n/app_l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DrugItem Model Tests', () {
    test('creates local drug item with correct source', () {
      final drug = DrugItem.fromLocalJson({
        'name': 'PAROL 500 MG 20 TB',
        'barcode': '8699717010109',
      });
      expect(drug.name, 'PAROL 500 MG 20 TB');
      expect(drug.barcode, '8699717010109');
      expect(drug.source, 'Yerel');
      expect(drug.isLocal, true);
      expect(drug.isGlobalApi, false);
    });

    test('creates OpenFDA drug item with Global API source', () {
      final drug = DrugItem.fromFda('Aspirin');
      expect(drug.name, 'Aspirin');
      expect(drug.barcode, null);
      expect(drug.source, 'Global API');
      expect(drug.isLocal, false);
      expect(drug.isGlobalApi, true);
    });
  });

  group('Automatic Avatar Computation Tests (avatarskill.md)', () {
    test('child age group produces child_female and child_male', () {
      final childFemaleDate = DateTime.now().subtract(const Duration(days: 365 * 10));
      final childMaleDate = DateTime.now().subtract(const Duration(days: 365 * 12));

      expect(ProfileModel.computeAvatarKey(childFemaleDate, 'female'), 'child_female');
      expect(ProfileModel.computeAvatarKey(childMaleDate, 'male'), 'child_male');
    });

    test('adult age group produces adult_female and adult_male', () {
      final adultFemaleDate = DateTime.now().subtract(const Duration(days: 365 * 35));
      final adultMaleDate = DateTime.now().subtract(const Duration(days: 365 * 40));

      expect(ProfileModel.computeAvatarKey(adultFemaleDate, 'female'), 'adult_female');
      expect(ProfileModel.computeAvatarKey(adultMaleDate, 'male'), 'adult_male');
    });

    test('elder age group produces elder_female and elder_male', () {
      final elderFemaleDate = DateTime.now().subtract(const Duration(days: 365 * 68));
      final elderMaleDate = DateTime.now().subtract(const Duration(days: 365 * 72));

      expect(ProfileModel.computeAvatarKey(elderFemaleDate, 'female'), 'elder_female');
      expect(ProfileModel.computeAvatarKey(elderMaleDate, 'male'), 'elder_male');
    });
  });

  group('DrugService Tests', () {
    test('normalization handles Turkish characters correctly', () {
      expect(DrugService.normalize('İLAÇ'), 'ilac');
      expect(DrugService.normalize('Şurup'), 'surup');
      expect(DrugService.normalize('Öksürük'), 'oksuruk');
      expect(DrugService.normalize('Çocuk'), 'cocuk');
    });
  });

  group('MedicationModel Stock & Expiry Tests', () {
    test('identifies low stock and out of stock accurately', () {
      final lowMed = MedicationModel(
        id: '1',
        profileId: 'p1',
        name: 'Test Med',
        times: ['08:00'],
        treatmentStartDate: DateTime.now(),
        stockRemaining: 3,
        lowThreshold: 5,
      );
      expect(lowMed.isLowStock, true);
      expect(lowMed.isOutOfStock, false);

      final emptyMed = lowMed.copyWith(stockRemaining: 0);
      expect(emptyMed.isOutOfStock, true);
      expect(emptyMed.isLowStock, false);
    });

    test('calculates expiry status correctly', () {
      final now = DateTime.now();
      final expiredMed = MedicationModel(
        id: '1',
        profileId: 'p1',
        name: 'Test Med',
        times: ['08:00'],
        treatmentStartDate: now,
        expiryDate: now.subtract(const Duration(days: 2)),
      );
      expect(expiredMed.expiryStatus, 'expired');

      final soonMed = MedicationModel(
        id: '2',
        profileId: 'p1',
        name: 'Test Med',
        times: ['08:00'],
        treatmentStartDate: now,
        expiryDate: now.add(const Duration(days: 15)),
      );
      expect(soonMed.expiryStatus, 'expiringSoon');

      final validMed = MedicationModel(
        id: '3',
        profileId: 'p1',
        name: 'Test Med',
        times: ['08:00'],
        treatmentStartDate: now,
        expiryDate: now.add(const Duration(days: 180)),
      );
      expect(validMed.expiryStatus, 'valid');
    });

    test('AppL10n formats frequency, form, and dose unit in EN mode', () {
      final enL10n = AppL10n(const Locale('en'));
      expect(enL10n.formatFrequency('Günde 1 kez'), 'Once daily');
      expect(enL10n.formatFrequency('Günde 2 kez'), 'Twice daily');
      expect(enL10n.formatFrequency('Günde 3 kez'), '3 times daily');
      expect(enL10n.formatDoseUnit('Adet'), 'Unit');
      expect(enL10n.formatDoseUnit('Ölçek'), 'Spoon');
      expect(enL10n.formatForm('Kapsül'), 'Capsule');
      expect(enL10n.formatForm('Şurup'), 'Syrup');

      final trL10n = AppL10n(const Locale('tr'));
      expect(trL10n.formatFrequency('Günde 1 kez'), 'Günde 1 kez');
      expect(trL10n.formatDoseUnit('Adet'), 'Adet');
      expect(trL10n.formatForm('Kapsül'), 'Kapsül');
    });
  });

  testWidgets('IlacTakipApp smoke test renders navigation screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: IlacTakipApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(IlacTakipApp), findsOneWidget);
  });
}
