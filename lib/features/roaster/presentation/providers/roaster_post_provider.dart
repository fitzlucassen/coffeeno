import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/roaster_post_repository.dart';
import '../../domain/roaster_post.dart';

final roasterPostRepositoryProvider = Provider<RoasterPostRepository>((ref) {
  return RoasterPostRepository();
});

final roasterPostsProvider =
    StreamProvider.family<List<RoasterPost>, String>((ref, roasterId) {
  final repo = ref.watch(roasterPostRepositoryProvider);
  return repo.watchPostsForRoaster(roasterId);
});
