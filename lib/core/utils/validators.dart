import 'package:coffeeno/l10n/app_localizations.dart';

/// Form field validators.
///
/// Each validator takes the active [AppLocalizations] so error messages are
/// localized at the call site (the widget already has `l10n` in scope), keeping
/// all user-facing copy out of this util and inside the ARB files.
abstract final class Validators {
  static String? email(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.validationEmailRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return l10n.validationEmailInvalid;
    return null;
  }

  static String? password(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.validationPasswordRequired;
    if (value.length < 8) return l10n.validationPasswordTooShort;
    return null;
  }

  static String? required(
    String? value,
    AppLocalizations l10n,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validationFieldRequired(fieldName);
    }
    return null;
  }

  static String? username(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.validationUsernameRequired;
    if (value.length < 3) return l10n.validationUsernameTooShort;
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return l10n.validationUsernameInvalid;
    }
    return null;
  }
}
