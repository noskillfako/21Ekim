import 'package:flutter_test/flutter_test.dart';
import 'package:ilactakip/core/services/drug_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DrugService queries local Turkish JSON database and has integrated API architecture', () async {
    final service = DrugService();
    await service.init();

    // 1. Test local search (8500+ records)
    final localResults = service.searchLocal('aspirin');
    expect(localResults.isNotEmpty, true);
    expect(localResults.first.source, 'Yerel');
    expect(localResults.any((d) => d.name.toUpperCase().contains('ASPIRIN')), true);

    final parolResults = service.searchLocal('parol');
    expect(parolResults.isNotEmpty, true);
    expect(parolResults.any((d) => d.name.toUpperCase().contains('PAROL')), true);

    // 2. Test searchDrugs in default JSON-only mode (enableExternalApi == false)
    expect(DrugService.enableExternalApi, false);
    final jsonOnlyResults = await service.searchDrugs('aspirin');
    expect(jsonOnlyResults.isNotEmpty, true);
    expect(jsonOnlyResults.every((d) => d.isLocal), true);

    // 3. Test API integration when enableExternalApi is toggled
    DrugService.enableExternalApi = true;
    final hybridResults = await service.searchDrugs('aspirin');
    expect(hybridResults.isNotEmpty, true);
    expect(hybridResults.any((d) => d.isLocal), true);

    // Verify error isolation with API enabled
    final emptyResults = await service.searchDrugs('zzzznonexistentdrug12345');
    expect(emptyResults.isEmpty, true);

    // Reset back to default JSON-only mode
    DrugService.enableExternalApi = false;
  });
}
