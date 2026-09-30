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

    // L'application se monte et affiche le titre / écran de démarrage
    expect(find.byType(MaliExplorerApp), findsOneWidget);

    // Écoulement du timer du SplashScreen
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
