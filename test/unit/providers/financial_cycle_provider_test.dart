import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billey/providers/financial_cycle_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('persists per account and clears the previous account immediately',
      () async {
    SharedPreferences.setMockInitialValues({});
    final provider = FinancialCycleProvider();
    await provider.bindUser('alice');
    expect(provider.configured, false);
    await provider.save(27);
    final restored = FinancialCycleProvider();
    await restored.bindUser('alice');
    expect(restored.cycle.startDay, 27);
    final loading = restored.bindUser('bob');
    expect(restored.configured, false);
    expect(restored.cycle.startDay, 1);
    await loading;
    await restored.save(15);
    await restored.bindUser('alice');
    expect(restored.cycle.startDay, 27);
    await restored.bindUser(null);
    await expectLater(restored.save(12), throwsStateError);
    await expectLater(provider.save(32), throwsArgumentError);
  });
}
