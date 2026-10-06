import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

/// Service technique pour le stockage d'images et médias via Supabase Storage.
class StorageService {
  StorageService._();

  static const String supabaseUrl = 'https://dzhqwkpwaljqsjwoqvso.supabase.co';
  static const String supabasePublishableKey = 'sb_publishable_7yi5d-qBrG9OnmKavJZ39Q_0OGGAciz';
  static const String defaultBucket = 'maliexplorer-media';

  /// Taille maximale autorisée pour un fichier : 10 Mo (10 485 760 octets)
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  static Future<void> init() async {
    try {
      await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);
    } catch (e) {
      debugPrint('[StorageService] Erreur init Supabase: $e');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Téléversement générique d'un fichier binaire vers Supabase Storage
  /// avec validation de taille (max 10 MO) et génération d'un nom unique.
  static Future<String> uploadFile({
    required String folder,
    required String fileName,
    required Uint8List bytes,
    String bucket = defaultBucket,
    ApiService? apiService,
  }) async {
    // 1. Validation de la taille maximale (10 Mo)
    if (bytes.lengthInBytes > maxFileSizeBytes) {
      final sizeMo = (bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(1);
      throw Exception('Le fichier ($sizeMo Mo) dépasse la limite autorisée de 10 Mo.');
    }

    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final uniquePath = '$folder/${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';

    // 2. Tentative d'upload direct vers Supabase Storage
    try {
      await client.storage.from(bucket).uploadBinary(
            uniquePath,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      final publicUrl = client.storage.from(bucket).getPublicUrl(uniquePath);
      debugPrint('[StorageService] Fichier uploadé avec succès sur Supabase: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('[StorageService] Échec upload direct Supabase ($e), tentative via API Backend...');

      // 3. Fallback : upload via le endpoint multipart du backend Spring Boot
      if (apiService != null) {
        try {
          final response = await apiService.uploadMultipart(
            '/storage/upload',
            fileFieldName: 'file',
            fileBytes: bytes,
            filename: cleanFileName,
            fields: {'folder': folder},
          );

          if (response.statusCode == 201 || response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            final url = data['fileUrl'] as String? ?? data['url'] as String?;
            if (url != null && url.isNotEmpty) {
              return url;
            }
          } else {
            debugPrint('[StorageService] Fallback backend status: ${response.statusCode} - ${response.body}');
          }
        } catch (backendError) {
          debugPrint('[StorageService] Erreur fallback backend: $backendError');
        }
      }

      // Si Supabase et le backend ont tous deux échoué, propager l'erreur
      throw Exception(
        'Impossible de téléverser l\'image sur Supabase Storage : RLS policy non configurée sur le bucket "$bucket" ou bucket manquant ($e).',
      );
    }
  }

  /// Upload direct sans fallback
  static Future<String> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
  }) async {
    if (bytes.lengthInBytes > maxFileSizeBytes) {
      throw Exception('Fichier trop volumineux (max 10 Mo).');
    }
    await client.storage.from(bucket).uploadBinary(path, bytes);
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Récupère l'URL publique d'un asset
  static String getPublicUrl({required String bucket, required String path}) {
    return client.storage.from(bucket).getPublicUrl(path);
  }
}
