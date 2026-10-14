import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service technique d'initialisation et d'accès à Firebase.
class FirebaseService {
  FirebaseService._();

  static Future<void> init() async {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyAz3UR_7kxYthRN8M3_uEGbx_k72lhAfpQ",
            appId: "1:258002604598:web:d2a07fc12825e824d23e97",
            messagingSenderId: "258002604598",
            projectId: "maliexplorer",
            authDomain: "maliexplorer.firebaseapp.com",
            storageBucket: "maliexplorer.firebasestorage.app",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
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
