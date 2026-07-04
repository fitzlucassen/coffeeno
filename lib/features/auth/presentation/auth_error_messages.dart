import 'package:coffeeno/l10n/app_localizations.dart';

/// Maps a [FirebaseAuthException] `code` to a localized, user-facing message.
///
/// Shared by the sign-in and sign-up screens so the copy (and the set of
/// handled codes) stays in one place instead of being copy-pasted per screen.
String authErrorMessage(String code, AppLocalizations l10n) {
  switch (code) {
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return l10n.authErrorInvalidCredentials;
    case 'user-disabled':
      return l10n.authErrorUserDisabled;
    case 'too-many-requests':
      return l10n.authErrorTooManyRequests;
    case 'email-already-in-use':
      return l10n.authErrorEmailInUse;
    case 'weak-password':
      return l10n.authErrorWeakPassword;
    default:
      return l10n.authErrorGeneric;
  }
}
