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

  /// Empty tastings message
  ///
  /// In en, this message translates to:
  /// **'No tastings yet'**
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
