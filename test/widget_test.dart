// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:triathlon_app/triathlon_app.dart';
import 'package:triathlon_app/services/data_manager.dart';

void main() {
  testWidgets('Triathlon App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => DataManager(),
        child: const TriathlonApp(), // Utilisez TriathlonApp au lieu de MyApp
      ),
    );

    // Attendez que l'app se charge
    await tester.pumpAndSettle();

    // Vérifiez que l'application s'est chargée correctement
    // Exemple: vérifiez qu'un texte de l'application est présent
    expect(find.text('Triathlon'), findsOneWidget);

    // Ou vérifiez qu'un widget de base est présent
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
