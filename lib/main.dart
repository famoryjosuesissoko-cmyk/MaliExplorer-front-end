import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  // S'assure que le binding Flutter est prêt avant d'exécuter du code asynchrone
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialisation des services Firebase & Supabase/Storage
  await FirebaseService.init();
  await StorageService.init();

  // Élimine définitivement l'écran rouge d'erreur Flutter en cas de rupture réseau temporaire
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: const Color(0xFFF7F8F5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color: Color(0xFF075E4D),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contenu en cours d\'actualisation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16332D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connexion temporairement indisponible. Les données locales sauvegardées restent accessibles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF6C7C77),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  };

  // Lancement de l'application avec Riverpod (ProviderScope)
  runApp(
    const ProviderScope(
      child: MaliExplorerApp(),
    ),
  );
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class MaliExplorerApp extends ConsumerWidget {
  const MaliExplorerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}