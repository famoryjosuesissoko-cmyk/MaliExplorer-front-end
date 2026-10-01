import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mali_explorer_frontend/main.dart';

void main() {
  testWidgets('MaliExplorerApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaliExplorerApp(),
      ),
    );

    // Vérifie que l'application démarre bien avec le widget racine
    expect(find.byType(MaliExplorerApp), findsOneWidget);
  });
}
