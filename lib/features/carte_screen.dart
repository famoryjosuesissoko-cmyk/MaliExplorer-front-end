import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../models/ville_model.dart';
import '../providers/villes_provider.dart';
import '../router/app_router.dart';

class CarteScreen extends ConsumerStatefulWidget {
  const CarteScreen({super.key});

  @override
  ConsumerState<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends ConsumerState<CarteScreen> {
  int _selectedCityIndex = 0;
  String _selectedFilter = 'Tous';

  final List<Map<String, dynamic>> _markerCities = [
    {
      'nom': 'Tombouctou',
      'region': 'Tombouctou',
      'coords': '16.7666° N, 3.0026° O',
      'highlight': 'Cité des 333 saints • UNESCO',
      'image':
          'https://images.unsplash.com/photo-1578922746465-3a80a228f223?q=80&w=600&auto=format&fit=crop',
      'x': 0.62,
      'y': 0.28,
    },
    {
      'nom': 'Djenné',
      'region': 'Mopti',
      'coords': '13.9061° N, 4.5533° O',
      'highlight': 'Grande Mosquée en terre crue • UNESCO',
      'image':
          'https://images.unsplash.com/photo-1516426122078-c23e76319801?q=80&w=600&auto=format&fit=crop',
      'x': 0.44,
      'y': 0.52,
    },
    {
      'nom': 'Mopti',
      'region': 'Mopti',
      'coords': '14.4958° N, 4.1873° O',
      'highlight': 'La Venise malienne • Port des pinasses',
      'image':
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
      'x': 0.52,
      'y': 0.46,
    },
    {
      'nom': 'Ségou',
      'region': 'Ségou',
      'coords': '13.4317° N, 6.2157° O',
      'highlight': 'Cité des Balanzans • Royaume Bambara',
      'image':
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      'x': 0.36,
      'y': 0.60,
    },
    {
      'nom': 'Bamako',
      'region': 'Bamako',
      'coords': '12.6392° N, 8.0029° O',
      'highlight': 'Capitale vibrante sur les rives du Niger',
      'image':
          'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=600&auto=format&fit=crop',
      'x': 0.26,
      'y': 0.68,
    },
    {
      'nom': 'Sikasso',
      'region': 'Sikasso',
      'coords': '11.3176° N, 5.6665° O',
      'highlight': 'Royaume du Kénédougou • Tata historique',
      'image':
          'https://images.unsplash.com/photo-1523821741446-edb2b68bb7a0?q=80&w=600&auto=format&fit=crop',
      'x': 0.42,
      'y': 0.82,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedMarker = _markerCities[_selectedCityIndex];
    final villesAsync = ref.watch(villesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackgroundSecondary
          : const Color(0xFF075E4D),
      body: Column(
        children: [
          // En-tête vert
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
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
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.explore_rounded,
                              color: Color(0xFFF2B544),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Interactive',
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
                      'Touchez une région ou un repère pour explorer son patrimoine.',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fiche blanche contenant la carte et la fiche ville
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filtres de catégories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children:
                            [
                              'Tous',
                              'UNESCO',
                              'Villes du Nord',
                              'Sud & Centre',
                            ].map((filtre) {
                              final bool isSelected = _selectedFilter == filtre;
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

                    const SizedBox(height: 14),

                    // Canvas interactif de la Carte du Mali
                    Container(
                      height: 260,
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
                              alpha: isDark ? 0.20 : 0.04,
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
                            // Tracé stylisé du fleuve Niger (Djoliba)
                            CustomPaint(
                              size: const Size(double.infinity, 260),
                              painter: _MaliMapPainter(),
                            ),

                            // Pointers des villes sur la carte
                            ...List.generate(_markerCities.length, (index) {
                              final city = _markerCities[index];
                              final isSelected = _selectedCityIndex == index;
                              return Align(
                                alignment: FractionalOffset(
                                  city['x'] as double,
                                  city['y'] as double,
                                ),
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedCityIndex = index,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF075E4D)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFF2B544)
                                            : const Color(0xFF075E4D),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? const Color(
                                                  0xFF075E4D,
                                                ).withValues(alpha: 0.3)
                                              : Colors.black12,
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          size: 14,
                                          color: isSelected
                                              ? const Color(0xFFF2B544)
                                              : const Color(0xFF075E4D),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          city['nom'] as String,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF16332D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Carte détaillée de la ville sélectionnée
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
                                Image.network(
                                  selectedMarker['image'] as String,
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, _, _) => Container(
                                    height: 140,
                                    color: const Color(0xFF075E4D),
                                    child: const Center(
                                      child: Icon(
                                        Icons.location_city,
                                        color: Colors.white70,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 140,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.65),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  bottom: 12,
                                  right: 16,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedMarker['nom'] as String,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'Région de ${selectedMarker['region']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFF2B544),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
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
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFF2B544),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        selectedMarker['highlight'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : const Color(0xFF16332D),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.my_location_rounded,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : const Color(0xFF6C7C77),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      selectedMarker['coords'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : const Color(0xFF6C7C77),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
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
                                      villesAsync.whenData((villes) {
                                        final matched = villes.firstWhere(
                                          (v) => v.nom.toLowerCase().contains(
                                            (selectedMarker['nom'] as String)
                                                .toLowerCase(),
                                          ),
                                          orElse: () => VilleModel(
                                            id: 1,
                                            nom:
                                                selectedMarker['nom'] as String,
                                            region:
                                                selectedMarker['region']
                                                    as String,
                                            description:
                                                selectedMarker['highlight']
                                                    as String,
                                            imageUrl:
                                                selectedMarker['image']
                                                    as String,
                                          ),
                                        );
                                        context.push(
                                          AppRouter.cityDetail,
                                          extra: matched,
                                        );
                                      });
                                    },
                                    child: Text(
                                      'Découvrir ${selectedMarker['nom']}',
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
}

class _MaliMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fond carte stylisé du Mali avec le fleuve Niger (boucle du Niger)
    final riverPaint = Paint()
      ..color = const Color(0xFF0E8F76).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Boucle du fleuve Niger : Sud-Ouest vers Nord-Est puis Sud-Est
    path.moveTo(size.width * 0.15, size.height * 0.85); // Guinée frontière
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height * 0.65, // Bamako
      size.width * 0.38,
      size.height * 0.58, // Ségou
    );
    path.quadraticBezierTo(
      size.width * 0.48,
      size.height * 0.44, // Mopti
      size.width * 0.62,
      size.height * 0.25, // Tombouctou
    );
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.32, // Boucle
      size.width * 0.88,
      size.height * 0.55, // Gao
    );

    canvas.drawPath(path, riverPaint);

    // Tracé secondaire Bani
    final baniPaint = Paint()
      ..color = const Color(0xFF0E8F76).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final baniPath = Path();
    baniPath.moveTo(size.width * 0.42, size.height * 0.85); // Sikasso/San
    baniPath.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.60,
      size.width * 0.48,
      size.height * 0.46, // Mopti
    );
    canvas.drawPath(baniPath, baniPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
