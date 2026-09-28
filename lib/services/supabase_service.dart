import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Vos identifiants Supabase
  static const String supabaseUrl = 'https://dzhqwkpwaljqsjwoqvso.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_7yi5d-qBrG9OnmKavJZ39Q_0OGGAciz';

  static Future init() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static Future initialize() async => init();

  /// Instance du client Supabase pour effectuer vos requêtes
  static SupabaseClient get client => Supabase.instance.client;
}
