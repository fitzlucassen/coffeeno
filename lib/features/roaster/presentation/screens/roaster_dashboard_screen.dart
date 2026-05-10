import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/features/subscription/presentation/providers/subscription_provider.dart';
import '../providers/roaster_provider.dart';
import '../widgets/roaster_pro_paywall.dart';
import '../widgets/roaster_posts_tab.dart';
import '../widgets/roaster_stats_tab.dart';
import '../widgets/roaster_tastings_tab.dart';

class RoasterDashboardScreen extends ConsumerStatefulWidget {
  const RoasterDashboardScreen({super.key, required this.roasterId});

  final String roasterId;

  @override
  ConsumerState<RoasterDashboardScreen> createState() =>
      _RoasterDashboardScreenState();
}

class _RoasterDashboardScreenState extends ConsumerState<RoasterDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRoasterPro = ref.watch(isRoasterProProvider);

    if (!isRoasterPro) {
      return RoasterProPaywall(roasterId: widget.roasterId);
    }

    final roasterAsync = ref.watch(roasterDetailProvider(widget.roasterId));
    final roasterName = roasterAsync.value?.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(roasterName ?? l10n.roasterDashboard),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.dashboardTabStats),
            Tab(text: l10n.dashboardTabTastings),
            Tab(text: l10n.dashboardTabPosts),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RoasterStatsTab(roasterId: widget.roasterId),
          RoasterTastingsTab(roasterId: widget.roasterId),
          RoasterPostsTab(roasterId: widget.roasterId),
        ],
      ),
    );
  }
}
