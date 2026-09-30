import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_model.dart';
import '../services/badge_service.dart';
import 'auth_provider.dart';

final badgeServiceProvider = Provider<BadgeService>((ref) {
  final apiService = ref.watch(authServiceProvider).apiService;
  return BadgeService(apiService: apiService);
});

final userProgressionProvider = FutureProvider<ProgressionModel?>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return null;

  final badgeService = ref.watch(badgeServiceProvider);
  try {
    return await badgeService.getProgression();
  } catch (_) {
    return null;
  }
});
