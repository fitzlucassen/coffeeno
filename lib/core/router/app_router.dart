import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/edit_profile_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/coffee/presentation/screens/coffee_library_screen.dart';
import '../../features/coffee/presentation/screens/coffee_detail_screen.dart';
import '../../features/coffee/presentation/screens/add_coffee_screen.dart';
import '../../features/tasting/presentation/screens/add_tasting_screen.dart';
import '../../features/tasting/presentation/screens/tasting_detail_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/scanner/presentation/screens/camera_screen.dart';
import '../../features/scanner/presentation/screens/scan_review_screen.dart';
import '../../features/social/presentation/screens/user_profile_screen.dart';
import '../../features/social/presentation/screens/followers_screen.dart';
import '../../features/social/presentation/screens/leaderboard_screen.dart';
import '../../features/social/presentation/screens/user_search_screen.dart';
import '../../features/map/presentation/screens/coffee_map_screen.dart';
import '../../features/map/presentation/screens/origin_detail_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../features/roaster/presentation/screens/roaster_profile_screen.dart';
import '../../features/farm/presentation/screens/farm_profile_screen.dart';
import '../../features/admin/presentation/screens/admin_claims_screen.dart';
import '../../features/admin/presentation/screens/claim_form_screen.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../widgets/main_shell.dart';

abstract final class AppRoutes {
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const profileSetup = '/profile-setup';
  static const feed = '/feed';
  static const library = '/library';
  static const map = '/map';
  static const profile = '/profile';
  static const coffeeDetail = '/coffee/:id';
  static const addCoffee = '/coffee/add';
  static const addTasting = '/tasting/add/:coffeeId';
  static const tastingDetail = '/tasting/:id';
  static const scan = '/scan';
  static const scanReview = '/scan/review';
  static const userProfile = '/user/:id';
  static const followers = '/user/:id/followers';
  static const following = '/user/:id/following';
  static const editProfile = '/edit-profile';
  static const leaderboard = '/leaderboard';
  static const userSearch = '/search/users';
  static const originDetail = '/origin/:country';
  static const stats = '/stats';
  static const roasterProfile = '/roaster/:id';
  static const farmProfile = '/farm/:id';
  static const adminClaims = '/admin/claims';
  static const claimForm = '/claim/:entityType/:entityId';
  static const paywall = '/paywall';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.feed,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.welcome ||
          state.matchedLocation == AppRoutes.signIn ||
          state.matchedLocation == AppRoutes.signUp;
      final isProfileSetup =
          state.matchedLocation == AppRoutes.profileSetup;
      final isShellRoute =
          state.matchedLocation == AppRoutes.feed ||
          state.matchedLocation == AppRoutes.library ||
          state.matchedLocation == AppRoutes.map ||
          state.matchedLocation == AppRoutes.profile;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.welcome;
      if (isLoggedIn && isAuthRoute) return AppRoutes.feed;

      // Only check for missing user doc on main tab routes, not during
      // active flows like scanning or adding a coffee.
      if (isLoggedIn &&
          isShellRoute &&
          !isProfileSetup &&
          currentUser.hasValue &&
          currentUser.value == null) {
        return AppRoutes.profileSetup;
      }

      return null;
    },
    routes: [
      // ── Auth routes (no shell) ──
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // ── Main shell with bottom nav ──
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.feed,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FeedScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.library,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CoffeeLibraryScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.map,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CoffeeMapScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UserProfileScreen(),
            ),
          ),
        ],
      ),

      // ── Detail routes (full screen, over shell) ──
      // addCoffee must come before coffeeDetail so '/coffee/add' isn't
      // matched by '/coffee/:id'.
      GoRoute(
        path: AppRoutes.addCoffee,
        builder: (context, state) => const AddCoffeeScreen(),
      ),
      GoRoute(
        path: AppRoutes.coffeeDetail,
        builder: (context, state) => CoffeeDetailScreen(
          coffeeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.addTasting,
        builder: (context, state) => AddTastingScreen(
          coffeeId: state.pathParameters['coffeeId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.tastingDetail,
        builder: (context, state) => TastingDetailScreen(
          tastingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.scan,
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanReview,
        builder: (context, state) => const ScanReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.userProfile,
        builder: (context, state) => UserProfileScreen(
          userId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.followers,
        builder: (context, state) => FollowersScreen(
          userId: state.pathParameters['id']!,
          showFollowers: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.following,
        builder: (context, state) => FollowersScreen(
          userId: state.pathParameters['id']!,
          showFollowers: false,
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.userSearch,
        builder: (context, state) => const UserSearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.originDetail,
        builder: (context, state) => OriginDetailScreen(
          country: state.pathParameters['country']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.stats,
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: AppRoutes.roasterProfile,
        builder: (context, state) => RoasterProfileScreen(
          roasterId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.farmProfile,
        builder: (context, state) => FarmProfileScreen(
          farmId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminClaims,
        builder: (context, state) => const AdminClaimsScreen(),
      ),
      GoRoute(
        path: AppRoutes.claimForm,
        builder: (context, state) => ClaimFormScreen(
          entityType: state.pathParameters['entityType']!,
          entityId: state.pathParameters['entityId']!,
          entityName: state.uri.queryParameters['name'] ?? '',
        ),
      ),
    ],
  );
});
