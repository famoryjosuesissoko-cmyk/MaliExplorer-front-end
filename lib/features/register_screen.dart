import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';
import '../core/services/api_service.dart';
import '../router/app_router.dart';
import 'auth/auth_controller.dart';

enum UserRole { touriste, promoteur, guide, artisan }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  UserRole _selectedRole = UserRole.touriste;
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _isUploadingFiles = false;

  // Fichiers sélectionnés
  Uint8List? _avatarBytes;
  String? _avatarName;

  Uint8List? _idDocBytes;
  String? _idDocName;

  Uint8List? _orgDocBytes;
  String? _orgDocName;

  // Contrôleurs communs
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();

  // Contrôleurs Promoteur / Artisan / Guide
  final _nomOrganisationController = TextEditingController();
  final _nifRccmController = TextEditingController();
  final _specialiteController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();

    _nomOrganisationController.dispose();
    _nifRccmController.dispose();
    _specialiteController.dispose();
    super.dispose();
  }

  /// Sélection de l'avatar (Caméra ou Galerie)
  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choisir une photo de profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryForest,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryForest),
                title: const Text('Galerie de photos'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (picked != null) {
                    final bytes = await picked.readAsBytes();
                    if (bytes.lengthInBytes > StorageService.maxFileSizeBytes) {
                      _showFileTooLargeError();
                      return;
                    }
                    setState(() {
                      _avatarBytes = bytes;
                      _avatarName = picked.name;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryForest),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picked = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);
                  if (picked != null) {
                    final bytes = await picked.readAsBytes();
                    if (bytes.lengthInBytes > StorageService.maxFileSizeBytes) {
                      _showFileTooLargeError();
                      return;
                    }
                    setState(() {
                      _avatarBytes = bytes;
                      _avatarName = picked.name;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sélection de pièce d'identité (PDF ou Image)
  Future<void> _pickIdDoc() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = await file.xFile.readAsBytes();
        if (bytes.lengthInBytes > StorageService.maxFileSizeBytes) {
          _showFileTooLargeError();
          return;
        }
        setState(() {
          _idDocBytes = bytes;
          _idDocName = file.name;
        });
      }
    } catch (e) {
      debugPrint('[RegisterScreen] Erreur sélection pièce d\'identité: $e');
    }
  }

  /// Sélection de pièce justificative (NIF, RCCM, etc.)
  Future<void> _pickOrgDoc() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = await file.xFile.readAsBytes();
        if (bytes.lengthInBytes > StorageService.maxFileSizeBytes) {
          _showFileTooLargeError();
          return;
        }
        setState(() {
          _orgDocBytes = bytes;
          _orgDocName = file.name;
        });
      }
    } catch (e) {
      debugPrint('[RegisterScreen] Erreur sélection document organisation: $e');
    }
  }

  void _showFileTooLargeError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Le fichier sélectionné dépasse la limite autorisée de 10 Mo.'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isUploadingFiles = true;
    });

    String? photoUrl;
    String? pieceIdentiteUrl;

    try {
      final apiService = ApiService();

      // 1. Upload de la photo de profil vers Supabase Storage si sélectionnée
      if (_avatarBytes != null && _avatarName != null) {
        photoUrl = await StorageService.uploadFile(
          folder: 'avatars',
          fileName: _avatarName!,
          bytes: _avatarBytes!,
          apiService: apiService,
        );
      }

      // 2. Upload de la pièce d'identité vers Supabase Storage si sélectionnée
      if (_idDocBytes != null && _idDocName != null) {
        pieceIdentiteUrl = await StorageService.uploadFile(
          folder: 'documents',
          fileName: _idDocName!,
          bytes: _idDocBytes!,
          apiService: apiService,
        );
      }
    } catch (uploadError) {
      debugPrint('[RegisterScreen] Avertissement upload média: $uploadError');
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingFiles = false;
        });
      }
    }

    final success = await ref.read(authControllerProvider.notifier).register(
      prenom: _prenomController.text,
      nom: _nomController.text,
      email: _emailController.text,
      password: _passwordController.text.isNotEmpty ? _passwordController.text : 'MaliExp2026!',
      role: _selectedRole.name,
      adresse: _adresseController.text,
      telephone: _telephoneController.text,
      photoUrl: photoUrl,
      nomOrganisation: _nomOrganisationController.text.isNotEmpty
          ? _nomOrganisationController.text
          : _specialiteController.text,
      pieceIdentite: pieceIdentiteUrl,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès ! Bienvenue sur MaliExplorer.'),
          backgroundColor: AppColors.primaryForest,
        ),
      );
      context.go(AppRouter.home);
    } else {
      final error = ref.read(authControllerProvider).errorMessage ?? 'Erreur lors de l\'inscription';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading || _isUploadingFiles;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryForest, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.home);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/MaliExplorer.png',
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),

                // Titre
                const Text(
                  'Créer un compte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryForest,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Sous-titre dynamique selon le rôle
                Text(
                  _getRoleSubtitle(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),

                // Sélecteur de rôle (en haut pour les profils professionnels)
                if (_selectedRole != UserRole.touriste) ...[
                  const Text(
                    'Votre rôle',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  _buildRoleSelector(),
                  const SizedBox(height: 16),
                ],

                // Formulaires conditionnels selon le rôle
                if (_selectedRole == UserRole.touriste)
                  _buildTouristeForm()
                else if (_selectedRole == UserRole.guide)
                  _buildGuideForm()
                else if (_selectedRole == UserRole.artisan)
                  _buildArtisanForm()
                else
                  _buildPromoteurForm(),

                // Sélecteur de rôle (en bas pour Touriste comme sur Figma)
                if (_selectedRole == UserRole.touriste) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Votre rôle',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  _buildRoleSelector(),
                ],

                // Checkbox Conditions d'utilisation obligatoire pour tous les rôles
                _buildTermsCheckbox(),

                const SizedBox(height: 24),

                // Bouton S'inscrire
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryForest,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryForest.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _isUploadingFiles ? 'Envoi des fichiers...' : 'Création du compte...',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          )
                        : const Text(
                            'S\'inscrire',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Footer vers Connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Déjà un compte ? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRouter.login),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: AppColors.primaryForest,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleSubtitle() {
    switch (_selectedRole) {
      case UserRole.touriste:
        return 'Rejoignez MaliExplorer et commencez votre aventure dès maintenant.';
      case UserRole.guide:
        return 'Rejoignez MaliExplorer comme guide touristique certifié.';
      case UserRole.artisan:
        return 'Faites découvrir vos créations artisanales du Mali au monde.';
      case UserRole.promoteur:
        return 'Rejoignez MaliExplorer comme promoteur culturel ou événementiel.';
    }
  }

  Widget _buildTermsCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: _acceptTerms,
            activeColor: AppColors.primaryForest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) => setState(() => _acceptTerms = val ?? false),
          ),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  "J'accepte les ",
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRouter.terms),
                  child: const Text(
                    "conditions d'utilisation",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryForest,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sélecteur à boutons de rôles
  Widget _buildRoleSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildRoleButton(
            role: UserRole.touriste,
            label: 'Touriste',
            icon: Icons.person_outline,
          ),
          const SizedBox(width: 8),
          _buildRoleButton(
            role: UserRole.guide,
            label: 'Guide',
            icon: Icons.lightbulb_outline,
          ),
          const SizedBox(width: 8),
          _buildRoleButton(
            role: UserRole.artisan,
            label: 'Artisan',
            icon: Icons.palette_outlined,
          ),
          const SizedBox(width: 8),
          _buildRoleButton(
            role: UserRole.promoteur,
            label: 'Promoteur',
            icon: Icons.handshake_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required UserRole role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryForest : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: AppColors.borderLight),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryForest.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 1. FORMULAIRE TOURISTE ====================
  Widget _buildTouristeForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPillField(
                controller: _nomController,
                hint: 'Nom',
                icon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Nom requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPillField(
                controller: _prenomController,
                hint: 'Prénom',
                icon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Prénom requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPillField(
                controller: _adresseController,
                hint: 'Adresse',
                icon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _pickAvatar,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _avatarBytes != null ? const Color(0xFFE8F4F0) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _avatarBytes != null ? AppColors.primaryForest : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _avatarBytes != null ? Icons.check_circle_outline : Icons.image_outlined,
                        color: _avatarBytes != null ? AppColors.primaryForest : AppColors.textPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _avatarBytes != null ? 'Photo ajoutée' : 'Photo profil',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _avatarBytes != null ? AppColors.primaryForest : AppColors.textMuted,
                            fontSize: 12.5,
                            fontWeight: _avatarBytes != null ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _emailController,
          hint: 'Email',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          validator: (val) => (val == null || !val.contains('@')) ? 'Email invalide' : null,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _passwordController,
          hint: 'Mot de passe',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (val) => (val == null || val.length < 6) ? 'Min 6 caractères' : null,
        ),
      ],
    );
  }

  // ==================== 2. FORMULAIRE GUIDE ====================
  Widget _buildGuideForm() {
    return _buildCardSection(
      icon: Icons.person_outline,
      title: 'Informations professionnelles',
      subtitle: 'Renseignez vos informations de guide et vos pièces',
      children: [
        _buildPillField(
          controller: _prenomController,
          hint: 'Prénom',
          icon: Icons.person_outline,
          validator: (val) => val == null || val.isEmpty ? 'Prénom requis' : null,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _nomController,
          hint: 'Nom',
          icon: Icons.person_outline,
          validator: (val) => val == null || val.isEmpty ? 'Nom requis' : null,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _emailController,
          hint: 'Email',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          validator: (val) => (val == null || !val.contains('@')) ? 'Email invalide' : null,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _passwordController,
          hint: 'Mot de passe',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (val) => (val == null || val.length < 6) ? 'Min 6 caractères' : null,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _telephoneController,
          hint: 'Téléphone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _adresseController,
          hint: 'Région / Ville d\'exercice',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 14),
        _buildInteractiveFilePickerTile(
          title: 'Photo de profil',
          subtitle: 'JPG, PNG (max 10 MO)',
          selectedBytes: _avatarBytes,
          selectedName: _avatarName,
          onTap: _pickAvatar,
          onRemove: () => setState(() {
            _avatarBytes = null;
            _avatarName = null;
          }),
          placeholderIcon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _buildInteractiveFilePickerTile(
          title: 'Carte d’identité / Badge Guide',
          subtitle: 'JPG, PNG, PDF (max 10 MO)',
          selectedBytes: _idDocBytes,
          selectedName: _idDocName,
          onTap: _pickIdDoc,
          onRemove: () => setState(() {
            _idDocBytes = null;
            _idDocName = null;
          }),
          placeholderIcon: Icons.badge_outlined,
        ),
      ],
    );
  }

  // ==================== 3. FORMULAIRE ARTISAN ====================
  Widget _buildArtisanForm() {
    return _buildCardSection(
      icon: Icons.palette_outlined,
      title: 'Atelier & Créations',
      subtitle: 'Présentez votre métier artisanal et votre atelier',
      children: [
        _buildPillField(
          controller: _prenomController,
          hint: 'Prénom',
          icon: Icons.person_outline,
          validator: (val) => val == null || val.isEmpty ? 'Prénom requis' : null,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _nomController,
          hint: 'Nom',
          icon: Icons.person_outline,
          validator: (val) => val == null || val.isEmpty ? 'Nom requis' : null,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _emailController,
          hint: 'Email',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          validator: (val) => (val == null || !val.contains('@')) ? 'Email invalide' : null,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _passwordController,
          hint: 'Mot de passe',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (val) => (val == null || val.length < 6) ? 'Min 6 caractères' : null,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _telephoneController,
          hint: 'Téléphone / WhatsApp',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _specialiteController,
          hint: 'Spécialité (ex: Bijouterie Touareg, Poterie, Bogolan)',
          icon: Icons.handyman_outlined,
        ),
        const SizedBox(height: 12),
        _buildPillField(
          controller: _adresseController,
          hint: 'Adresse de l\'atelier (ex: Marché artisanal de Bamako)',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 14),
        _buildInteractiveFilePickerTile(
          title: 'Photo de profil ou atelier',
          subtitle: 'JPG, PNG (max 10 MO)',
          selectedBytes: _avatarBytes,
          selectedName: _avatarName,
          onTap: _pickAvatar,
          onRemove: () => setState(() {
            _avatarBytes = null;
            _avatarName = null;
          }),
          placeholderIcon: Icons.camera_alt_outlined,
        ),
        const SizedBox(height: 12),
        _buildInteractiveFilePickerTile(
          title: 'Pièce d’identité ou Carte artisanale',
          subtitle: 'JPG, PNG, PDF (max 10 MO)',
          selectedBytes: _idDocBytes,
          selectedName: _idDocName,
          onTap: _pickIdDoc,
          onRemove: () => setState(() {
            _idDocBytes = null;
            _idDocName = null;
          }),
          placeholderIcon: Icons.badge_outlined,
        ),
      ],
    );
  }

  // ==================== 4. FORMULAIRE PROMOTEUR ====================
  Widget _buildPromoteurForm() {
    return Column(
      children: [
        // Section 1 : Informations personnelles
        _buildCardSection(
          icon: Icons.person_outline,
          title: 'Informations personnelles',
          subtitle: 'Renseignez vos coordonnées de contact',
          children: [
            _buildPillField(
              controller: _prenomController,
              hint: 'Prénom',
              icon: Icons.person_outline,
              validator: (val) => val == null || val.isEmpty ? 'Prénom requis' : null,
            ),
            const SizedBox(height: 12),
            _buildPillField(
              controller: _nomController,
              hint: 'Nom',
              icon: Icons.person_outline,
              validator: (val) => val == null || val.isEmpty ? 'Nom requis' : null,
            ),
            const SizedBox(height: 12),
            _buildPillField(
              controller: _emailController,
              hint: 'Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (val) => (val == null || !val.contains('@')) ? 'Email invalide' : null,
            ),
            const SizedBox(height: 12),
            _buildPillField(
              controller: _passwordController,
              hint: 'Mot de passe',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (val) => (val == null || val.length < 6) ? 'Min 6 caractères' : null,
            ),
            const SizedBox(height: 12),
            _buildPillField(
              controller: _telephoneController,
              hint: 'Téléphone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _buildInteractiveFilePickerTile(
              title: 'Choisir une photo',
              subtitle: 'JPG, PNG (max 10 MO)',
              selectedBytes: _avatarBytes,
              selectedName: _avatarName,
              onTap: _pickAvatar,
              onRemove: () => setState(() {
                _avatarBytes = null;
                _avatarName = null;
              }),
              placeholderIcon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildInteractiveFilePickerTile(
              title: 'Pièce d’identité du représentant',
              subtitle: 'JPG, PNG, PDF (max 10 MO)',
              selectedBytes: _idDocBytes,
              selectedName: _idDocName,
              onTap: _pickIdDoc,
              onRemove: () => setState(() {
                _idDocBytes = null;
                _idDocName = null;
              }),
              placeholderIcon: Icons.badge_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Section 2 : Organisation
        _buildCardSection(
          icon: Icons.business_outlined,
          title: 'Informations sur l’organisation',
          subtitle: 'Parlez-nous de votre structure',
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nom de l’organisation',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
              ),
            ),
            const SizedBox(height: 6),
            _buildPillField(
              controller: _nomOrganisationController,
              hint: 'Ex : Agence Culture & Tourisme Mali',
              icon: Icons.home_work_outlined,
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Adresse complète',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
              ),
            ),
            const SizedBox(height: 6),
            _buildPillField(
              controller: _adresseController,
              hint: 'Ex : Bamako, ACI 2000',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Numéro d\'enregistrement (NIF, RCCM...)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
              ),
            ),
            const SizedBox(height: 6),
            _buildPillField(
              controller: _nifRccmController,
              hint: 'Ex : 0841234567-RCCM',
              icon: Icons.receipt_long_outlined,
            ),
            const SizedBox(height: 14),
            _buildInteractiveFilePickerTile(
              title: 'Document justificatif (RCCM / NIF)',
              subtitle: 'JPG, PNG, PDF (max 10 MO)',
              selectedBytes: _orgDocBytes,
              selectedName: _orgDocName,
              onTap: _pickOrgDoc,
              onRemove: () => setState(() {
                _orgDocBytes = null;
                _orgDocName = null;
              }),
              placeholderIcon: Icons.receipt_long_outlined,
            ),
          ],
        ),
      ],
    );
  }

  // ==================== WIDGETS HELPERS ====================

  Widget _buildCardSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primaryForest,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPillField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.textPrimary, size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primaryForest, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  /// Sélecteur de fichier interactif avec statut et prévisualisation
  Widget _buildInteractiveFilePickerTile({
    required String title,
    required String subtitle,
    required Uint8List? selectedBytes,
    required String? selectedName,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    required IconData placeholderIcon,
  }) {
    final hasFile = selectedBytes != null;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: hasFile ? const Color(0xFFF0FDF8) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasFile ? AppColors.primaryForest : AppColors.borderLight,
                  width: hasFile ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: hasFile ? AppColors.primaryForest : const Color(0xFFE8F4F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      hasFile ? Icons.check_circle_outline : Icons.add_photo_alternate_outlined,
                      color: hasFile ? Colors.white : AppColors.primaryForest,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasFile ? (selectedName ?? 'Fichier sélectionné') : title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: hasFile ? AppColors.primaryForest : AppColors.primaryForest,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasFile
                              ? '${(selectedBytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(2)} Mo • Prêt pour envoi'
                              : subtitle,
                          style: TextStyle(
                            fontSize: 10,
                            color: hasFile ? const Color(0xFF0E8F76) : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasFile)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Colors.redAccent),
                      onPressed: onRemove,
                      tooltip: 'Supprimer',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Vignette d'aperçu
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFD6EDE6),
            borderRadius: BorderRadius.circular(26),
            image: hasFile && (selectedName?.toLowerCase().endsWith('.pdf') != true)
                ? DecorationImage(
                    image: MemoryImage(selectedBytes),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasFile && (selectedName?.toLowerCase().endsWith('.pdf') != true)
              ? null
              : Icon(
                  hasFile ? Icons.picture_as_pdf_outlined : placeholderIcon,
                  color: AppColors.primaryForest,
                  size: 24,
                ),
        ),
      ],
    );
  }
}
