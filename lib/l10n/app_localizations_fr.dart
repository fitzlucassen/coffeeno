// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Coffeeno';

  @override
  String get feedTab => 'Fil';

  @override
  String get libraryTab => 'Bibliothèque';

  @override
  String get mapTab => 'Carte';

  @override
  String get profileTab => 'Profil';

  @override
  String get welcomeTitle => 'Bienvenue sur Coffeeno';

  @override
  String get welcomeSubtitle =>
      'Découvrez, dégustez et partagez votre aventure café';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get signInWithGoogle => 'Continuer avec Google';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get displayName => 'Nom d\'affichage';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get bio => 'Bio';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get dontHaveAccount => 'Pas encore de compte ?';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ?';

  @override
  String get orContinueWith => 'ou continuer avec';

  @override
  String get scanCoffee => 'Scanner un café';

  @override
  String get addCoffee => 'Ajouter un café';

  @override
  String get addTasting => 'Ajouter une dégustation';

  @override
  String get myCoffees => 'Mes cafés';

  @override
  String get coffeeDetail => 'Détail du café';

  @override
  String get noCoffeesYet => 'Aucun café pour le moment';

  @override
  String get noCoffeesYetSubtitle =>
      'Scannez un sachet ou ajoutez-en un manuellement';

  @override
  String get roaster => 'Torréfacteur';

  @override
  String get coffeeName => 'Nom du café';

  @override
  String get originCountry => 'Pays';

  @override
  String get originRegion => 'Région';

  @override
  String get farmName => 'Ferme';

  @override
  String get farmerName => 'Producteur';

  @override
  String get altitude => 'Altitude';

  @override
  String get variety => 'Variété';

  @override
  String get processingMethod => 'Procédé';

  @override
  String get roastDate => 'Date de torréfaction';

  @override
  String get roastLevel => 'Niveau de torréfaction';

  @override
  String get flavorNotes => 'Notes aromatiques';

  @override
  String get brewMethod => 'Méthode d\'infusion';

  @override
  String get grindSize => 'Mouture';

  @override
  String get dose => 'Dose (g)';

  @override
  String get waterAmount => 'Eau (ml)';

  @override
  String get ratio => 'Ratio';

  @override
  String get brewTime => 'Temps d\'infusion';

  @override
  String get waterTemperature => 'Temp. eau (°C)';

  @override
  String get aroma => 'Arôme';

  @override
  String get flavor => 'Saveur';

  @override
  String get acidity => 'Acidité';

  @override
  String get body => 'Corps';

  @override
  String get sweetness => 'Douceur';

  @override
  String get aftertaste => 'Arrière-goût';

  @override
  String get overallRating => 'Note globale';

  @override
  String get notes => 'Notes';

  @override
  String get tastings => 'Dégustations';

  @override
  String get noTastingsYet => 'Aucune dégustation pour l\'instant.';

  @override
  String get noTastingsYetSubtitle =>
      'Ajoutez une dégustation pour noter ce café';

  @override
  String get followers => 'Abonnés';

  @override
  String get following => 'Abonnements';

  @override
  String get follow => 'Suivre';

  @override
  String get unfollow => 'Ne plus suivre';

  @override
  String get like => 'J\'aime';

  @override
  String get comment => 'Commenter';

  @override
  String get addComment => 'Ajouter un commentaire...';

  @override
  String get leaderboard => 'Classement';

  @override
  String get topRated => 'Mieux notés';

  @override
  String get searchUsers => 'Rechercher des utilisateurs...';

  @override
  String get search => 'Rechercher';

  @override
  String get coffeeOrigins => 'Origines du café';

  @override
  String mostLovedFrom(String country) {
    return 'Les plus appréciés de $country';
  }

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get scanReview => 'Vérifier le scan';

  @override
  String get scanReviewSubtitle =>
      'Vérifiez et modifiez les informations extraites';

  @override
  String get scanning => 'Scan en cours...';

  @override
  String get extractingInfo => 'Extraction des informations...';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get retry => 'Réessayer';

  @override
  String get error => 'Une erreur est survenue';

  @override
  String ratingsCount(int count) {
    return '$count notes';
  }

  @override
  String tastingsCount(int count) {
    return '$count dégustations';
  }

  @override
  String get emptyFeed =>
      'Suivez des amateurs de café pour voir leurs dégustations ici';

  @override
  String get findPeople => 'Trouver des personnes';

  @override
  String get noCommentsYet => 'Aucun commentaire';

  @override
  String get beFirstToComment => 'Soyez le premier à partager vos pensées';

  @override
  String get comments => 'Commentaires';

  @override
  String get couldNotLoadComments => 'Impossible de charger les commentaires';

  @override
  String get noFollowersYet => 'Aucun abonné pour le moment';

  @override
  String get notFollowingAnyone => 'Aucun abonnement pour le moment';

  @override
  String get noRatedCoffeesYet => 'Aucun café noté pour le moment';

  @override
  String get selectCountry =>
      'Sélectionnez un pays pour voir ses meilleurs cafés';

  @override
  String noRatedCoffeesFrom(String country) {
    return 'Aucun café noté de $country pour le moment';
  }

  @override
  String get searchForCoffeeLovers => 'Rechercher des amateurs de café';

  @override
  String noUsersFound(String query) {
    return 'Aucun utilisateur trouvé pour \"$query\"';
  }

  @override
  String get userNotFound => 'Utilisateur introuvable';

  @override
  String get global => 'Mondial';

  @override
  String get byOrigin => 'Par origine';

  @override
  String get noOriginsYet => 'Aucune origine de café à afficher';

  @override
  String get addCoffeesForMap =>
      'Ajoutez des cafés avec une origine pour les voir sur la carte';

  @override
  String get noCoffeesFromOrigin => 'Aucun café trouvé pour cette origine';

  @override
  String get deleteCoffeeConfirm =>
      'Supprimer ce café et toutes ses dégustations ?';

  @override
  String similarCoffeeAlert(String roaster) {
    return 'Vous avez un café similaire de $roaster';
  }

  @override
  String get viewSimilar => 'Voir';

  @override
  String get statsTab => 'Stats';

  @override
  String get insights => 'Analyses';

  @override
  String get topOrigins => 'Origines favorites';

  @override
  String get topProcessing => 'Procédés favoris';

  @override
  String get flavorProfile => 'Profil aromatique';

  @override
  String get tastingTimeline => 'Historique';

  @override
  String get avgScore => 'Note moy.';

  @override
  String get totalTastings => 'Total dégustations';

  @override
  String get totalCoffees => 'Total cafés';

  @override
  String get brewSuggestion => 'Suggestion d\'infusion';

  @override
  String get getSuggestion => 'Suggestion IA';

  @override
  String get suggestedParams => 'Paramètres suggérés';

  @override
  String get shareTasting => 'Partager la dégustation';

  @override
  String get aboutRoaster => 'À propos du torréfacteur';

  @override
  String get aboutFarm => 'À propos de la ferme';

  @override
  String get visitWebsite => 'Voir le site';

  @override
  String get enriching => 'Recherche d\'infos...';

  @override
  String get noInfoFound => 'Aucune info trouvée';

  @override
  String get roasterProfile => 'Profil torréfacteur';

  @override
  String get farmProfile => 'Profil ferme';

  @override
  String coffeesFromRoaster(String roaster) {
    return 'Cafés de $roaster';
  }

  @override
  String coffeesFromFarm(String farm) {
    return 'Cafés de $farm';
  }

  @override
  String get keyPeople => 'Personnes clés';

  @override
  String get locationLabel => 'Localisation';

  @override
  String get noDescription => 'Aucune description disponible';

  @override
  String get claimProfile => 'Revendiquer ce profil';

  @override
  String get pendingClaim => 'Revendication en attente';

  @override
  String get approvedClaim => 'Vérifié';

  @override
  String get editProfileInfo => 'Modifier les infos';

  @override
  String get claimMessage => 'Pourquoi devriez-vous gérer ce profil ?';

  @override
  String get submitClaim => 'Soumettre';

  @override
  String get adminClaims => 'Revendications en attente';

  @override
  String get approveClaim => 'Approuver';

  @override
  String get rejectClaim => 'Rejeter';

  @override
  String get noPendingClaims => 'Aucune revendication en attente';

  @override
  String get claimSubmitted => 'Revendication soumise pour vérification';

  @override
  String get premium => 'Premium';

  @override
  String get freePlan => 'Offre gratuite';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get premiumFeatures => 'Débloquer toutes les fonctionnalités';

  @override
  String get premiumPrice => '1,99 \$/mois';

  @override
  String get subscribe => 'S\'abonner';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get premiumRequired => 'Premium requis';

  @override
  String get premiumRequiredDesc =>
      'Cette fonctionnalité nécessite un abonnement premium';

  @override
  String coffeeLimitReached(int max) {
    return 'Vous avez atteint la limite gratuite de $max cafés';
  }

  @override
  String tastingLimitReached(int max) {
    return 'Vous avez atteint la limite gratuite de $max dégustations ce mois-ci';
  }

  @override
  String get unlimitedCoffees => 'Cafés illimités';

  @override
  String get unlimitedTastings => 'Dégustations illimitées';

  @override
  String get aiFeatures => 'Fonctionnalités IA';

  @override
  String get photoUploads => 'Upload de photos';

  @override
  String get shareCards => 'Cartes de dégustation';

  @override
  String get admin => 'Admin';

  @override
  String get scanHint => 'Positionnez l\'étiquette du sachet dans le cadre';

  @override
  String get price => 'Prix';

  @override
  String get lot => 'Lot';

  @override
  String get harvestYear => 'Année de récolte';

  @override
  String get resting => 'Repos';

  @override
  String get peakFreshness => 'Fraîcheur optimale';

  @override
  String get useSoon => 'À consommer bientôt';

  @override
  String get pastPeak => 'Passé';

  @override
  String daysPostRoast(int days) {
    return '$days jours après torréfaction';
  }

  @override
  String get communityRating => 'Note communautaire';

  @override
  String communityRatingValue(String rating, int count) {
    return '$rating ($count utilisateurs)';
  }

  @override
  String get scanABag => 'Scanner un sachet';

  @override
  String get addManually => 'Ajouter manuellement';

  @override
  String get addCoffeeTitle => 'Ajouter un café';

  @override
  String get selectFlavors => 'Appuyez pour sélectionner';

  @override
  String get exploreTab => 'Explorer';

  @override
  String get exploreTrending => 'Tendances';

  @override
  String get exploreRecentlyAdded => 'Ajoutés récemment';

  @override
  String get exploreTopRated => 'Mieux notés';

  @override
  String get exploreNewRoasters => 'Nouveaux torréfacteurs';

  @override
  String get roasterDashboard => 'Tableau de bord';

  @override
  String get roasterProRequired => 'Roaster Pro requis';

  @override
  String get roasterProDesc => 'Accédez aux analyses détaillées de vos cafés';

  @override
  String get roasterProPrice => '9,99 €/mois';

  @override
  String get recentTastings30d => '30 derniers jours';

  @override
  String get topCoffeesByRating => 'Meilleurs cafés';

  @override
  String get exploreNearYou => 'Populaire près de vous';

  @override
  String get country => 'Pays';

  @override
  String get dashboardTabStats => 'Stats';

  @override
  String get dashboardTabTastings => 'Dégustations';

  @override
  String get dashboardTabPosts => 'Publications';

  @override
  String get period30d => '30 jours';

  @override
  String get period3m => '3 mois';

  @override
  String get period12m => '12 mois';

  @override
  String get chartTastingsLabel => 'Dégustations';

  @override
  String get chartRatingLabel => 'Note moyenne';

  @override
  String get exportCsv => 'Exporter en CSV';

  @override
  String get exportCsvShareText => 'Export des données Coffeeno';

  @override
  String get tastingNotesEmpty => '(aucun commentaire écrit)';

  @override
  String get roasterPostsTitle => 'Messages à vos clients';

  @override
  String get newPost => 'Nouvelle publication';

  @override
  String get noPostsYet => 'Vous n\'avez encore publié aucun message.';

  @override
  String postExpiresIn(int days) {
    return 'Expire dans $days jours';
  }

  @override
  String get postExpired => 'Expiré';

  @override
  String get composePostTitle => 'Écrire un message';

  @override
  String get postTitleLabel => 'Titre';

  @override
  String get postBodyLabel => 'Message';

  @override
  String get postLinkCoffeeLabel => 'Lier à un de vos cafés (optionnel)';

  @override
  String get postCtaLabelField => 'Libellé du bouton (optionnel)';

  @override
  String get postCtaUrlField => 'Lien du bouton (optionnel)';

  @override
  String get postNoLinkedCoffee => 'Aucun café lié';

  @override
  String get publishPost => 'Publier';

  @override
  String get postPublished => 'Message publié';

  @override
  String get deletePostConfirm => 'Supprimer cette publication ?';

  @override
  String feedPostedBy(String roaster) {
    return 'Message de $roaster';
  }

  @override
  String feedAboutCoffee(String coffee) {
    return 'À propos de $coffee';
  }

  @override
  String get deleteCommentConfirm => 'Supprimer ce commentaire ?';

  @override
  String get blockUser => 'Bloquer';

  @override
  String get unblockUser => 'Débloquer';

  @override
  String get blockUserConfirm =>
      'Bloquer cet utilisateur ? Vous ne verrez plus son contenu et il ne verra plus le vôtre.';

  @override
  String get unblockUserConfirm => 'Débloquer cet utilisateur ?';

  @override
  String get blockedUsers => 'Utilisateurs bloqués';

  @override
  String get noBlockedUsers => 'Vous n\'avez bloqué personne.';
}
