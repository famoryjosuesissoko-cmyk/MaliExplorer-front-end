import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_colors.dart';
import 'router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Barre de statut transparente avec icônes sombres pour un rendu épuré
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MaliExplorerApp());
}

class MaliExplorerApp extends StatelessWidget {
  const MaliExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MaliExplorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.mistIvory,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryForest,
          primary: AppColors.primaryForest,
          secondary: AppColors.secondaryEmerald,
          surface: AppColors.pureWhite,


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
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text(AppStrings.appName),
        ),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
