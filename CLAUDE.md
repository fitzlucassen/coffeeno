# Coffeeno

A modern coffee discovery, scanning, and tasting journal app with social features.

## Tech Stack

- **Framework**: Flutter 3.41+ (Dart 3.11+)
- **Backend**: Firebase (Auth, Firestore, Cloud Storage)
- **AI**: Google ML Kit (OCR) + Gemini 2.0 Flash (structured extraction)
- **State Management**: Riverpod
- **Routing**: GoRouter
- **i18n**: Flutter gen_l10n (ARB files in assets/l10n/)

## Project Structure

Feature-first architecture with clean data/domain/presentation separation:

```
lib/
├── core/           # Theme, router, constants, shared widgets, utils
├── features/
│   ├── auth/       # Authentication & user management
│   ├── scanner/    # Coffee bag scanning (OCR + AI)
│   ├── coffee/     # Coffee library & CRUD
│   ├── tasting/    # Tasting journal
│   ├── feed/       # Social activity feed
│   ├── social/     # Follow system, leaderboard, user profiles
│   └── map/        # Coffee origin world map
└── l10n/           # Generated localization files
```

## Commands

```bash
# Run the app (add flutter to PATH first)
export PATH="$PATH:/c/Users/ThibaultDulon/Documents/perso/flutter/bin"
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format lib/ test/

# Generate localization files
flutter gen-l10n

# Generate Riverpod code (if using riverpod_generator)
dart run build_runner build --delete-conflicting-outputs
```

## Key Conventions

- All user-facing strings must use i18n (AppLocalizations)
- Screens use ConsumerWidget or ConsumerStatefulWidget (Riverpod)
- Navigation via GoRouter with named routes (AppRoutes constants)
- Models include fromFirestore/toFirestore factory methods
- Font: Plus Jakarta Sans (assets/fonts/)
- Design: warm cream/espresso/sage/terracotta palette, 16px card radius

## Firebase

- Firestore collections: users, coffees, tastings, feed
- Storage path: users/{uid}/ for uploads
- Security rules in firebase/firestore.rules
- Gemini API key passed via --dart-define=GEMINI_API_KEY=xxx
