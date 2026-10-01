import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// Écran principal d'accueil de MaliExplorer.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MaliExplorer'),
        backgroundColor: AppColors.primaryForest,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bannière d'accueil culturelle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryForest, AppColors.secondaryEmerald],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Découvrez le Mali Authentique',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Patrimoine, traditions ancestrales, gastronomie et rencontres locales.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Section Gastronomie & Plats traditionnels
            const Text(
              'Gastronomie Malienne',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryForest,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.sahelGold,
                  child: Icon(Icons.restaurant, color: Colors.white),
                ),
                title: const Text(
                  'Tiga Diga Na (Sauce d\'Arachide / Mafé)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Plat emblématique du terroir malien'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/dish-detail'),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Section Peuples & Traditions
            const Text(
              'Peuples & Traditions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryForest,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.secondaryEmerald,
                  child: Icon(Icons.people, color: Colors.white),
                ),
                title: const Text(
                  'Le Peuple Dogon & Falaise de Bandiagara',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Cosmogonie, architecture en banco et danses de masques'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/ethnicity-detail'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
