import 'package:billey/providers/amount_visibility_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('visibility survives reopening and can be restored', () async {
    SharedPreferences.setMockInitialValues({});
    final first = AmountVisibilityProvider();
    await first.initialize();
    expect(first.hidden, false);
    await first.toggle();
    expect(first.hidden, true);
    final reopened = AmountVisibilityProvider();
    await reopened.initialize();
    expect(reopened.hidden, true);
    await reopened.toggle();
    final restored = AmountVisibilityProvider();
    await restored.initialize();
    expect(restored.hidden, false);
    first.dispose();
    reopened.dispose();
    restored.dispose();
  });
}
