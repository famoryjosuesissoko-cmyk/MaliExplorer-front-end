import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service technique d'initialisation et d'accès à Firebase.
class FirebaseService {
  FirebaseService._();

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;

  static User? get currentUser => auth.currentUser;

  /// Récupère le token JWT Firebase ID actuel
  static Future<String?> getIdToken([bool forceRefresh = false]) async {
    final user = currentUser;
    if (user == null) return null;
    return await user.getIdToken(forceRefresh);
  }
}
