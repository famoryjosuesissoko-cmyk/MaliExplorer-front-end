import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await FirebaseService.init();

  // Initialisation de Supabase
  await StorageService.init();

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
      routerConfig: appRouter,
    );
  }
}
