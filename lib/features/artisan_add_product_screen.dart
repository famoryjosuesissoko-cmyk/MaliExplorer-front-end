import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

class ArtisanAddProductScreen extends StatefulWidget {
  const ArtisanAddProductScreen({super.key});

  @override
  State<ArtisanAddProductScreen> createState() => _ArtisanAddProductScreenState();
}

class _ArtisanAddProductScreenState extends State<ArtisanAddProductScreen> {
  int _selectedNavIndex = 4;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  int _selectedImagesCount = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onPublish() {
    if (_nameController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir les champs obligatoires (*)'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(
          children: const [
            Icon(Icons.check_circle_rounded, color: Color(0xFF075E4D), size: 52),
            SizedBox(height: 10),
            Text(
              'Création publiée !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF075E4D),
              ),
            ),
          ],
        ),
        content: const Text(
          'Votre création a été ajoutée avec succès à votre catalogue d\'artisan.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: Color(0xFF6C7C77)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF075E4D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. En-tête vert
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRouter.home);
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Espace Artisan',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0),
                        child: Text(
                          'Publiez vos nouvelles créations d\'artisanat d\'art malien',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Fiche blanche avec formulaire
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8F5),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ajouter un produit à ma fiche',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16332D),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Zone d'importation d'images avec bordure en pointillé / style
                        _buildImageUploadBox(),

                        const SizedBox(height: 20),

                        // Champ : Nom de la création
                        _buildFormField(
                          label: 'Nom de la création *',
                          controller: _nameController,
                          hint: 'Ex: Canari d\'argile soudanais de luxe',
                        ),

                        const SizedBox(height: 16),

                        // Champ : Description courte
                        _buildFormField(
                          label: 'Description courte *',
                          controller: _descController,
                          hint:
                              'Ex: Pot d\'argile fait main, cuit selon les traditions millénaires de Djenné, orné de motifs spirituels...',
                          maxLines: 3,
                        ),

                        const SizedBox(height: 16),

                        // Champ : Prix
                        _buildFormField(
                          label: 'Prix (FCFA) *',
                          controller: _priceController,
                          hint: 'Ex: 25000',
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 28),

                        // Boutons Annuler et Publier l'article
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: () => context.pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF16332D),
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.black.withValues(alpha: 0.15),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Annuler',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _onPublish,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF075E4D),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Publier l\'article',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Barre de navigation inférieure
          Positioned(
            left: math.max(16.0, screenWidth * 0.04),
            right: math.max(16.0, screenWidth * 0.04),
            bottom: math.max(12.0, MediaQuery.of(context).padding.bottom + 6.0),
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadBox() {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedImagesCount = (_selectedImagesCount + 1) % 5;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF0E8F76).withValues(alpha: 0.5),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE65151).withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFFE65151),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedImagesCount > 0
                  ? '$_selectedImagesCount image(s) sélectionnée(s)'
                  : 'Importer plusieurs images (max. 4)',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16332D),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Formats supportés : JPG, PNG (min. 500px)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF16332D),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF16332D)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Accueil', isSelected: _selectedNavIndex == 0, onTap: () => context.go(AppRouter.home)),
          _buildNavItem(1, Icons.menu_book_rounded, 'Carte', isSelected: _selectedNavIndex == 1),
          _buildNavItem(2, Icons.explore_outlined, 'Découvrir', isSelected: _selectedNavIndex == 2, onTap: () => context.push(AppRouter.monParcours)),
          _buildNavItem(3, Icons.help_outline_rounded, 'Quiz', isSelected: _selectedNavIndex == 3, onTap: () => context.push(AppRouter.quizList)),
          _buildNavItem(4, Icons.person_rounded, 'Profil', isSelected: _selectedNavIndex == 4, onTap: () => context.push(AppRouter.profil)),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {required bool isSelected, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedNavIndex = index;
          });
          if (onTap != null) onTap();
        },
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF075E4D),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              )
            else
              Icon(icon, color: const Color(0xFF6C7C77), size: 22),
            const SizedBox(height: 2.5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF075E4D) : const Color(0xFF6C7C77),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
