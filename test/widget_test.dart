import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/main.dart';

void main() {
  testWidgets('Without configuration, the gate shows the error screen',
      (tester) async {
    // In tests AppConfig is not configured: the bootstrap fails in a
    // controlled way and the gate shows "Errore di avvio" instead of crashing.
    await tester.pumpWidget(const ForkastApp());
    await tester.pump();

    expect(find.text('Errore di avvio'), findsOneWidget);
  });
}
