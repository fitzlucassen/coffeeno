import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/core/widgets/empty_state_view.dart';
import 'package:coffeeno/core/widgets/error_retry_view.dart';
import 'package:coffeeno/features/social/presentation/providers/block_provider.dart';
import 'package:coffeeno/features/social/presentation/providers/social_provider.dart';
import 'package:coffeeno/features/social/presentation/widgets/user_list_tile.dart';

/// A screen for searching users by username or display name.
class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchUsers,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            setState(() => _query = value.trim());
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? EmptyStateView(
              icon: Icons.person_search,
              message: l10n.searchForCoffeeLovers,
            )
          : _SearchResults(query: _query),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final resultsAsync = ref.watch(userSearchResultsProvider(query));
    final blocked = ref.watch(blockedUidsProvider);

    return resultsAsync.when(
      data: (rawResults) {
        final results = rawResults
            .where((u) => !blocked.contains(u.uid))
            .toList();
        if (results.isEmpty) {
          return EmptyStateView(
            icon: Icons.search_off,
            message: l10n.noUsersFound(query),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final user = results[index];
            return UserListTile(
              userId: user.uid,
              displayName: user.displayName,
              avatarUrl: user.avatarUrl,
              username: user.username,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const ErrorRetryView(),
    );
  }
}
