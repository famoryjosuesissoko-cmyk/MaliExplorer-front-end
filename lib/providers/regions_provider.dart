import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/region_service.dart';
import '../models/region_model.dart';

final regionsProvider = FutureProvider<List<RegionModel>>((ref) async {
  final service = ref.watch(regionServiceProvider);
  return await service.getRegions();
});

