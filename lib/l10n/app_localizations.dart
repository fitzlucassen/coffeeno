import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// The app title
  ///
  /// In en, this message translates to:
  /// **'Coffeeno'**
  String get appTitle;

  /// Onboarding skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Onboarding next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Onboarding final CTA
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// Onboarding scan page title
  ///
  /// In en, this message translates to:
  /// **'Scan any coffee bag'**
  String get onboardingScanTitle;

  /// Onboarding scan page body
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a bag — we read the label and fill in origin, roast, and flavor notes for you.'**
  String get onboardingScanBody;

  /// Onboarding taste page title
  ///
  /// In en, this message translates to:
  /// **'Keep a tasting journal'**
  String get onboardingTasteTitle;

  /// Onboarding taste page body
  ///
  /// In en, this message translates to:
  /// **'Rate every brew and track how your palate evolves over time.'**
  String get onboardingTasteBody;

  /// Onboarding discover page title
  ///
  /// In en, this message translates to:
  /// **'Discover what others brew'**
  String get onboardingDiscoverTitle;

  /// Onboarding discover page body
  ///
  /// In en, this message translates to:
  /// **'Follow coffee lovers, like and comment on their tastings, and climb the leaderboard.'**
  String get onboardingDiscoverBody;

  /// Onboarding map page title
  ///
  /// In en, this message translates to:
  /// **'Explore coffee origins'**
  String get onboardingMapTitle;

  /// Onboarding map page body
  ///
  /// In en, this message translates to:
  /// **'See every coffee you\'ve tasted plotted on a world map and dive into each origin.'**
  String get onboardingMapBody;

  /// Onboarding preferences page title
  ///
  /// In en, this message translates to:
  /// **'Tell us your taste'**
  String get onboardingPrefsTitle;

  /// Onboarding preferences page body
  ///
  /// In en, this message translates to:
  /// **'Pick a few favorites so we can tailor what you discover. You can change these anytime.'**
  String get onboardingPrefsBody;

  /// Onboarding brew method preference section label
  ///
  /// In en, this message translates to:
  /// **'How do you brew?'**
  String get onboardingPrefsBrewMethods;

  /// Onboarding roast level preference section label
  ///
  /// In en, this message translates to:
  /// **'Roast levels you enjoy'**
  String get onboardingPrefsRoastLevels;

  /// Onboarding flavor preference section label
  ///
  /// In en, this message translates to:
  /// **'Flavors you love'**
  String get onboardingPrefsFlavors;

  /// Gamification tier 1 title
  ///
  /// In en, this message translates to:
  /// **'Bean Sprout'**
  String get levelBeanSprout;

  /// Gamification tier 2 title
  ///
  /// In en, this message translates to:
  /// **'Home Brewer'**
  String get levelHomeBrewer;

  /// Gamification tier 3 title
  ///
  /// In en, this message translates to:
  /// **'Coffee Enthusiast'**
  String get levelEnthusiast;

  /// Gamification tier 4 title
  ///
  /// In en, this message translates to:
  /// **'Cupper'**
  String get levelCupper;

  /// Gamification tier 5 title
  ///
  /// In en, this message translates to:
  /// **'Connoisseur'**
  String get levelConnoisseur;

  /// Gamification tier 6 title
  ///
  /// In en, this message translates to:
  /// **'Master Taster'**
  String get levelMasterTaster;

  /// Compact points display
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String pointsLabel(int points);

  /// Progress to next tier
  ///
  /// In en, this message translates to:
  /// **'{points} pts to {level}'**
  String pointsToNextLevel(int points, String level);

  /// Title of the level-up celebration
  ///
  /// In en, this message translates to:
  /// **'Level up!'**
  String get levelUpTitle;

  /// Body of the level-up celebration
  ///
  /// In en, this message translates to:
  /// **'You\'re now a {level}.'**
  String levelUpBody(String level);

  /// Button to start the guided brew timer
  ///
  /// In en, this message translates to:
  /// **'Start brew'**
  String get brewGuideStart;

  /// Button to stop the guided brew timer
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get brewGuideStop;

  /// Button to reset the guided brew timer
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get brewGuideReset;

  /// Shown when the brew timer hits the suggested time
  ///
  /// In en, this message translates to:
  /// **'Target time reached'**
  String get brewGuideTargetReached;

  /// Guided brew section title
  ///
  /// In en, this message translates to:
  /// **'Guided brew'**
  String get brewGuideTitle;

  /// Confirmation that AI params filled the form
  ///
  /// In en, this message translates to:
  /// **'Suggested parameters applied below'**
  String get brewSuggestionApplied;

  /// Banner when scanning a coffee you already own
  ///
  /// In en, this message translates to:
  /// **'Already in your library'**
  String get alreadyInLibrary;

  /// Button to re-add a previously owned coffee
  ///
  /// In en, this message translates to:
  /// **'Add again'**
  String get addAgain;

  /// Button to open an existing coffee instead of re-adding
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openExisting;

  /// Confirmation after re-adding a coffee
  ///
  /// In en, this message translates to:
  /// **'Added a fresh bag to your shelf'**
  String get reAddedToShelf;

  /// Feed tab label
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feedTab;

  /// Library tab label
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTab;

  /// Map tab label
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTab;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// Welcome screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Coffeeno'**
  String get welcomeTitle;

  /// Welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Discover, taste, and share your coffee journey'**
  String get welcomeSubtitle;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Google sign in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Display name field label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Bio field label
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Link to sign up
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Link to sign in
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Divider text between form and social sign in
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// Scan coffee button
  ///
  /// In en, this message translates to:
  /// **'Scan Coffee'**
  String get scanCoffee;

  /// Add coffee manually button
  ///
  /// In en, this message translates to:
  /// **'Add Coffee'**
  String get addCoffee;

  /// Add tasting button
  ///
  /// In en, this message translates to:
  /// **'Add Tasting'**
  String get addTasting;

  /// Coffee library title
  ///
  /// In en, this message translates to:
  /// **'My Coffees'**
  String get myCoffees;

  /// Coffee detail screen title
  ///
  /// In en, this message translates to:
  /// **'Coffee Detail'**
  String get coffeeDetail;

  /// Empty library message
  ///
  /// In en, this message translates to:
  /// **'No coffees yet'**
  String get noCoffeesYet;

  /// Empty library subtitle
  ///
  /// In en, this message translates to:
  /// **'Scan a bag or add one manually to get started'**
  String get noCoffeesYetSubtitle;

  /// Roaster field label
  ///
  /// In en, this message translates to:
  /// **'Roaster'**
  String get roaster;

  /// Coffee name field label
  ///
  /// In en, this message translates to:
  /// **'Coffee Name'**
  String get coffeeName;

  /// Origin country field label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get originCountry;

  /// Origin region field label
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get originRegion;

  /// Farm name field label
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get farmName;

  /// Farmer name field label
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmerName;

  /// Altitude field label
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get altitude;

  /// Variety/cultivar field label
  ///
  /// In en, this message translates to:
  /// **'Variety'**
  String get variety;

  /// Processing method field label
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get processingMethod;

  /// Roast date field label
  ///
  /// In en, this message translates to:
  /// **'Roast Date'**
  String get roastDate;

  /// Roast level field label
  ///
  /// In en, this message translates to:
  /// **'Roast Level'**
  String get roastLevel;

  /// Flavor notes field label
  ///
  /// In en, this message translates to:
  /// **'Flavor Notes'**
  String get flavorNotes;

  /// Brew method field label
  ///
  /// In en, this message translates to:
  /// **'Brew Method'**
  String get brewMethod;

  /// Grind size field label
  ///
  /// In en, this message translates to:
  /// **'Grind Size'**
  String get grindSize;

  /// Coffee dose field label
  ///
  /// In en, this message translates to:
  /// **'Dose (g)'**
  String get dose;

  /// Water amount field label
  ///
  /// In en, this message translates to:
  /// **'Water (ml)'**
  String get waterAmount;

  /// Brew ratio field label
  ///
  /// In en, this message translates to:
  /// **'Ratio'**
  String get ratio;

  /// Brew time field label
  ///
  /// In en, this message translates to:
  /// **'Brew Time'**
  String get brewTime;

  /// Water temperature field label
  ///
  /// In en, this message translates to:
  /// **'Water Temp (°C)'**
  String get waterTemperature;

  /// Aroma score label
  ///
  /// In en, this message translates to:
  /// **'Aroma'**
  String get aroma;

  /// Flavor score label
  ///
  /// In en, this message translates to:
  /// **'Flavor'**
  String get flavor;

  /// Acidity score label
  ///
  /// In en, this message translates to:
  /// **'Acidity'**
  String get acidity;

  /// Body score label
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// Sweetness score label
  ///
  /// In en, this message translates to:
  /// **'Sweetness'**
  String get sweetness;

  /// Aftertaste score label
  ///
  /// In en, this message translates to:
  /// **'Aftertaste'**
  String get aftertaste;

  /// Overall rating label
  ///
  /// In en, this message translates to:
  /// **'Overall Rating'**
  String get overallRating;

  /// Free text notes label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Tastings section title
  ///
  /// In en, this message translates to:
  /// **'Tastings'**
  String get tastings;

  /// Empty state for the tastings list
  ///
  /// In en, this message translates to:
  /// **'No tastings yet.'**
  String get noTastingsYet;

  /// Empty tastings subtitle
  ///
  /// In en, this message translates to:
  /// **'Add a tasting to rate this coffee'**
  String get noTastingsYetSubtitle;

  /// Followers label
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// Following label
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// Follow button
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// Unfollow button
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// Like button
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// Comment button
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// Comment input placeholder
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addComment;

  /// Leaderboard title
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// Top rated filter
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRated;

  /// User search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// Search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Map screen title
  ///
  /// In en, this message translates to:
  /// **'Coffee Origins'**
  String get coffeeOrigins;

  /// Origin detail title
  ///
  /// In en, this message translates to:
  /// **'Most loved from {country}'**
  String mostLovedFrom(String country);

  /// Edit profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Scan review screen title
  ///
  /// In en, this message translates to:
  /// **'Review Scan'**
  String get scanReview;

  /// Scan review subtitle
  ///
  /// In en, this message translates to:
  /// **'Check and edit the extracted information'**
  String get scanReviewSubtitle;

  /// Scanning loading message
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// AI extraction loading message
  ///
  /// In en, this message translates to:
  /// **'Extracting coffee info...'**
  String get extractingInfo;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// Number of ratings
  ///
  /// In en, this message translates to:
  /// **'{count} ratings'**
  String ratingsCount(int count);

  /// Number of tastings
  ///
  /// In en, this message translates to:
  /// **'{count} tastings'**
  String tastingsCount(int count);

  /// Shown to free-tier users indicating how many bag scans they have left in the current calendar month
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No free scans left this month} =1{1 free scan left this month} other{{count} free scans left this month}}'**
  String freeScansLeft(int count);

  /// Empty feed message
  ///
  /// In en, this message translates to:
  /// **'Follow coffee lovers to see their tastings here'**
  String get emptyFeed;

  /// Find people button
  ///
  /// In en, this message translates to:
  /// **'Find people'**
  String get findPeople;

  /// Empty comments message
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// Empty comments subtitle
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your thoughts'**
  String get beFirstToComment;

  /// Comments title
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// Comments error
  ///
  /// In en, this message translates to:
  /// **'Could not load comments'**
  String get couldNotLoadComments;

  /// Empty followers message
  ///
  /// In en, this message translates to:
  /// **'No followers yet'**
  String get noFollowersYet;

  /// Empty following message
  ///
  /// In en, this message translates to:
  /// **'Not following anyone yet'**
  String get notFollowingAnyone;

  /// Empty leaderboard message
  ///
  /// In en, this message translates to:
  /// **'No rated coffees yet'**
  String get noRatedCoffeesYet;

  /// Origin leaderboard prompt
  ///
  /// In en, this message translates to:
  /// **'Select a country to see its top coffees'**
  String get selectCountry;

  /// Empty origin leaderboard message
  ///
  /// In en, this message translates to:
  /// **'No rated coffees from {country} yet'**
  String noRatedCoffeesFrom(String country);

  /// Empty search state message
  ///
  /// In en, this message translates to:
  /// **'Search for coffee lovers'**
  String get searchForCoffeeLovers;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No users found for \"{query}\"'**
  String noUsersFound(String query);

  /// User not found message
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// Global tab label
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// By origin tab label
  ///
  /// In en, this message translates to:
  /// **'By Origin'**
  String get byOrigin;

  /// Empty map message
  ///
  /// In en, this message translates to:
  /// **'No coffee origins to display yet'**
  String get noOriginsYet;

  /// Empty map subtitle
  ///
  /// In en, this message translates to:
  /// **'Add coffees with origin info to see them on the map'**
  String get addCoffeesForMap;

  /// Map scope toggle label for only the current user's coffees
  ///
  /// In en, this message translates to:
  /// **'My map'**
  String get mapScopeMine;

  /// Map scope toggle label for all users' coffees
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get mapScopeGlobal;

  /// Chip label that lets the AI pick the brew method for the user (as opposed to constraining to a specific method)
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get suggestionMethodAuto;

  /// Empty origin ranking
  ///
  /// In en, this message translates to:
  /// **'No coffees found for this origin'**
  String get noCoffeesFromOrigin;

  /// Delete coffee confirmation message
  ///
  /// In en, this message translates to:
  /// **'Delete this coffee and all its tastings?'**
  String get deleteCoffeeConfirm;

  /// Alert when a similar coffee exists
  ///
  /// In en, this message translates to:
  /// **'You have a similar coffee from {roaster}'**
  String similarCoffeeAlert(String roaster);

  /// View similar coffee button
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewSimilar;

  /// Stats tab label
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTab;

  /// Insights section title
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// Top origins stat label
  ///
  /// In en, this message translates to:
  /// **'Top Origins'**
  String get topOrigins;

  /// Top processing methods stat label
  ///
  /// In en, this message translates to:
  /// **'Top Processing Methods'**
  String get topProcessing;

  /// Flavor profile section title
  ///
  /// In en, this message translates to:
  /// **'Flavor Profile'**
  String get flavorProfile;

  /// Tasting timeline section title
  ///
  /// In en, this message translates to:
  /// **'Tasting Timeline'**
  String get tastingTimeline;

  /// Average score stat label
  ///
  /// In en, this message translates to:
  /// **'Avg Score'**
  String get avgScore;

  /// Total tastings stat label
  ///
  /// In en, this message translates to:
  /// **'Total Tastings'**
  String get totalTastings;

  /// Total coffees stat label
  ///
  /// In en, this message translates to:
  /// **'Total Coffees'**
  String get totalCoffees;

  /// Brew suggestion section title
  ///
  /// In en, this message translates to:
  /// **'Brew Suggestion'**
  String get brewSuggestion;

  /// Get AI suggestion button
  ///
  /// In en, this message translates to:
  /// **'Get AI Suggestion'**
  String get getSuggestion;

  /// Suggested parameters section title
  ///
  /// In en, this message translates to:
  /// **'Suggested Parameters'**
  String get suggestedParams;

  /// Share tasting button
  ///
  /// In en, this message translates to:
  /// **'Share Tasting'**
  String get shareTasting;

  /// About the roaster section title
  ///
  /// In en, this message translates to:
  /// **'About the Roaster'**
  String get aboutRoaster;

  /// About the farm section title
  ///
  /// In en, this message translates to:
  /// **'About the Farm'**
  String get aboutFarm;

  /// Visit website link
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get visitWebsite;

  /// Enrichment loading message
  ///
  /// In en, this message translates to:
  /// **'Looking up info...'**
  String get enriching;

  /// No enrichment info found message
  ///
  /// In en, this message translates to:
  /// **'No info found'**
  String get noInfoFound;

  /// Roaster profile screen title
  ///
  /// In en, this message translates to:
  /// **'Roaster Profile'**
  String get roasterProfile;

  /// Farm profile screen title
  ///
  /// In en, this message translates to:
  /// **'Farm Profile'**
  String get farmProfile;

  /// Coffees from a specific roaster
  ///
  /// In en, this message translates to:
  /// **'Coffees from {roaster}'**
  String coffeesFromRoaster(String roaster);

  /// Coffees from a specific farm
  ///
  /// In en, this message translates to:
  /// **'Coffees from {farm}'**
  String coffeesFromFarm(String farm);

  /// Key people section label
  ///
  /// In en, this message translates to:
  /// **'Key People'**
  String get keyPeople;

  /// Location section label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// Fallback when no description
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescription;

  /// Claim profile button
  ///
  /// In en, this message translates to:
  /// **'Claim this profile'**
  String get claimProfile;

  /// Pending claim status
  ///
  /// In en, this message translates to:
  /// **'Claim pending approval'**
  String get pendingClaim;

  /// Approved claim badge
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get approvedClaim;

  /// Edit entity profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Info'**
  String get editProfileInfo;

  /// Claim form message label
  ///
  /// In en, this message translates to:
  /// **'Why should you manage this profile?'**
  String get claimMessage;

  /// Submit claim button
  ///
  /// In en, this message translates to:
  /// **'Submit Claim'**
  String get submitClaim;

  /// Admin claims screen title
  ///
  /// In en, this message translates to:
  /// **'Pending Claims'**
  String get adminClaims;

  /// Approve claim button
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveClaim;

  /// Reject claim button
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectClaim;

  /// Empty claims message
  ///
  /// In en, this message translates to:
  /// **'No pending claims'**
  String get noPendingClaims;

  /// Claim submitted confirmation
  ///
  /// In en, this message translates to:
  /// **'Claim submitted for review'**
  String get claimSubmitted;

  /// Premium label
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Free plan label
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// Upgrade button
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// Premium features tagline
  ///
  /// In en, this message translates to:
  /// **'Unlock all features'**
  String get premiumFeatures;

  /// Premium price display
  ///
  /// In en, this message translates to:
  /// **'\$1.99/month'**
  String get premiumPrice;

  /// Subscribe button
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// Restore purchases button
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// Premium required title
  ///
  /// In en, this message translates to:
  /// **'Premium Required'**
  String get premiumRequired;

  /// Premium required description
  ///
  /// In en, this message translates to:
  /// **'This feature requires a premium subscription'**
  String get premiumRequiredDesc;

  /// Coffee limit reached message
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the free limit of {max} coffees'**
  String coffeeLimitReached(int max);

  /// Tasting limit reached message
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the free limit of {max} tastings this month'**
  String tastingLimitReached(int max);

  /// Premium feature: unlimited coffees
  ///
  /// In en, this message translates to:
  /// **'Unlimited coffees'**
  String get unlimitedCoffees;

  /// Premium feature: unlimited tastings
  ///
  /// In en, this message translates to:
  /// **'Unlimited tastings'**
  String get unlimitedTastings;

  /// Premium feature: AI
  ///
  /// In en, this message translates to:
  /// **'AI-powered features'**
  String get aiFeatures;

  /// Premium feature: photos
  ///
  /// In en, this message translates to:
  /// **'Photo uploads'**
  String get photoUploads;

  /// Premium feature: share cards
  ///
  /// In en, this message translates to:
  /// **'Share tasting cards'**
  String get shareCards;

  /// Admin label
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Hint text on scan screen
  ///
  /// In en, this message translates to:
  /// **'Position the coffee bag label in the frame'**
  String get scanHint;

  /// Price field label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Lot field label
  ///
  /// In en, this message translates to:
  /// **'Lot'**
  String get lot;

  /// Harvest year field label
  ///
  /// In en, this message translates to:
  /// **'Harvest Year'**
  String get harvestYear;

  /// Freshness label: resting
  ///
  /// In en, this message translates to:
  /// **'Resting'**
  String get resting;

  /// Freshness label: peak
  ///
  /// In en, this message translates to:
  /// **'Peak freshness'**
  String get peakFreshness;

  /// Freshness label: use soon
  ///
  /// In en, this message translates to:
  /// **'Use soon'**
  String get useSoon;

  /// Freshness label: past peak
  ///
  /// In en, this message translates to:
  /// **'Past peak'**
  String get pastPeak;

  /// Days since roast
  ///
  /// In en, this message translates to:
  /// **'{days} days post-roast'**
  String daysPostRoast(int days);

  /// Community rating section title
  ///
  /// In en, this message translates to:
  /// **'Community rating'**
  String get communityRating;

  /// Community rating with count
  ///
  /// In en, this message translates to:
  /// **'{rating} ({count} users)'**
  String communityRatingValue(String rating, int count);

  /// Scan a bag option in add coffee sheet
  ///
  /// In en, this message translates to:
  /// **'Scan a bag'**
  String get scanABag;

  /// Add manually option in add coffee sheet
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManually;

  /// Add coffee bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Add a coffee'**
  String get addCoffeeTitle;

  /// Flavor selector hint text
  ///
  /// In en, this message translates to:
  /// **'Tap to select flavors'**
  String get selectFlavors;

  /// Explore tab label
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTab;

  /// Trending coffees section title
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get exploreTrending;

  /// Recently added coffees section title
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get exploreRecentlyAdded;

  /// Top rated coffees section title
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get exploreTopRated;

  /// New roasters section title
  ///
  /// In en, this message translates to:
  /// **'New Roasters'**
  String get exploreNewRoasters;

  /// Roaster dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Roaster Dashboard'**
  String get roasterDashboard;

  /// Roaster Pro paywall title
  ///
  /// In en, this message translates to:
  /// **'Roaster Pro Required'**
  String get roasterProRequired;

  /// Roaster Pro paywall description
  ///
  /// In en, this message translates to:
  /// **'Access detailed analytics about your coffees'**
  String get roasterProDesc;

  /// Roaster Pro price display
  ///
  /// In en, this message translates to:
  /// **'€9.99/month'**
  String get roasterProPrice;

  /// Recent tastings (30 days) stat label
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get recentTastings30d;

  /// Top coffees by rating section title
  ///
  /// In en, this message translates to:
  /// **'Top Coffees'**
  String get topCoffeesByRating;

  /// Popular coffees from user's country section title
  ///
  /// In en, this message translates to:
  /// **'Popular Near You'**
  String get exploreNearYou;

  /// Country field label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Roaster dashboard Stats tab label
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get dashboardTabStats;

  /// Roaster dashboard Tastings tab label
  ///
  /// In en, this message translates to:
  /// **'Tastings'**
  String get dashboardTabTastings;

  /// Roaster dashboard Posts tab label
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get dashboardTabPosts;

  /// Timeseries period selector — 30 days
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get period30d;

  /// Timeseries period selector — 3 months
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get period3m;

  /// Timeseries period selector — 12 months
  ///
  /// In en, this message translates to:
  /// **'12 months'**
  String get period12m;

  /// Legend label for the tastings line in the chart
  ///
  /// In en, this message translates to:
  /// **'Tastings'**
  String get chartTastingsLabel;

  /// Legend label for the average rating line in the chart
  ///
  /// In en, this message translates to:
  /// **'Avg rating'**
  String get chartRatingLabel;

  /// CSV export button label
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportCsv;

  /// Subject when sharing the CSV export
  ///
  /// In en, this message translates to:
  /// **'Coffeeno roaster data export'**
  String get exportCsvShareText;

  /// Placeholder when a tasting has no free-text notes
  ///
  /// In en, this message translates to:
  /// **'(no written notes)'**
  String get tastingNotesEmpty;

  /// Roaster posts tab header
  ///
  /// In en, this message translates to:
  /// **'Messages to your customers'**
  String get roasterPostsTitle;

  /// Button to compose a new roaster post
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get newPost;

  /// Empty state for the roaster posts list
  ///
  /// In en, this message translates to:
  /// **'You haven\'t published any post yet.'**
  String get noPostsYet;

  /// Countdown shown on a roaster post card
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String postExpiresIn(int days);

  /// Shown when a post has passed its expiry date
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get postExpired;

  /// Compose roaster post screen title
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get composePostTitle;

  /// Compose roaster post — title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get postTitleLabel;

  /// Compose roaster post — body field label
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get postBodyLabel;

  /// Compose roaster post — coffee picker label
  ///
  /// In en, this message translates to:
  /// **'Link to one of your coffees (optional)'**
  String get postLinkCoffeeLabel;

  /// Compose roaster post — CTA label field
  ///
  /// In en, this message translates to:
  /// **'Call-to-action label (optional)'**
  String get postCtaLabelField;

  /// Compose roaster post — CTA URL field
  ///
  /// In en, this message translates to:
  /// **'Call-to-action URL (optional)'**
  String get postCtaUrlField;

  /// Coffee picker option for 'no link'
  ///
  /// In en, this message translates to:
  /// **'No linked coffee'**
  String get postNoLinkedCoffee;

  /// Publish roaster post button
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishPost;

  /// Snackbar after publishing a roaster post
  ///
  /// In en, this message translates to:
  /// **'Post published'**
  String get postPublished;

  /// Dialog title when deleting a roaster post
  ///
  /// In en, this message translates to:
  /// **'Delete this post?'**
  String get deletePostConfirm;

  /// Roaster post card header in the consumer feed
  ///
  /// In en, this message translates to:
  /// **'Message from {roaster}'**
  String feedPostedBy(String roaster);

  /// Subheader on a roaster post that links to a specific coffee
  ///
  /// In en, this message translates to:
  /// **'About {coffee}'**
  String feedAboutCoffee(String coffee);

  /// Confirm dialog when deleting a comment
  ///
  /// In en, this message translates to:
  /// **'Delete this comment?'**
  String get deleteCommentConfirm;

  /// Block user action label
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockUser;

  /// Unblock user action label
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblockUser;

  /// Confirm dialog when blocking a user
  ///
  /// In en, this message translates to:
  /// **'Block this user? You will no longer see their content and they will no longer see yours.'**
  String get blockUserConfirm;

  /// Confirm dialog when unblocking a user
  ///
  /// In en, this message translates to:
  /// **'Unblock this user?'**
  String get unblockUserConfirm;

  /// Blocked users settings entry / screen title
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get blockedUsers;

  /// Empty state for the blocked users list
  ///
  /// In en, this message translates to:
  /// **'You haven\'t blocked anyone.'**
  String get noBlockedUsers;

  /// Validation: empty email
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// Validation: malformed email
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationEmailInvalid;

  /// Validation: empty password
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// Validation: short password
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordTooShort;

  /// Validation: a required field is empty
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String validationFieldRequired(String field);

  /// Validation: empty username
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get validationUsernameRequired;

  /// Validation: short username
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get validationUsernameTooShort;

  /// Validation: invalid username chars
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers, and underscores'**
  String get validationUsernameInvalid;

  /// Auth error: bad credentials
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get authErrorInvalidCredentials;

  /// Auth error: disabled account
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// Auth error: rate limited
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get authErrorTooManyRequests;

  /// Auth error: email already registered
  ///
  /// In en, this message translates to:
  /// **'An account already exists for that email.'**
  String get authErrorEmailInUse;

  /// Auth error: weak password
  ///
  /// In en, this message translates to:
  /// **'That password is too weak.'**
  String get authErrorWeakPassword;

  /// Auth error: fallback
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get authErrorGeneric;

  /// Brew method label
  ///
  /// In en, this message translates to:
  /// **'V60'**
  String get brewMethodV60;

  /// Brew method label
  ///
  /// In en, this message translates to:
  /// **'Espresso'**
  String get brewMethodEspresso;

  /// Brew method label
  ///
  /// In en, this message translates to:
  /// **'AeroPress'**
  String get brewMethodAeropress;

  /// Brew method label
  ///
  /// In en, this message translates to:
  /// **'French Press'**
  String get brewMethodFrenchPress;

  /// Brew method label
  ///
  /// In en, this message translates to:
  /// **'Chemex'**
  String get brewMethodChemex;

  /// Brew method label
  ///
  /// In en, this message translates to:
  /// **'Moka Pot'**
  String get brewMethodMokaPot;

  /// Brew method label
  ///
  /// In en, this message translates to:
  /// **'Cold Brew'**
  String get brewMethodColdBrew;

  /// Brew method label
  ///
  /// In en, this message translates to:
  /// **'Siphon'**
  String get brewMethodSiphon;

  /// Brew method label
  ///
  /// In en, this message translates to:
  /// **'Turkish Coffee'**
  String get brewMethodTurkish;

  /// Brew method label
  ///
  /// In en, this message translates to:
  /// **'Pour Over (Other)'**
  String get brewMethodPourOver;

  /// Brew method label
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get brewMethodOther;

  /// Grind size label
  ///
  /// In en, this message translates to:
  /// **'Extra Fine'**
  String get grindExtraFine;

  /// Grind size label
  ///
  /// In en, this message translates to:
  /// **'Fine'**
  String get grindFine;

  /// Grind size label
  ///
  /// In en, this message translates to:
  /// **'Medium-Fine'**
  String get grindMediumFine;

  /// Grind size label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get grindMedium;

  /// Grind size label
  ///
  /// In en, this message translates to:
  /// **'Medium-Coarse'**
  String get grindMediumCoarse;

  /// Grind size label
  ///
  /// In en, this message translates to:
  /// **'Coarse'**
  String get grindCoarse;

  /// Grind size label
  ///
  /// In en, this message translates to:
  /// **'Extra Coarse'**
  String get grindExtraCoarse;

  /// Processing method label
  ///
  /// In en, this message translates to:
  /// **'Washed'**
  String get processWashed;

  /// Processing method label
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get processNatural;

  /// Processing method label
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get processHoney;

  /// Processing method label
  ///
  /// In en, this message translates to:
  /// **'Anaerobic'**
  String get processAnaerobic;

  /// Processing method label
  ///
  /// In en, this message translates to:
  /// **'Wet Hulled'**
  String get processWetHulled;

  /// Processing method label
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get processExperimental;

  /// Processing method label
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get processOther;

  /// Roast level label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get roastLight;

  /// Roast level label
  ///
  /// In en, this message translates to:
  /// **'Medium-Light'**
  String get roastMediumLight;

  /// Roast level label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get roastMedium;

  /// Roast level label
  ///
  /// In en, this message translates to:
  /// **'Medium-Dark'**
  String get roastMediumDark;

  /// Roast level label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get roastDark;

  /// Flavor family label
  ///
  /// In en, this message translates to:
  /// **'Fruity'**
  String get flavorFruity;

  /// Flavor family label
  ///
  /// In en, this message translates to:
  /// **'Sour/Fermented'**
  String get flavorSourFermented;

  /// Flavor family label
  ///
  /// In en, this message translates to:
  /// **'Green/Vegetative'**
  String get flavorGreenVegetative;

  /// Flavor family label
  ///
  /// In en, this message translates to:
  /// **'Roasted'**
  String get flavorRoasted;

  /// Flavor family label
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get flavorSpices;

  /// Flavor family label
  ///
  /// In en, this message translates to:
  /// **'Nutty/Cocoa'**
  String get flavorNuttyCocoa;

  /// Flavor family label
  ///
  /// In en, this message translates to:
  /// **'Sweet'**
  String get flavorSweet;

  /// Flavor family label
  ///
  /// In en, this message translates to:
  /// **'Floral'**
  String get flavorFloral;

  /// Flavor family label
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get flavorOther;

  /// Generic empty state message
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateGeneric;

  /// Custom flavor note input hint
  ///
  /// In en, this message translates to:
  /// **'Add your own'**
  String get customFlavorHint;

  /// Fallback coffee name when missing
  ///
  /// In en, this message translates to:
  /// **'Unknown Coffee'**
  String get unknownCoffee;

  /// Remove photo action
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// Change photo action
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// Add photo action
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// Short required-field validation message
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// Short invalid-value validation message
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get fieldInvalid;

  /// Abbreviated minutes label on brew time picker
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minutesAbbrev;

  /// Abbreviated seconds label on brew time picker
  ///
  /// In en, this message translates to:
  /// **'Sec'**
  String get secondsAbbrev;

  /// Sort option: newest first
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// Sort option: alphabetical
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortAlphabetical;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Website URL field label
  ///
  /// In en, this message translates to:
  /// **'Website URL'**
  String get websiteUrl;

  /// City field label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// Freshness reminder notification title
  ///
  /// In en, this message translates to:
  /// **'Time to brew!'**
  String get freshnessNotificationTitle;

  /// Freshness reminder body when the roaster is known
  ///
  /// In en, this message translates to:
  /// **'Your {coffee} from {roaster} is leaving peak freshness — brew it soon!'**
  String freshnessNotificationBody(String coffee, String roaster);

  /// Freshness reminder body when the roaster is unknown
  ///
  /// In en, this message translates to:
  /// **'Your {coffee} is leaving peak freshness — brew it soon!'**
  String freshnessNotificationBodyNoRoaster(String coffee);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
