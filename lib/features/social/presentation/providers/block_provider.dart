import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/block_repository.dart';

final blockRepositoryProvider = Provider<BlockRepository>((ref) {
  return BlockRepository();
});

/// Streams the UIDs the current user has blocked. Empty when signed out.
final outgoingBlocksProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const <String>{});
  return ref.watch(blockRepositoryProvider).watchOutgoing(uid);
});

/// Streams the UIDs that have blocked the current user. Empty when signed out.
final incomingBlocksProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const <String>{});
  return ref.watch(blockRepositoryProvider).watchIncoming(uid);
});

/// Union of outgoing + incoming — the full set of UIDs that should be
/// filtered out of feeds, leaderboards, search results, comment lists, and
/// any other user-visible surface. Subscribes to both streams so updates
/// from either side are reactive.
final blockedUidsProvider = Provider<Set<String>>((ref) {
  final outgoing = ref.watch(outgoingBlocksProvider).value ?? const <String>{};
  final incoming = ref.watch(incomingBlocksProvider).value ?? const <String>{};
  return {...outgoing, ...incoming};
});
