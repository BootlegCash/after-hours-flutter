# After Hours Ranked Flutter

After Hours Ranked Flutter is the mobile frontend for **After Hours Ranked**, a social drinking-stats app backed by the Django API in [`BootlegCash/rank-v4`](https://github.com/BootlegCash/rank-v4).

The app lets users log drinks, track XP, climb monthly/yearly/lifetime ranks, view leaderboards, manage friends, post to a feed, and review safety/policy information from a Flutter mobile interface.

> Responsible-use note: this app is intended for adults of legal drinking age. It should be treated as a social stats/game layer, not encouragement to drink excessively or unsafely.

## Backend connection

The Flutter app currently talks to the production backend at:

```text
https://ranked-0xtx.onrender.com
```

Main API root:

```text
https://ranked-0xtx.onrender.com/accounts/api
```

The primary service implementation is in:

```text
lib/services/api_service.dart
```

There are also smaller service helpers under `lib/core/`. If API behavior changes, keep those files aligned with `ApiService` and the Django routes in the backend repo.

## Features

- Login and registration
- Password reset flow
- Profile page with XP and rank progress
- Monthly, yearly, and lifetime rank tracking
- Drink logging
- Calendar and daily drink history
- Leaderboard
- Friends list, friend search, friend requests, and friend profiles
- Social feed with posts and likes
- Rank history
- Safety, policies, contact, feedback, and app information pages
- Custom app icon assets for Android and iOS
- iOS TestFlight workflow configuration

## Tech stack

- Flutter / Dart
- `http` for API requests
- `shared_preferences` for local token storage
- `provider` for app state patterns
- `url_launcher` for external links
- `package_info_plus` for app/version metadata
- `flutter_launcher_icons` for app icon generation

## Project structure

```text
.
├── android/                 # Android project files
├── ios/                     # iOS project files, Fastlane, TestFlight workflow support
├── assets/icon/             # App icon source asset
├── lib/
│   ├── core/                # Smaller API/client helper services
│   ├── screens/             # App screens and page UI
│   ├── services/            # Main API service
│   ├── widgets/             # Reusable UI widgets
│   └── main.dart            # App entrypoint and route setup
├── pubspec.yaml             # Flutter dependencies and asset config
└── analysis_options.yaml    # Dart analyzer/lint configuration
```

## Requirements

- Flutter SDK 3.x
- Dart SDK compatible with `>=3.0.0 <4.0.0`
- Android Studio or Xcode for device builds
- A running backend, usually the deployed Render backend above

Check your local Flutter setup:

```bash
flutter doctor
```

## Local setup

Clone the repo:

```bash
git clone https://github.com/BootlegCash/after-hours-flutter.git
cd after-hours-flutter
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run on a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

## Useful commands

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Format Dart files:

```bash
dart format lib test
```

Regenerate launcher icons after changing `assets/icon/icon.png`:

```bash
flutter pub run flutter_launcher_icons
```

Build Android release APK:

```bash
flutter build apk --release
```

Build iOS release:

```bash
flutter build ios --release
```

## Main routes

The app defines its main navigation in `lib/main.dart`, including:

| Route | Purpose |
| --- | --- |
| `/login` | Sign in |
| `/register` | Create account |
| `/profile` | User profile and rank progress |
| `/feed` | Social feed |
| `/friends` | Friends hub |
| `/log-drink` | Drink logging |
| `/ranks` | Leaderboard |
| `/settings` | App/user settings |
| `/calendar` | Drink/rank calendar |
| `/rank-history` | Historical rank snapshots |
| `/reset-password` | Password reset |
| `/drinking-safely` | Safety information |
| `/policies` | Policies |
| `/about-app` | App information |
| `/feedback` | Send feedback |
| `/contact` | Contact page |

Friend profile routes are generated dynamically under:

```text
/friends/profile/<username>
```

## API notes

Most authenticated app calls are made through `ApiService`:

- `POST /accounts/api/token/`
- `POST /accounts/api/register/`
- `GET /accounts/api/profile/`
- `POST /accounts/api/log_drink/`
- `GET /accounts/api/calendar/<year>/<month>/`
- `GET /accounts/api/leaderboard/`
- `GET /accounts/api/feed/`
- `POST /accounts/api/feed/create/`
- `POST /accounts/api/posts/<post_id>/like/`
- `GET /accounts/api/friends/`
- `GET /accounts/api/friends/search/`
- `POST /accounts/api/friends/request/send/`
- `POST /accounts/api/friends/request/<id>/accept/`
- `POST /accounts/api/friends/request/<id>/reject/`
- `POST /accounts/api/friends/remove/`

When changing backend routes in `rank-v4`, update the Flutter service methods at the same time so the app and API stay in sync.

## Release notes

The current app version is defined in `pubspec.yaml`:

```yaml
version: 1.0.0+8
```

Update this before publishing a new mobile build.

The repo also includes:

```text
.github/workflows/ios_testflight.yml
ios/fastlane/
```

Those files support iOS/TestFlight release automation.

## Development notes

- Avoid committing generated build outputs.
- Keep `pubspec.lock` committed for reproducible app builds.
- Keep backend URL changes centralized in the API service layer.
- If local-only IDE or assistant settings change, avoid mixing them into app feature commits.

## License

No license is currently specified. Add one before distributing the project or accepting outside contributions.
