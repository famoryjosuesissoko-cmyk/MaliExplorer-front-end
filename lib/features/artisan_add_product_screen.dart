import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/storage_service.dart';
import '../router/app_router.dart';

class ArtisanAddProductScreen extends StatefulWidget {
  const ArtisanAddProductScreen({super.key});

  @override
  State<ArtisanAddProductScreen> createState() =>
      _ArtisanAddProductScreenState();
}

class _ArtisanAddProductScreenState extends State<ArtisanAddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final List<({Uint8List bytes, String name})> _selectedImages = [];
  bool _isPublishing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limite de 4 images atteinte.'),
          backgroundColor: Color(0xFFE65151),
        ),
      );
      return;
    }

    try {
      final List<XFile> pickedList = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );
      if (pickedList.isNotEmpty) {
        for (final img in pickedList) {
          if (_selectedImages.length >= 4) break;
          final bytes = await img.readAsBytes();
          if (bytes.lengthInBytes <= StorageService.maxFileSizeBytes) {
            _selectedImages.add((bytes: bytes, name: img.name));
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'L\'image ${img.name} dépasse 10 Mo et a été ignorée.',
                  ),
                  backgroundColor: const Color(0xFFE65151),
                ),
              );
            }
          }
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint('[ArtisanAddProduct] Erreur sélection images: $e');
    }
  }

  Future<void> _onPublish() async {
    if (_nameController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir les champs obligatoires (*)'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    final List<String> uploadedUrls = [];
    try {
      for (final img in _selectedImages) {
        final url = await StorageService.uploadFile(
          folder: 'artisans',
          fileName: img.name,
          bytes: img.bytes,
        );
        uploadedUrls.add(url);
      }
    } catch (e) {
      debugPrint('[ArtisanAddProduct] Erreur téléversement images: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(
          children: const [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF075E4D),
              size: 52,
            ),
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
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
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
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
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
                                  onPressed: _isPublishing ? null : _onPublish,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF075E4D),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isPublishing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
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
        ],
      ),
    );
  }

  Widget _buildImageUploadBox() {
    if (_selectedImages.isEmpty) {
      return InkWell(
        onTap: _pickImages,
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
                  Icons.add_photo_alternate_outlined,
                  color: Color(0xFFE65151),
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Importer plusieurs images (max. 4)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16332D),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Formats supportés : JPG, PNG (max. 10 Mo par photo)',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount:
                _selectedImages.length + (_selectedImages.length < 4 ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (ctx, idx) {
              if (idx < _selectedImages.length) {
                final img = _selectedImages[idx];
                return Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF0E8F76),
                          width: 1.5,
                        ),
                        image: DecorationImage(
                          image: MemoryImage(img.bytes),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.removeAt(idx);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return InkWell(
                  onTap: _pickImages,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF0E8F76).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Color(0xFF0E8F76), size: 28),
                        Text(
                          'Ajouter',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF0E8F76),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_selectedImages.length}/4 photo(s) sélectionnée(s)',
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF0E8F76),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
}
