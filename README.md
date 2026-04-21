# Coffeeno

Coffee discovery, scanning, and tasting journal with social features. Built with Flutter + Firebase.

## Tech Stack

- **Flutter** 3.41+ / Dart 3.11+
- **Firebase**: Auth, Firestore, Cloud Storage
- **AI**: Google ML Kit (OCR) + Gemini 2.0 Flash (structured extraction + brew suggestions)
- **State**: Riverpod
- **Routing**: GoRouter
- **i18n**: Flutter gen_l10n (EN + FR)

## Features

### Free Tier
- Add up to 10 coffees manually
- Up to 3 tastings per month
- Social feed: follow users, like/comment on tastings
- Leaderboard (global + by origin)
- Coffee origin world map
- Personal stats & insights

### Premium ($1.99/mo)
- Unlimited coffees and tastings
- Scan coffee bags (OCR + Gemini extraction)
- AI brew suggestions
- Photo uploads
- Share tasting cards
- Roaster/farm enrichment via Gemini

### Entity System
- **Roasters** and **Farms** are first-class Firestore entities with profiles (description, website, key people, photos)
- Created automatically during AI enrichment or manually by users
- Deduplicated by name before calling Gemini
- Old coffees without entity links fall back to inline fields

### Roles & Claims
- **user** (default): standard access
- **roaster** / **farmer**: granted after claiming and admin approval of an entity profile
- **admin**: can approve/reject claims, edit any roaster/farm profile

## Project Structure

```
lib/
  core/              # Theme, router, constants, shared widgets
  features/
    auth/            # Firebase Auth, user model (role, premium fields)
    scanner/         # Camera + OCR + Gemini extraction pipeline
    coffee/          # Coffee CRUD, enrichment service, detail screen
    tasting/         # Tasting journal, brew suggestion, share cards
    feed/            # Social activity feed (written by Cloud Functions)
    social/          # Follow system, leaderboard, user profiles, search
    map/             # Coffee origin world map + origin detail
    stats/           # Personal stats & insights
    roaster/         # Roaster entity: model, repository, profile screen
    farm/            # Farm entity: model, repository, profile screen
    admin/           # Claims system: model, repository, admin screen
    subscription/    # Premium status, paywall, gate widgets
  l10n/              # Generated localization files
```

## Firestore Collections

| Collection | Purpose |
|---|---|
| `users/{uid}` | User profile, role, premium status. Subcollections: `followers`, `following` |
| `coffees/{id}` | Coffee entries. Fields: `uid`, `roasterId?`, `farmId?`, inline fields for backward compat |
| `tastings/{id}` | Tasting entries. Subcollections: `likes`, `comments` |
| `feed/{uid}/items/{id}` | Activity feed (read-only, written by Cloud Functions) |
| `roasters/{id}` | Roaster profiles. Fields: `name`, `nameLower`, `description`, `url`, `photoUrl`, `country`, `city`, `keyPeople`, `claimedBy?`, `claimStatus?`, `source` |
| `farms/{id}` | Farm profiles. Fields: `name`, `nameLower`, `description`, `url`, `photoUrl`, `country`, `region`, `farmerName`, `altitude`, `claimedBy?`, `claimStatus?`, `source` |
| `claims/{id}` | Profile claims. Fields: `userId`, `entityType`, `entityId`, `entityName`, `status`, `message?` |
| `leaderboard/{id}` | Aggregated leaderboard (read-only, written by Cloud Functions) |

## Firestore Security Rules

Defined in `firebase/firestore.rules`:

- All reads require authentication
- Users can only write their own data
- Coffees/tastings: owner-only update/delete
- Roasters/farms: update allowed for `claimedBy` user or admin (checked via `get()` on user doc)
- Claims: create by owner, read by owner or admin, update by admin only
- Feed and leaderboard: read-only (Cloud Functions write)

## Firestore Indexes

Defined in `firebase/firestore.indexes.json`. Required composite indexes:

- `coffees`: `uid + createdAt`, `originCountry + avgRating`, `roasterId + createdAt`, `farmId + createdAt`
- `tastings`: `userId + createdAt`, `coffeeId + createdAt`, `userId + tastingDate`
- `claims`: `status + createdAt`, `userId + createdAt`

## Storage Rules

Defined in `firebase/storage.rules`:

- Path: `users/{uid}/**`
- Read: any authenticated user
- Write: owner only, max 5MB, images only

## Firebase Console Setup

1. **Authentication**: Enable Email/Password and Google sign-in providers
2. **Firestore**: Create the database. Deploy rules: `firebase deploy --only firestore:rules`
3. **Firestore Indexes**: Deploy indexes: `firebase deploy --only firestore:indexes`
4. **Cloud Storage**: Create default bucket. Deploy rules: `firebase deploy --only storage`
5. **Cloud Functions** (separate repo/deploy): Required for feed fanout and leaderboard aggregation

### Collections to create manually

None. All collections are created automatically on first write from the app.

### User roles

To make a user admin, set `role: 'admin'` on their document in the `users` collection via the Firebase Console.

## Local Development

### Prerequisites

- Flutter SDK 3.41+
- Firebase CLI (`npm install -g firebase-tools`)
- A Firebase project with Auth, Firestore, Storage enabled
- A Gemini API key (for AI features)

### Setup

```bash
# Clone and install dependencies
git clone <repo-url>
cd coffeeno
flutter pub get

# Generate localization files
flutter gen-l10n

# Configure Firebase (generates firebase_options.dart)
flutterfire configure

# Run the app
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

### Commands

```bash
flutter analyze          # Static analysis
flutter test             # Run tests
dart format lib/ test/   # Format code
flutter gen-l10n         # Regenerate l10n
```

### Environment Variables

| Variable | Required | Purpose |
|---|---|---|
| `GEMINI_API_KEY` | For AI features | Passed via `--dart-define`. Enables scan extraction, enrichment, brew suggestions |

## Payment (not yet wired)

The premium flag is read from `users/{uid}.premium` (boolean) in Firestore. The paywall screen and gate widgets exist but the actual purchase flow (RevenueCat or direct StoreKit/Billing) is not connected yet. To test premium locally, set `premium: true` on your user doc in the Firebase Console.

## Fonts

Plus Jakarta Sans, bundled in `assets/fonts/`. Weights: 400, 500, 600, 700.
