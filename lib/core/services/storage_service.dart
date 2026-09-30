import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service technique pour le stockage d'images et médias via Supabase Storage.
class StorageService {
  StorageService._();

  static const String supabaseUrl = 'https://dzhqwkpwaljqsjwoqvso.supabase.co';
  static const String supabasePublishableKey = 'sb_publishable_7yi5d-qBrG9OnmKavJZ39Q_0OGGAciz';

  static Future<void> init() async {
    try {
      await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);
    } catch (_) {}
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Upload d'un fichier binaire vers un bucket Supabase
  static Future<String> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
  }) async {
    await client.storage.from(bucket).uploadBinary(path, bytes);
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Récupère l'URL publique d'un asset
  static String getPublicUrl({required String bucket, required String path}) {
    return client.storage.from(bucket).getPublicUrl(path);
  }
}
