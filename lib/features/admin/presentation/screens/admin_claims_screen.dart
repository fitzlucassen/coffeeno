import 'package:coffeeno/features/auth/presentation/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/claim.dart';
import '../providers/admin_provider.dart';

class AdminClaimsScreen extends ConsumerWidget {
  const AdminClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final claimsAsync = ref.watch(pendingClaimsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminClaims)),
      body: claimsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.error)),
        data: (claims) {
          if (claims.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 48,
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text(l10n.noPendingClaims,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: claims.length,
            itemBuilder: (context, index) =>
                _ClaimTile(claim: claims[index]),
          );
        },
      ),
    );
  }
}

class _ClaimTile extends ConsumerWidget {
  const _ClaimTile({required this.claim});

  final Claim claim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final typeLabel =
        claim.entityType == 'roaster' ? l10n.roaster : l10n.farmName;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  claim.entityType == 'roaster'
                      ? Icons.store_rounded
                      : Icons.agriculture_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(claim.entityName,
                      style: theme.textTheme.titleMedium),
                ),
                Chip(
                  label: Text(typeLabel),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMd().format(claim.createdAt),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            FutureBuilder(
              future:
                  ref.watch(userRepositoryProvider).getUser(claim.userId),
              builder: (context, snapshot) {
                final displayName =
                    snapshot.data?.displayName ?? claim.userId;
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.push('/user/${claim.userId}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            displayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (claim.message != null && claim.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(claim.message!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _reject(context, ref),
                  child: Text(l10n.rejectClaim),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _approve(context, ref),
                  child: Text(l10n.approveClaim),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final repo = ref.read(claimRepositoryProvider);
    await repo.approveClaim(claim.id, adminUid);
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final repo = ref.read(claimRepositoryProvider);
    await repo.rejectClaim(claim.id, adminUid);
  }
}
