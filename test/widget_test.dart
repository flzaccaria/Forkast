import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/locale_provider.dart';
import 'package:forkast/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Without configuration, the gate shows the error screen',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final localeNotifier = LocaleNotifier(prefs);

    await tester.pumpWidget(ForkastApp(localeNotifier: localeNotifier));
    await tester.pump();

    // The bootstrap error screen title is localized — defaults to Italian.
    expect(find.text('Errore di avvio'), findsOneWidget);
  });
}
