import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/roaster_repository.dart';
import '../../domain/roaster.dart';

final roasterRepositoryProvider = Provider<RoasterRepository>((ref) {
  return RoasterRepository();
});

final roasterDetailProvider =
    StreamProvider.family<Roaster?, String>((ref, roasterId) {
  final repository = ref.watch(roasterRepositoryProvider);
  return repository.watchRoaster(roasterId);
});
