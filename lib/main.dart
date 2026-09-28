import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'services/supabase_service.dart';

void main() async {
  // S'assure que le moteur Flutter est prêt avant d'invoquer le code natif
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp();

  // Initialisation de Supabase
  await SupabaseService.init();

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
      title: 'MaliExplorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
