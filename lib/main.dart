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

  // Lancement de l'application avec Riverpod (ProviderScope)
  runApp(
    const ProviderScope(
      child: MaliExplorerApp(),
    ),
  );
}

class MaliExplorerApp extends StatelessWidget {
  const MaliExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}