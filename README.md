# 🌱 Sprout

> **Watch your money grow.** A personal-budgeting app for young people — gamified, encouraging, never shaming.

Sprout is a Flutter mobile app (iOS + Android) backed by a Python REST API. A friendly sprout mascot grows as you hit goals, slumps on red days, and fist-pumps on milestones. The app helps you track spending, set goals, build streaks, and (optionally) share a budget with a partner.

---

## Tech stack

- **Flutter** (stable, 3.41.x) / Dart 3.7+
- **State management:** `provider` (a single `ChangeNotifier` — `BudgetController`)
- **Networking:** `http` against a REST backend, configured via `.env`
- **Charts:** `fl_chart`
- **Local storage:** `shared_preferences` (auth token only)
- **Localization:** English + Bulgarian (`flutter_localizations` + ARB files)

The app talks to the backend through a single `BudgetApi` interface. The live implementation is `HttpBudgetApi`; there is no longer a mock — the app always speaks to the real server.

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel) — run `flutter doctor` and resolve any issues
- **iOS:** Xcode + CocoaPods (`sudo gem install cocoapods`)
- **Android:** Android Studio + an SDK / emulator
- A running instance of the Sprout backend (see [Backend](#backend))

---

## Setup

```sh
# 1. Install dependencies
flutter pub get

# 2. Configure the backend URL
#    Edit .env and set BACKEND_URL to your running backend.
#    (.env is git-ignored — each machine sets its own.)
```

`.env` lives at the project root and currently contains a placeholder:

```dotenv
BACKEND_URL=https://your-backend-host/v1
```

> ⚠️ **The app reads `BACKEND_URL` at launch and will fail to reach the server until you set a real URL.** Use no trailing slash (e.g. `https://api.sprout.app/v1`).

`.env` is bundled as a Flutter asset (declared in `pubspec.yaml`) and loaded in `main.dart` via `flutter_dotenv`.

---

## Running the app

```sh
# List available devices
flutter devices

# Run on a specific device
flutter run -d "iPhone 17 Pro"      # iOS simulator
flutter run -d android              # Android emulator/device
```

While running: `r` = hot reload · `R` = hot restart · `q` = quit.

First launch with no saved session lands on the **auth screen** (log in / sign up). After signup you'll go through onboarding, then into the main app, which is seeded server-side with default categories and goals.

---

## Project structure

```
lib/
├── main.dart                 loads .env, builds HttpBudgetApi, runApp
├── app.dart                  MaterialApp + ChangeNotifierProvider + theme
├── theme.dart                colors, gradients, shapes
├── data/
│   ├── budget_api.dart       abstract BudgetApi + exceptions (Auth/Partnership/Api)
│   └── http_budget_api.dart  REST client (the live backend)
├── models/                   Transaction, Category, Goal, User, Insight, Partnership…
├── state/
│   └── budget_controller.dart  ChangeNotifier owning all app data
├── screens/                  splash, auth, onboarding, home, stats, goals, you, together…
├── widgets/                  reusable UI: cards, mascot, heatmap, nudges, sheets…
├── l10n/                     app_en.arb / app_bg.arb + generated localizations
└── utils/                    formatters, helpers

android/  ios/                native shells (other platforms removed — mobile only)
test/                         unit tests (models, formatters, l10n drift)
```

### How data flows

1. Widgets read state with `context.watch<BudgetController>()` and trigger actions with `context.read<BudgetController>()`.
2. `BudgetController` calls the `BudgetApi` for every read/write, updates its in-memory lists, and calls `notifyListeners()`.
3. `HttpBudgetApi` makes the REST call, attaching `Authorization: Bearer <token>` (stored in `shared_preferences` under `auth_token`) to every authenticated request.

All persisted data goes through `BudgetApi` — widgets never touch `shared_preferences` directly.

---

## Backend

Every authenticated request carries `Authorization: Bearer <token>`; the backend issues a JWT on signup/login. Requests and responses are JSON with ISO-8601 dates.

The REST contract the client expects — every endpoint, its request/response shape, and the error codes — is defined by the `BudgetApi` interface in [`lib/data/budget_api.dart`](lib/data/budget_api.dart) and implemented by `HttpBudgetApi`. Default categories and goals are seeded server-side on account creation.

Errors come back as `{ "error": { "code": "...", "message": "..." } }`. The client maps the locale-agnostic `code` to:
- `AuthException` (e.g. `accountExists`, `noMatch`, `passwordTooShort`),
- `PartnershipException` (e.g. `alreadyLinked`, `inviteExpired`),
- `ApiException` (everything else: `unauthorized`, `notFound`, `invalidRequest`).

---

## Localization

Strings live in `lib/l10n/app_en.arb` and `lib/l10n/app_bg.arb`. After editing them, regenerate the typed accessors:

```sh
flutter gen-l10n
```

A test (`test/l10n/arb_drift_test.dart`) guards against the ARB files and generated code drifting apart.

---

## Quality checks

```sh
flutter analyze     # must report: No issues found!
flutter test        # unit tests
```

Keep `flutter analyze` at zero issues before committing.

---

## Common commands

| Command | What it does |
|---|---|
| `flutter pub get` | Install/refresh dependencies |
| `flutter run -d "iPhone 17 Pro"` | Run on a device/simulator |
| `flutter gen-l10n` | Regenerate localizations from ARB files |
| `flutter analyze` | Static analysis (lints) |
| `flutter test` | Run the test suite |
| `flutter create --platforms=web .` | Re-add a platform folder if ever needed |
