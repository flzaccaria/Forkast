import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/main.dart';

void main() {
  testWidgets('Senza configurazione, il gate mostra la schermata di errore',
      (tester) async {
    // In test AppConfig non è configurato: il bootstrap fallisce in modo
    // controllato e il gate mostra "Errore di avvio" invece di crashare.
    await tester.pumpWidget(const ForkastApp());
    await tester.pump();

    expect(find.text('Errore di avvio'), findsOneWidget);
  });
}
