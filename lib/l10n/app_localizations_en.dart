// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Coffeeno';

  @override
  String get feedTab => 'Feed';

  @override
  String get libraryTab => 'Library';

  @override
  String get mapTab => 'Map';

  @override
  String get profileTab => 'Profile';

  @override
  String get welcomeTitle => 'Welcome to Coffeeno';

  @override
  String get welcomeSubtitle =>
      'Discover, taste, and share your coffee journey';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get displayName => 'Display Name';

  @override
  String get username => 'Username';

  @override
  String get bio => 'Bio';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get scanCoffee => 'Scan Coffee';

  @override
  String get addCoffee => 'Add Coffee';

  @override
  String get addTasting => 'Add Tasting';

  @override
  String get myCoffees => 'My Coffees';

  @override
  String get coffeeDetail => 'Coffee Detail';

  @override
  String get noCoffeesYet => 'No coffees yet';

  @override
  String get noCoffeesYetSubtitle =>
      'Scan a bag or add one manually to get started';

  @override
  String get roaster => 'Roaster';

  @override
  String get coffeeName => 'Coffee Name';

  @override
  String get originCountry => 'Country';

  @override
  String get originRegion => 'Region';

  @override
  String get farmName => 'Farm';

  @override
  String get farmerName => 'Farmer';

  @override
  String get altitude => 'Altitude';

  @override
  String get variety => 'Variety';

  @override
  String get processingMethod => 'Process';

  @override
  String get roastDate => 'Roast Date';

  @override
  String get roastLevel => 'Roast Level';

  @override
  String get flavorNotes => 'Flavor Notes';

  @override
  String get brewMethod => 'Brew Method';

  @override
  String get grindSize => 'Grind Size';

  @override
  String get dose => 'Dose (g)';

  @override
  String get waterAmount => 'Water (ml)';

  @override
  String get ratio => 'Ratio';

  @override
  String get brewTime => 'Brew Time';

  @override
  String get waterTemperature => 'Water Temp (°C)';

  @override
  String get aroma => 'Aroma';

  @override
  String get flavor => 'Flavor';

  @override
  String get acidity => 'Acidity';

  @override
  String get body => 'Body';

  @override
  String get sweetness => 'Sweetness';

  @override
  String get aftertaste => 'Aftertaste';

  @override
  String get overallRating => 'Overall Rating';

  @override
  String get notes => 'Notes';

  @override
  String get tastings => 'Tastings';

  @override
  String get noTastingsYet => 'No tastings yet';

  @override
  String get noTastingsYetSubtitle => 'Add a tasting to rate this coffee';

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String get follow => 'Follow';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get like => 'Like';

  @override
  String get comment => 'Comment';

  @override
  String get addComment => 'Add a comment...';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get topRated => 'Top Rated';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get search => 'Search';

  @override
  String get coffeeOrigins => 'Coffee Origins';

  @override
  String mostLovedFrom(String country) {
    return 'Most loved from $country';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign Out';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get scanReview => 'Review Scan';

  @override
  String get scanReviewSubtitle => 'Check and edit the extracted information';

  @override
  String get scanning => 'Scanning...';

  @override
  String get extractingInfo => 'Extracting coffee info...';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Something went wrong';

  @override
  String ratingsCount(int count) {
    return '$count ratings';
  }

  @override
  String tastingsCount(int count) {
    return '$count tastings';
  }

  @override
  String get emptyFeed => 'Follow coffee lovers to see their tastings here';

  @override
  String get findPeople => 'Find people';

  @override
  String get noCommentsYet => 'No comments yet';

  @override
  String get beFirstToComment => 'Be the first to share your thoughts';

  @override
  String get comments => 'Comments';

  @override
  String get couldNotLoadComments => 'Could not load comments';

  @override
  String get noFollowersYet => 'No followers yet';

  @override
  String get notFollowingAnyone => 'Not following anyone yet';

  @override
  String get noRatedCoffeesYet => 'No rated coffees yet';

  @override
  String get selectCountry => 'Select a country to see its top coffees';

  @override
  String noRatedCoffeesFrom(String country) {
    return 'No rated coffees from $country yet';
  }

  @override
  String get searchForCoffeeLovers => 'Search for coffee lovers';

  @override
  String noUsersFound(String query) {
    return 'No users found for \"$query\"';
  }

  @override
  String get userNotFound => 'User not found';

  @override
  String get global => 'Global';

  @override
  String get byOrigin => 'By Origin';

  @override
  String get noOriginsYet => 'No coffee origins to display yet';

  @override
  String get addCoffeesForMap =>
      'Add coffees with origin info to see them on the map';

  @override
  String get noCoffeesFromOrigin => 'No coffees found for this origin';

  @override
  String get deleteCoffeeConfirm => 'Delete this coffee and all its tastings?';

  @override
  String similarCoffeeAlert(String roaster) {
    return 'You have a similar coffee from $roaster';
  }

  @override
  String get viewSimilar => 'View';

  @override
  String get statsTab => 'Stats';

  @override
  String get insights => 'Insights';

  @override
  String get topOrigins => 'Top Origins';

  @override
  String get topProcessing => 'Top Processing Methods';

  @override
  String get flavorProfile => 'Flavor Profile';

  @override
  String get tastingTimeline => 'Tasting Timeline';

  @override
  String get avgScore => 'Avg Score';

  @override
  String get totalTastings => 'Total Tastings';

  @override
  String get totalCoffees => 'Total Coffees';

  @override
  String get brewSuggestion => 'Brew Suggestion';

  @override
  String get getSuggestion => 'Get AI Suggestion';

  @override
  String get suggestedParams => 'Suggested Parameters';

  @override
  String get shareTasting => 'Share Tasting';

  @override
  String get aboutRoaster => 'About the Roaster';

  @override
  String get aboutFarm => 'About the Farm';

  @override
  String get visitWebsite => 'Visit Website';

  @override
  String get enriching => 'Looking up info...';

  @override
  String get noInfoFound => 'No info found';

  @override
  String get roasterProfile => 'Roaster Profile';

  @override
  String get farmProfile => 'Farm Profile';

  @override
  String coffeesFromRoaster(String roaster) {
    return 'Coffees from $roaster';
  }

  @override
  String coffeesFromFarm(String farm) {
    return 'Coffees from $farm';
  }

  @override
  String get keyPeople => 'Key People';

  @override
  String get locationLabel => 'Location';

  @override
  String get noDescription => 'No description available';

  @override
  String get claimProfile => 'Claim this profile';

  @override
  String get pendingClaim => 'Claim pending approval';

  @override
  String get approvedClaim => 'Verified';

  @override
  String get editProfileInfo => 'Edit Info';

  @override
  String get claimMessage => 'Why should you manage this profile?';

  @override
  String get submitClaim => 'Submit Claim';

  @override
  String get adminClaims => 'Pending Claims';

  @override
  String get approveClaim => 'Approve';

  @override
  String get rejectClaim => 'Reject';

  @override
  String get noPendingClaims => 'No pending claims';

  @override
  String get claimSubmitted => 'Claim submitted for review';

  @override
  String get premium => 'Premium';

  @override
  String get freePlan => 'Free Plan';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumFeatures => 'Unlock all features';

  @override
  String get premiumPrice => '\$1.99/month';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get premiumRequired => 'Premium Required';

  @override
  String get premiumRequiredDesc =>
      'This feature requires a premium subscription';

  @override
  String coffeeLimitReached(int max) {
    return 'You\'ve reached the free limit of $max coffees';
  }

  @override
  String tastingLimitReached(int max) {
    return 'You\'ve reached the free limit of $max tastings this month';
  }

  @override
  String get unlimitedCoffees => 'Unlimited coffees';

  @override
  String get unlimitedTastings => 'Unlimited tastings';

  @override
  String get aiFeatures => 'AI-powered features';

  @override
  String get photoUploads => 'Photo uploads';

  @override
  String get shareCards => 'Share tasting cards';

  @override
  String get admin => 'Admin';

  @override
  String get scanHint => 'Position the coffee bag label in the frame';

  @override
  String get price => 'Price';

  @override
  String get lot => 'Lot';

  @override
  String get harvestYear => 'Harvest Year';

  @override
  String get resting => 'Resting';

  @override
  String get peakFreshness => 'Peak freshness';

  @override
  String get useSoon => 'Use soon';

  @override
  String get pastPeak => 'Past peak';

  @override
  String daysPostRoast(int days) {
    return '$days days post-roast';
  }

  @override
  String get communityRating => 'Community rating';

  @override
  String communityRatingValue(String rating, int count) {
    return '$rating ($count users)';
  }

  @override
  String get scanABag => 'Scan a bag';

  @override
  String get addManually => 'Add manually';

  @override
  String get addCoffeeTitle => 'Add a coffee';

  @override
  String get selectFlavors => 'Tap to select flavors';

  @override
  String get exploreTab => 'Explore';

  @override
  String get exploreTrending => 'Trending';

  @override
  String get exploreRecentlyAdded => 'Recently Added';

  @override
  String get exploreTopRated => 'Top Rated';

  @override
  String get exploreNewRoasters => 'New Roasters';

  @override
  String get roasterDashboard => 'Roaster Dashboard';

  @override
  String get roasterProRequired => 'Roaster Pro Required';

  @override
  String get roasterProDesc => 'Access detailed analytics about your coffees';

  @override
  String get roasterProPrice => '€9.99/month';

  @override
  String get recentTastings30d => 'Last 30 days';

  @override
  String get topCoffeesByRating => 'Top Coffees';

  @override
  String get exploreNearYou => 'Popular Near You';

  @override
  String get country => 'Country';
}
