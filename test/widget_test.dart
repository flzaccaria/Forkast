import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/locale_provider.dart';
import 'package:forkast/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Without configuration, the gate shows the error screen',
      (tester) async {
    SharedPreferences.setMockInitialValues({'app_locale': 'it'});
    final prefs = await SharedPreferences.getInstance();
    final localeNotifier = LocaleNotifier(prefs);

    await tester.pumpWidget(ForkastApp(localeNotifier: localeNotifier));
    await tester.pump();
    await tester.pump();

    expect(find.text('Errore di avvio'), findsOneWidget);
  });
}
