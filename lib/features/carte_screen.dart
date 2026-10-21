import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../core/constants/api_constants.dart';
import '../core/constants/app_colors.dart';
import '../models/region_model.dart';
import '../providers/regions_provider.dart';
import '../router/app_router.dart';

/// Écran Carte Interactive du Mali avec FlutterMap & OpenStreetMap
/// Permet l'exploration géographique, la sélection par région ou marqueur,
/// et met en valeur l'ensemble des régions du Mali de manière dynamique.
class CarteScreen extends ConsumerStatefulWidget {
  const CarteScreen({super.key});

  @override
  ConsumerState<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends ConsumerState<CarteScreen> {
  final MapController _mapController = MapController();
  late RegionModel _selectedRegion;
  String _selectedFilter = 'Tous'; // 'Tous', 'UNESCO', 'Sud', 'Nord', 'Centre'

  @override
  void initState() {
    super.initState();
    _selectedRegion = RegionData.regions.firstWhere(
      (r) => r.id == 'mopti',
      orElse: () => RegionData.regions.first,
    );
  }

  void _centerOnRegion(RegionModel region) {
    setState(() => _selectedRegion = region);
    _mapController.move(
      LatLng(region.latitude, region.longitude),
      6.2,
    );
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 0.8);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (currentZoom - 0.8).clamp(3.0, 18.0));
  }

  void _resetMaliView() {
    _mapController.move(const LatLng(17.5707, -3.9962), 5.2);
  }

  List<RegionModel> _getFilteredRegions(List<RegionModel> source) {
    if (_selectedFilter == 'UNESCO') {
      return source
          .where((r) =>
              r.id == 'mopti' ||
              r.id == 'tombouctou' ||
              r.id == 'gao' ||
              r.id == 'bandiagara' ||
              r.id == 'san')
          .toList();
    }
    if (_selectedFilter == 'Nord') {
      return source
          .where((r) =>
              r.id == 'tombouctou' ||
              r.id == 'gao' ||
              r.id == 'kidal' ||
              r.id == 'taoudenit' ||
              r.id == 'menaka')
          .toList();
    }
    if (_selectedFilter == 'Sud') {
      return source
          .where((r) =>
              r.id == 'bamako' ||
              r.id == 'sikasso' ||
              r.id == 'segou' ||
              r.id == 'kayes' ||
              r.id == 'koulikoro' ||
              r.id == 'koutiala' ||
              r.id == 'san' ||
              r.id == 'kita' ||
              r.id == 'kenieba')
          .toList();
    }
    if (_selectedFilter == 'Centre') {
      return source
          .where((r) =>
              r.id == 'mopti' ||
              r.id == 'segou' ||
              r.id == 'san' ||
              r.id == 'bandiagara')
          .toList();
    }
    return source;
  }

  Widget _buildRegionImage(
    String imagePath, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
  }) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        ApiConstants.resolveImageUrl(imagePath),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: width,
          color: const Color(0xFF075E4D),
          child: const Center(
            child: Icon(Icons.location_city_rounded,
                color: Colors.white54, size: 28),
          ),
        ),
      );
    }
    return Image.asset(
      imagePath,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: width,
        color: const Color(0xFF075E4D),
        child: const Center(
          child: Icon(Icons.location_city_rounded,
              color: Colors.white54, size: 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allRegions = ref.watch(regionsProvider).valueOrNull ?? RegionData.regions;
    for (final reg in allRegions) {
      if (reg.id == _selectedRegion.id) {
        _selectedRegion = reg;
        break;
      }
    }
    final displayedRegions = _getFilteredRegions(allRegions);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackgroundSecondary
          : const Color(0xFF075E4D),
      body: Column(
        children: [
          // En-tête vert MaliExplorer
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CARTE DU MALI',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.explore_rounded,
                              color: Color(0xFFD6A23A),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'OpenStreetMap',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Explorez les régions et touchez un marqueur pour démarrer une immersion.',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Conteneur principal
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : const Color(0xFFF7F8F5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filtres de sélection géographique
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          'Tous',
                          'UNESCO',
                          'Sud',
                          'Nord',
                          'Centre',
                        ].map((filtre) {
                          final isSelected = _selectedFilter == filtre;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(filtre),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _selectedFilter = filtre),
                              selectedColor: isDark
                                  ? AppColors.primaryInteractive
                                  : const Color(0xFF075E4D),
                              backgroundColor: isDark
                                  ? AppColors.darkSurface
                                  : Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : const Color(0xFF6C7C77)),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 12.5,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.primaryInteractive
                                        : const Color(0xFF075E4D))
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : const Color(0xFFE2E8F0)),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Carte Interactive OpenStreetMap avec FlutterMap
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.20 : 0.05,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: const MapOptions(
                                initialCenter: LatLng(14.4958, -4.1873), // Centré Mopti / Mali central
                                initialZoom: 5.6,
                                minZoom: 4.0,
                                maxZoom: 16.0,
                              ),
                              children: [
                                // Tuiles cartographiques OpenStreetMap France (100% libres, sans clé API ni filigrane)
                                TileLayer(
                                  urlTemplate:
                                      'https://a.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.maliexplorer.mali_explorer_frontend',
                                ),

                                // Marqueurs des régions du Mali
                                MarkerLayer(
                                  markers: displayedRegions.map((region) {
                                    final isSelected =
                                        _selectedRegion.id == region.id;
                                    return Marker(
                                      point: LatLng(
                                          region.latitude, region.longitude),
                                      width: isSelected ? 110 : 85,
                                      height: isSelected ? 50 : 40,
                                      child: GestureDetector(
                                        onTap: () => _centerOnRegion(region),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF075E4D)
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFD6A23A)
                                                  : const Color(0xFF075E4D),
                                              width: isSelected ? 2.2 : 1.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: isSelected ? 8 : 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.location_on_rounded,
                                                size: isSelected ? 16 : 13,
                                                color: isSelected
                                                    ? const Color(0xFFD6A23A)
                                                    : const Color(0xFF075E4D),
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  region.chefLieu,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize:
                                                        isSelected ? 11.5 : 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF16332D),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),

                            // Boutons de contrôle (Zoom +, Zoom -, Recadrer Mali)
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Column(
                                children: [
                                  _buildMapControlButton(
                                    icon: Icons.add,
                                    tooltip: 'Zoom avant',
                                    onTap: _zoomIn,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildMapControlButton(
                                    icon: Icons.remove,
                                    tooltip: 'Zoom arrière',
                                    onTap: _zoomOut,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildMapControlButton(
                                    icon: Icons.fullscreen_exit_rounded,
                                    tooltip: 'Vue d’ensemble Mali',
                                    onTap: _resetMaliView,
                                  ),
                                ],
                              ),
                            ),

                            // Attribution légale OpenStreetMap obligatoire
                            Positioned(
                              left: 8,
                              bottom: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '© OpenStreetMap contributors',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section 1 : Régions du Mali
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Régions du Mali',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            context.push(
                              AppRouter.regionDetail,
                              extra: _selectedRegion,
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Voir plus',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFFD6A23A)
                                        : const Color(0xFF075E4D),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 11,
                                  color: isDark
                                      ? const Color(0xFFD6A23A)
                                      : const Color(0xFF075E4D),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Carrousel horizontal des régions du Mali avec vraies photos de couverture
                    SizedBox(
                      height: 135,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayedRegions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final region = displayedRegions[index];
                          final isSelected = _selectedRegion.id == region.id;

                          return GestureDetector(
                            onTap: () => _centerOnRegion(region),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFD6A23A)
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isSelected ? 0.25 : 0.08,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _buildRegionImage(region.imageCover),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.8),
                                          ],
                                          stops: const [0.4, 1.0],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 10,
                                      bottom: 10,
                                      right: 10,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            region.chefLieu,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            region.population,
                                            style: const TextStyle(
                                              color: Color(0xFFD6A23A),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Carte détaillée de la région sélectionnée
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.05,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                _buildRegionImage(
                                  _selectedRegion.imageCover,
                                  height: 150,
                                  width: double.infinity,
                                ),
                                Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.75),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  bottom: 14,
                                  right: 16,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedRegion.nom,
                                              style: const TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Chef-lieu : ${_selectedRegion.chefLieu} • ${_selectedRegion.superficie}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFFD6A23A),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedRegion.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : const Color(0xFF4A5568),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Bouton Explorer la région
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark
                                          ? AppColors.primaryInteractive
                                          : const Color(0xFF075E4D),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () {
                                      context.push(
                                        AppRouter.regionDetail,
                                        extra: _selectedRegion,
                                      );
                                    },
                                    child: Text(
                                      'Explorer ${_selectedRegion.nom}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 20, color: const Color(0xFF075E4D)),
          ),
        ),
      ),
    );
  }
}
