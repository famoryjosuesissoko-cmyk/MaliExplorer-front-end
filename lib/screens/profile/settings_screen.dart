import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final startTime = DateTime.now();
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/regions'))
          .timeout(const Duration(seconds: 5));
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      setState(() {
        _isTesting = false;
        _testSuccess = response.statusCode >= 200 && response.statusCode < 300;
        _testResult = _testSuccess
            ? 'Connecté avec succès ! Code ${response.statusCode} (${duration}ms)'
            : 'Erreur HTTP ${response.statusCode} : ${response.body}';
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _testSuccess = false;
        _testResult = 'Échec de connexion : $e';
      });
    }
  }

  void _showChangeUrlDialog() {
    final controller = TextEditingController(text: ApiConstants.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configurer l\'URL API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisissez un profil ou entrez une URL :',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.sm),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'URL API Backend',
                hintText: 'http://...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ActionChip(
                  label: const Text('USB (localhost)'),
                  onPressed: () => controller.text = 'http://localhost:8080/api',
                ),
                ActionChip(
                  label: const Text('Wi-Fi (192.168.10.255)'),
                  onPressed: () => controller.text = 'http://192.168.10.255:8080/api',
                ),
                ActionChip(
                  label: const Text('Émulateur (10.0.2.2)'),
                  onPressed: () => controller.text = 'http://10.0.2.2:8080/api',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                ApiConstants.baseUrl = controller.text;
                _testResult = null;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeModeProvider);
    final isDark = currentTheme == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres & Tests')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.md),
        children: [
          // Section Backend API
          const Text(
            'Serveur Backend Spring Boot',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primaryForest,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.dns, color: AppColors.primaryForest),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Text(
                          ApiConstants.baseUrl,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Modifier l\'URL',
                        onPressed: _showChangeUrlDialog,
                      ),
                    ],
                  ),
                  const Divider(),
                  if (_testResult != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.sm),
                      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                      decoration: BoxDecoration(
                        color: _testSuccess
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _testSuccess ? AppColors.success : AppColors.error,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _testSuccess ? Icons.check_circle : Icons.error,
                            color: _testSuccess ? AppColors.success : AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _testResult!,
                              style: TextStyle(
                                fontSize: 13,
                                color: _testSuccess ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: _isTesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.network_check),
                      label: Text(_isTesting ? 'Test en cours...' : 'Tester la connexion Backend'),
                      onPressed: _isTesting ? null : _testConnection,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // Section Affichage
          const Text(
            'Affichage',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primaryForest,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          AppCard(
            child: SwitchListTile(
              title: const Text('Mode Sombre (Dark Theme)'),
              subtitle: const Text('Ajuste le contraste pour un confort visuel'),
              value: isDark,
              activeThumbColor: AppColors.sahelGold,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // Section À propos
          const Text(
            'À propos de l\'application',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primaryForest,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Application'),
                  subtitle: const Text(AppStrings.appName),
                  trailing: const Text('v1.0.0', style: TextStyle(color: AppColors.textSecondary)),
                ),
                const Divider(),
                const ListTile(
                  title: Text('Architecture'),
                  subtitle: Text('Flutter Mobile & Web + Spring Boot Backend + Firebase'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
