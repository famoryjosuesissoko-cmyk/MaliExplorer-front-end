import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loader.dart';
import '../../models/artisan_model.dart';
import '../../models/guide_model.dart';
import '../../widgets/common/empty_view.dart';

class PartenairesScreen extends StatefulWidget {
  const PartenairesScreen({super.key});

  @override
  State<PartenairesScreen> createState() => _PartenairesScreenState();
}

class _PartenairesScreenState extends State<PartenairesScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _apiService = ApiService();

  late Future<List<ArtisanModel>> _artisansFuture;
  late Future<List<GuideModel>> _guidesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    _artisansFuture = _fetchArtisans();
    _guidesFuture = _fetchGuides();
  }

  Future<List<ArtisanModel>> _fetchArtisans() async {
    try {
      final response = await _apiService.get(ApiConstants.artisans);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        return list.map((e) => ArtisanModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<GuideModel>> _fetchGuides() async {
    try {
      final response = await _apiService.get(ApiConstants.guides);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        return list.map((e) => GuideModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artisans & Guides'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.sahelGold,
          tabs: const [
            Tab(text: 'Artisans Locaux', icon: Icon(Icons.handyman_outlined)),
            Tab(text: 'Guides Touristiques', icon: Icon(Icons.badge_outlined)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/partenaires/nouveau'),
        backgroundColor: AppColors.sahelGold,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Devenir Partenaire', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<List<ArtisanModel>>(
            future: _artisansFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppLoader(message: 'Chargement des artisans...');
              }
              if (snapshot.hasError) {
                return AppError(message: 'Erreur lors du chargement des artisans.', onRetry: () => setState(() => _loadData()));
              }
              final artisans = snapshot.data ?? [];
              if (artisans.isEmpty) {
                return const EmptyView(title: 'Aucun artisan inscrit pour le moment', icon: Icons.handyman_outlined);
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.md),
                itemCount: artisans.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.sm),
                itemBuilder: (context, index) {
                  final a = artisans[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryForest.withValues(alpha: 0.12),
                        child: const Icon(Icons.palette, color: AppColors.primaryForest),
                      ),
                      title: Text(a.nomComplet, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(a.typeArtisanat ?? a.adresse ?? 'Artisanat malien'),
                      trailing: a.email != null ? const Icon(Icons.email_outlined, color: AppColors.primaryForest) : null,
                    ),
                  );
                },
              );
            },
          ),

          FutureBuilder<List<GuideModel>>(
            future: _guidesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppLoader(message: 'Chargement des guides certifiés...');
              }
              if (snapshot.hasError) {
                return AppError(message: 'Erreur lors du chargement des guides.', onRetry: () => setState(() => _loadData()));
              }
              final guides = snapshot.data ?? [];
              if (guides.isEmpty) {
                return const EmptyView(title: 'Aucun guide enregistré pour le moment', icon: Icons.badge_outlined);
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.md),
                itemCount: guides.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.sm),
                itemBuilder: (context, index) {
                  final g = guides[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondaryEmerald.withValues(alpha: 0.12),
                        child: const Icon(Icons.person, color: AppColors.secondaryEmerald),
                      ),
                      title: Text(g.nomComplet, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(g.langueParlee != null ? 'Langues : ${g.langueParlee}' : (g.adresse ?? 'Guide certifié')),
                      trailing: g.email != null ? const Icon(Icons.contact_phone_outlined, color: AppColors.secondaryEmerald) : null,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
