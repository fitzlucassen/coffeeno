import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/farm_repository.dart';
import '../../domain/farm.dart';

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepository();
});

final farmDetailProvider =
    StreamProvider.family<Farm?, String>((ref, farmId) {
  final repository = ref.watch(farmRepositoryProvider);
  return repository.watchFarm(farmId);
});
