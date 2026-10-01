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

    // Vérifie le montage de l'application
    expect(find.byType(MaliExplorerApp), findsOneWidget);

    // Écoulement du timer de SplashScreen pour éviter les timers pendants
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
