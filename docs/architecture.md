# Sprout — Technical Architecture & Specification

> Reference document for writing user-facing technical documentation. Describes the app structure, backend contract, data model, state management, UI surfaces, and conventions as they exist in the current code.

---

## 1. Product overview

**Sprout** is a personal-budgeting mobile app for young people. Tone is warm and encouraging, never shaming. Core jobs-to-be-done:

- Track day-to-day spending and stay under a monthly budget.
- Set savings goals and watch them grow (with a mascot, milestones, confetti).
- Build daily logging habits via streaks, no-spend days, and a cooldown timer.
- Surface gentle insights ("latte factor", mood patterns, weekly recap).
- **Phase 9 — Partner Plan:** link 1:1 with another user to plan shared money (a home, a car, kids' activities, a holiday) **without giving up personal financial privacy**.

Target platforms: **iOS + Android only** (mobile). Web/desktop platform folders are not part of the supported build.

---

## 2. Tech stack

| Layer | Choice |
|---|---|
| UI / runtime | Flutter (stable, 3.41.x) / Dart 3.7+ |
| State management | `provider` ^6.1.2 — a single `ChangeNotifier` (`BudgetController`) |
| Networking | `http` ^1.2.0 against a REST backend |
| Charts | `fl_chart` ^0.70.2 |
| Local storage | `shared_preferences` ^2.3.0 — **auth token only** |
| Config | `flutter_dotenv` ^5.1.0 — `BACKEND_URL` loaded at launch |
| Localization | `flutter_localizations` + ARB files (English + Bulgarian) |
| Date/number formatting | `intl` ^0.20.2 |
| Lints | `flutter_lints` ^5.0.0 — must stay at **zero issues** |

Backend is a separate Python REST service (out of scope for this doc; the contract it must implement is defined here).

---

## 3. Project layout

```
lib/
├── main.dart                 entrypoint — loads .env, builds HttpBudgetApi, runApp
├── app.dart                  MaterialApp + ChangeNotifierProvider + AuthGate
├── theme.dart                Sprout brand colors, gradients, shapes
├── data/
│   ├── budget_api.dart       abstract BudgetApi + exceptions (Auth/Partnership/Api)
│   └── http_budget_api.dart  live REST client (the only implementation)
├── models/                   pure-Dart data classes with toJson/fromJson
│   ├── user.dart
│   ├── transaction.dart
│   ├── category.dart
│   ├── goal.dart             (also defines GoalBoost)
│   ├── partnership.dart      (Partnership, PartnerSummary, PendingInvite, enums)
│   ├── insight.dart
│   ├── achievement.dart
│   └── currency.dart
├── state/
│   └── budget_controller.dart  ChangeNotifier — owns all in-memory app data
├── screens/                  one folder per route surface
│   ├── splash/   auth/   onboarding/
│   ├── home/   stats/   goals/   together/   you/
│   ├── add_transaction/  category_detail/
│   └── root_shell.dart    5-tab bottom-nav scaffold
├── widgets/                  reusable UI: cards, sheets, mascot, charts, banners
├── l10n/                     app_en.arb / app_bg.arb + generated localizations
├── utils/                    formatters, helpers
└── CategoryPage/             (legacy category subtree — being phased into screens/)

android/  ios/                native shells
test/                         unit tests (models, formatters, l10n drift)
```

> Other platform folders (`linux/`, `macos/`, `windows/`) exist in the working tree but are not part of the supported mobile build.

---

## 4. Runtime startup & routing

### 4.1 Bootstrap sequence

`lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final api = HttpBudgetApi(baseUrl: dotenv.env['BACKEND_URL']!);
  runApp(FinanceApp(api: api));
}
```

- `.env` is bundled as a Flutter asset (declared in `pubspec.yaml`). It must contain `BACKEND_URL=https://host/v1` (no trailing slash). The file is git-ignored — each machine sets its own.
- The `HttpBudgetApi` is injected into `FinanceApp`, which wraps the tree in a `ChangeNotifierProvider<BudgetController>` and immediately calls `BudgetController.bootstrap()`.

### 4.2 Auth gate (`lib/app.dart`)

A single `AuthGate` widget reads `BudgetController.authStatus` and selects a top-level screen:

| `AuthStatus` | Surface |
|---|---|
| `booting` | `SplashScreen` |
| `signedOut` | `AuthScreen` (login / signup) |
| `needsOnboarding` | `OnboardingFlow` |
| `ready` | `RootShell` (the 5-tab app) |

Transitions use a 250 ms `FadeTransition` keyed on the status enum.

### 4.3 Main shell (`lib/screens/root_shell.dart`)

`RootShell` is a `StatefulWidget` holding a single `_index` for the bottom-nav tab. Tabs (in order):

| Index | Screen | Tab name |
|---|---|---|
| 0 | `HomeScreen` | Home |
| 1 | `StatsScreen` | Stats |
| 2 | `GoalsScreen` | Goals |
| 3 | `TogetherScreen` | Together (Partner Plan) |
| 4 | `YouScreen` | You |

`RootShell.goToTab(context, kTogetherTabIndex)` is exposed so promo widgets can jump to a sibling tab (e.g. Home → Together).

Loading state is rendered as a centered `CircularProgressIndicator` swapped via `AnimatedSwitcher`.

---

## 5. Data layer (`lib/data/`)

### 5.1 `BudgetApi` — the contract

`lib/data/budget_api.dart` defines an **abstract class** that is the **single source of truth for the REST contract**. Every screen and the `BudgetController` depend on this interface, never on the HTTP client directly. The live implementation is `HttpBudgetApi`. There is no mock — the app always speaks to the real backend.

Method groups (signatures live in [`lib/data/budget_api.dart`](../lib/data/budget_api.dart)):

| Group | Methods |
|---|---|
| **Auth** | `signup`, `login`, `logout` |
| **User** | `getMe`, `updateMe`, `completeOnboarding` |
| **Transactions** | `getTransactions`, `createTransaction`, `updateTransaction`, `deleteTransaction`, `ensureRecurringTransactions` |
| **Categories** | `getCategories`, `createCategory`, `updateCategory`, `deleteCategory` |
| **Goals** | `getGoals`, `createGoal`, `updateGoal`, `deleteGoal`, `boostGoal` |
| **Insights & streak** | `getInsights`, `getStreak` |
| **Partnership (Phase 9)** | `invitePartner`, `getPendingInvite`, `acceptPartnership`, `declinePartnership`, `unlinkPartnership`, `getPartnerSummary`, `getPartner`, `depositToSharedPot` |

Auxiliary value objects:

- `AuthSession { String token; User user; }` — returned by signup/login.
- `StreakInfo { int current; int longest; DateTime? lastLogDate; }` — returned by `getStreak`.

### 5.2 `HttpBudgetApi` — the live client

`lib/data/http_budget_api.dart` is the only `BudgetApi` implementation. Key behaviors:

- **Bearer auth.** The JWT is stored in `shared_preferences` under the key `auth_token`. It is attached as `Authorization: Bearer <token>` to every request **except** paths starting with `/auth/`.
- **Transport helpers.** Internal `_get/_post/_put/_patch/_delete` wrap `http.Client`, set `Content-Type: application/json`, and decode the response.
- **JSON-only.** Requests and responses are JSON; `DateTime` is ISO-8601 (`toIso8601String()` / `DateTime.parse`).
- **Token lifecycle.** `signup` / `login` save the token via `_setToken`; `logout` calls `POST /auth/logout` and then clears the token.

### 5.3 Error mapping

Backend errors are returned as:

```json
{ "error": { "code": "passwordTooShort", "message": "…" } }
```

`HttpBudgetApi._handle` reads `error.code` and throws one of:

| Exception | Codes (locale-agnostic) |
|---|---|
| `AuthException(AuthError)` | `nameRequired`, `emailLooksOff`, `passwordTooShort`, `accountExists`, `noMatch` |
| `PartnershipException(PartnershipError)` | `alreadyLinked`, `targetLinked`, `emailUnknown`, `inviteExpired`, `notSharedPot` |
| `ApiException(status, code)` | everything else: `unauthorized` (401), `notFound` (404), `invalidRequest` (400), transport/parse failures |

The UI maps each typed error to a localized Sprout-voice string via `AppLocalizations`. **The backend never returns English error prose** — locale-agnostic `code` only.

### 5.4 REST endpoint map

All endpoints are relative to `BACKEND_URL`. All authenticated endpoints require `Authorization: Bearer <token>`.

| Verb | Path | Auth | Body / Returns |
|---|---|---|---|
| `POST` | `/auth/signup` | — | `{ name, email, password }` → `{ token, user }` |
| `POST` | `/auth/login` | — | `{ email, password }` → `{ token, user }` |
| `POST` | `/auth/logout` | ✓ | `{}` → 204 |
| `GET` | `/me` | ✓ | → `User` |
| `PUT` | `/me` | ✓ | `User` → `User` |
| `POST` | `/onboarding` | ✓ | `{ currencyCode, monthlyBudget, primaryGoal, personality }` → `User` |
| `GET` | `/transactions?from=&to=&category=` | ✓ | → `Transaction[]` |
| `POST` | `/transactions` | ✓ | `Transaction` (no `id`) → `Transaction` |
| `PUT` | `/transactions/{id}` | ✓ | `Transaction` → `Transaction` |
| `DELETE` | `/transactions/{id}` | ✓ | 204 |
| `POST` | `/transactions/ensure-recurring` | ✓ | `{}` → 204 (idempotent; instantiates planned tx for current month) |
| `GET` | `/categories` | ✓ | → `Category[]` |
| `POST` | `/categories` | ✓ | `Category` (no `id`) → `Category` |
| `PUT` | `/categories/{id}` | ✓ | `Category` → `Category` |
| `DELETE` | `/categories/{id}` | ✓ | 204 |
| `GET` | `/goals` | ✓ | → `Goal[]` |
| `POST` | `/goals` | ✓ | `Goal` (no `id`) → `Goal` |
| `PATCH` | `/goals/{id}` | ✓ | `Goal` → `Goal` |
| `DELETE` | `/goals/{id}` | ✓ | 204 |
| `POST` | `/goals/{id}/boost` | ✓ | `{ amount, contributorUserId? }` → `Goal` |
| `POST` | `/goals/{id}/pot-deposit` | ✓ | `{ amount, contributorUserId? }` → `Goal` (only valid when `fundingMode == sharedPot`; otherwise `notSharedPot`) |
| `GET` | `/insights` | ✓ | → `Insight[]` |
| `GET` | `/streak` | ✓ | → `{ current, longest, lastLogDate }` |
| `POST` | `/partnership/invite` | ✓ | `{ email }` → `{ status: "pendingOutbound" \| "linked" }` |
| `GET` | `/partnership/pending` | ✓ | → `PendingInvite` or 404 |
| `POST` | `/partnership/accept` | ✓ | `{}` → `Partnership` |
| `POST` | `/partnership/decline` | ✓ | `{}` → 204 (also cancels an outbound invite) |
| `DELETE` | `/partnership` | ✓ | 204 |
| `GET` | `/partnership/partner-summary` | ✓ | → `PartnerSummary` (privacy-filtered) |
| `GET` | `/partnership/partner` | ✓ | → `User` (partner's public profile only) or 404 |

---

## 6. Domain model

All models live under `lib/models/`. Every class implements `toJson()` + `fromJson(Map<String, dynamic>)` so the contract stays symmetric with the backend.

### 6.1 `User`

The current user. Fields fall into groups:

- **Identity & basics:** `id`, `name`, `email`, `currencyCode`, `monthlyBudget`, `themeAccent`, `hasOnboarded`, `personality` (`saver` / `treater` / `goalChaser` / `impulse`).
- **Cooldown (Phase 4):** `cooldownEnabled`, `cooldownThreshold` (default 30), `cooldownSaved`, `cooldownWinCount`. When enabled and an unplanned amount ≥ threshold is logged, the user takes a 30 s breath; cancelling adds the amount to `cooldownSaved` and increments `cooldownWinCount`.
- **Habit loops (Phase 6):** `noSpendDays` — list of ISO dates flagged as "no-spend"; the streak union counts these + days with logged transactions.
- **Theme (Phase 7):** `themeMode` — `system` / `light` / `dark` (default `system`).
- **Round-up savings (Phase 8):** `roundUpEnabled` — every logged spend boosts the primary goal by `ceil(amount) − amount`.
- **Localization:** `languageCode` (null = follow device; otherwise `'en'` or `'bg'`).
- **Partner Plan (Phase 9):** `partnerId`, `partnership` (`PartnershipStatus`), `linkedAt`.
- **Top-ups:** `budgetTopUps: Map<String /* 'yyyy-MM' */, double>` — one-off bonuses for a single month, never affecting the recurring `monthlyBudget`.

### 6.2 `Transaction`

```
id, dateTime, amount, currencyCode, categoryId, note?, mood?, isPlanned, createdAt
isShared, partnerSharePercent?, paidByUserId?
```

- `isPlanned` (Phase 8) marks a recurring monthly transaction; `POST /transactions/ensure-recurring` makes the backend instantiate one copy per month.
- `mood` is an optional integer (UI-defined scale).
- Phase 9 shared-tx fields are only set when `isShared == true`. `partnerSharePercent` defaults to 50; the caller's own budget is charged `100 − partnerSharePercent` of `amount` (see `BudgetController.budgetShareOf`).

### 6.3 `Category`

```
id, name, icon (codepoint + fontFamily), color (ARGB int), monthlyCap, sharedWithPartner
```

- `icon` round-trips as `{ icon: codePoint, iconFontFamily: 'MaterialIcons' }`.
- `color` round-trips as a 32-bit ARGB int (`Color.toARGB32`).
- `monthlyCap` powers the per-category over-budget check (`BudgetController.isOverBudget`).
- `sharedWithPartner` (Phase 9, opt-in, default false) exposes **only the category's monthly total** to the linked partner, never individual transactions. Categories created after linking still default to false.

### 6.4 `Goal` + `GoalBoost`

```
Goal:  id, name, icon, color, targetAmount, currentAmount, deadline?, boosts[]
       partnershipId?, fundingMode?, sharedPotBalance
GoalBoost: amount, dateTime, contributorUserId?
```

- `progress` = `currentAmount / targetAmount`, clamped 0..1.
- Milestones at 0.25 / 0.5 / 0.75 / 1.0 trigger a confetti burst (`BoostResult.milestone`).
- **Phase 9 shared goals:**
  - `partnershipId != null` → goal is co-owned.
  - `fundingMode == splitContributions` → each partner boosts from their own money; `GoalBoost.contributorUserId` attributes each boost.
  - `fundingMode == sharedPot` → partners deposit into one pot (`sharedPotBalance`); use `POST /goals/{id}/pot-deposit`.

### 6.5 Partnership types (`lib/models/partnership.dart`)

| Type | Purpose |
|---|---|
| `enum PartnershipStatus` | `none` / `pendingOutbound` / `pendingInbound` / `linked` |
| `enum GoalFundingMode` | `splitContributions` / `sharedPot` |
| `Partnership { id, userAId, userBId, linkedAt, inviterEmail? }` | the live 1:1 link |
| `PendingInvite { inviterEmail, inviterName }` | an inbound invite |
| `PartnerSummary { sharedCategoryTotals[], sharedTxThisMonthTotal, sharedGoalsTotalSaved, rateAsOf? }` | **the entire surface a partner can see** |
| `SharedCategoryTotal { categoryId, name, total }` | one opted-in category's monthly sum |
| `enum SharedGoalAction` | `assignToMe` / `assignToPartner` / `delete` (unlink resolution) |
| `SharedGoalResolution { goalId, action }` | per-shared-goal choice during unlink |

> **Privacy contract.** `PartnerSummary` is the **only** payload the server is allowed to send about the linked partner. It must **never** include the partner's overall monthly spend, total savings, monthly budget, personal goals, personal transactions, or any category they haven't opted to share. Filtering is server-side; the client must not rely on local filtering. See [`partner_plan.md`](partner_plan.md) for the full spec.

### 6.6 Insights & achievements

- `Insight { id, kind, data }` — `kind ∈ { latteFactor, moodPattern, weeklyRecap, achievement }`. The backend ships locale-agnostic kind + data map; the UI renders title/body via `AppLocalizations`.
- `Achievement { kind, emoji, unlocked, amount? }` — **derived state**, not stored. Computed by `BudgetController.achievements` from the current user/goals/streak. Kinds: `firstAmountSaved` (≥ 100 saved), `streak7`, `cooldowns10`, `firstGoalHit`.

### 6.7 `Currency`

```dart
enum Currency { eur, usd }
```

Helpers: `code` (uppercase string), `Currency.fromCode(String)` with `EUR` fallback.

---

## 7. State management — `BudgetController`

`lib/state/budget_controller.dart` is a single `ChangeNotifier` that owns **all** in-memory app state. UI conventions:

- `context.watch<BudgetController>()` → subscribe to rebuilds.
- `context.select<BudgetController, T>(selector)` → subscribe only to one field.
- `context.read<BudgetController>()` → trigger mutations (no rebuild dependency).

Widgets **never** touch `BudgetApi` or `shared_preferences` directly.

### 7.1 Owned state

| Field | Purpose |
|---|---|
| `User? _user` | current user (null = signed out) |
| `List<Transaction> _transactions` | full transaction list |
| `List<Category> _categories` | user's categories |
| `List<Goal> _goals` | personal **and** shared goals |
| `List<Insight> _insights` | server-computed insights |
| `StreakInfo _streak` | current + longest streak |
| `User? _partner` | linked partner's public profile (null when solo) |
| `Partnership? _partnership` | the live 1:1 link |
| `PartnerSummary? _partnerSummary` | privacy-filtered partner data |
| `PendingInvite? _pendingInvite` | inbound invite waiting on this user |
| `bool _booted, _loading` | lifecycle flags |
| `String? _error` | last error |

All collection getters return `List.unmodifiable(...)` to keep mutation centralized.

### 7.2 Derived getters

- `authStatus` → `booting | signedOut | needsOnboarding | ready`.
- `partnershipStatus` → derived from `User.partnership` and `_pendingInvite`. `isPartnered = partnershipStatus == linked`.
- `sharedGoals` / `personalGoals` — partitioned by `Goal.partnershipId`.
- `spentThisMonth`, `spendByCategoryThisMonth` — both use `budgetShareOf(tx)` so shared transactions only count the user's own share.
- `savedThisMonth` — sum of *your* goal boosts this month (own contributions + your share of split/pot deposits; never your partner's contributions).
- `effectiveMonthlyBudget` = `User.monthlyBudget + topUpThisMonth`.
- `remainingThisMonth` = `effectiveMonthlyBudget − spentThisMonth − savedThisMonth`. **May go negative** — both spending and money set aside draw down the balance.
- `isOverBudget` — true when any single category exceeds its `monthlyCap`.
- `primaryGoal` — first personal goal, or first goal overall if none.
- `dailyNudge` — `noSpend | aheadOfPace | treatDay`, computed against `monthlyBudget / daysInMonth`.
- `achievements` — derived badges (§6.6).
- `currency`, `locale`, `localeString`.

### 7.3 Lifecycle

`bootstrap()` runs once on app start:

1. `api.getMe()` to confirm the saved token is still valid.
2. `api.ensureRecurringTransactions()` (Phase 8) — idempotent.
3. `_refreshAll()` parallel-fetches transactions, categories, goals, streak, insights, then `_refreshPartnerState()` (partner + summary if linked, else pending invite).
4. On any failure, all state is cleared and `authStatus` falls back to `signedOut`.

`_refreshPartnerState()` is the single funnel for partner data and is re-run after any partner-touching mutation (invite/accept/decline/unlink/toggle/share-create).

### 7.4 Mutating methods (selected)

| Method | Behavior |
|---|---|
| `signup` / `login` | call API, store user, `_refreshAll()` |
| `logout` | API call, clear all in-memory state |
| `completeOnboarding({ currency, monthlyBudget, primaryGoal, personality })` | `POST /onboarding` then `_refreshAll()` |
| `addTransaction(...)` | creates tx; if `roundUpEnabled` and a primary goal exists, also auto-boosts by `ceil(amount) − amount`; returns `BoostResult?` so UI can fire confetti on a milestone |
| `markTodayNoSpend` | adds today to `User.noSpendDays`, refreshes streak |
| `setCooldownEnabled` / `setCooldownThreshold` / `recordCooldownWin` | Phase 4 cooldown timer |
| `setRoundUpEnabled` | Phase 8 |
| `setMonthlyBudget(double)` | clamped to (0, `kMaxMonthlyBudget = 50000`] |
| `addBudgetTopUp(double)` | one-off bonus for `'yyyy-MM'` of today |
| `boostGoal(goalId, amount, { contributorUserId? })` | returns `BoostResult { goal, milestone? }`; refreshes partner summary if the goal is shared |
| `invitePartner` / `acceptPartnership` / `declinePartnership` / `cancelInvite` | Phase 9 invite flow |
| `toggleCategoryShared(categoryId)` | flips `Category.sharedWithPartner`, refreshes partner summary |
| `createSharedGoal(Goal, GoalFundingMode)` | tags goal with `_partnershipId` and the funding mode |
| `depositToSharedPot(goalId, amount)` | `POST /goals/{id}/pot-deposit`; returns `BoostResult` |
| `createSharedTransaction({ amount, categoryId, partnerSharePercent, paidByUserId, ... })` | logs a split tx; round-up only fires when **you** are the payer, and rounds **your share** |
| `unlinkPartner({ resolutions })` | applies each `SharedGoalResolution` first (assignToMe → make personal; assignToPartner / delete → remove from my view), then `DELETE /partnership` |

---

## 8. Screens & UI

Each screen lives under `lib/screens/<name>/<name>_screen.dart`. Five live behind the bottom nav (§4.3); the rest are reached via push.

### 8.1 Pre-app

| Screen | Purpose |
|---|---|
| `SplashScreen` | shown during `AuthStatus.booting`; minimal sprout logo + spinner |
| `AuthScreen` (+ `LoginForm`, `SignupForm`) | login / signup; surfaces `AuthException` via localized strings |
| `OnboardingFlow` | multi-step: `WelcomeStep` → `PersonalityQuizStep` (sets `SpendingPersonality`) → `BudgetStep` (currency + monthly budget) → `GoalStep` (first goal). Calls `completeOnboarding` at the end |

### 8.2 Tabs

| Screen | What it shows |
|---|---|
| `HomeScreen` | balance card, daily nudge banner, streak chip, today's transactions, "+" FAB → `AddTransactionSheet`, partner promo card when not partnered |
| `StatsScreen` | donut + bar charts (fl_chart), calendar heatmap, category sparklines, mood breakdown |
| `GoalsScreen` | shared-goal section above personal goals when partnered; each card → `GoalDetailScreen` / `SharedGoalDetailScreen` |
| `TogetherScreen` | partner dashboard — shared goals summary, shared transactions this month, opted-in shared category totals; only enabled when partnered |
| `YouScreen` | profile, currency, monthly budget editor, theme/language pickers, achievements grid, cooldown + round-up toggles, Partner panel (invite/accept/unlink), logout |

### 8.3 Detail & sheets

- `GoalDetailScreen` — progress, deadline countdown, boost history, confetti on milestone crossings.
- `SharedGoalDetailScreen` — adds funding-mode-specific UI: stacked-bar contribution split for `splitContributions`, pot-balance card + "deposit" sheet for `sharedPot`. History entries show contributor avatars.
- `AddTransactionSheet` — amount, category, note, mood; when partnered, exposes "share with partner" toggle → split slider + "paid by" segmented control.
- `CooldownScreen` — 30 s breath when an unplanned amount ≥ `cooldownThreshold` is logged.
- `CategoryDetailScreen` — per-category list + edit (cap, name, color, icon, `sharedWithPartner`).

### 8.4 Reusable widgets (`lib/widgets/`)

Cards: `balance_card`, `category_card`, `goal_card`, `shared_goal_card`, `partner_home_card`, `insight_card`. Charts: `bar_chart_card`, `donut_chart_card`, `calendar_heatmap`, `category_sparkline`. Sheets: `add_category_sheet`, `add_goal_sheet`, `amount_entry_sheet`, `budget_top_up_sheet`, `create_shared_goal_sheet`, `edit_goal_sheet`, `set_aside_sheet`, `shared_categories_sheet`, `shared_contribute_sheet`, `unlink_resolution_sheet`. Other: `bottom_nav_bar`, `header`, `streak_chip`, `nudge_banner`, `sprout_mascot`, `milestone_celebration`, `language_panel`, `partner_panel`, `partner_common`, `recurring_list`, `round_up_panel`, `achievement_badges`, `what_if_simulator`.

---

## 9. Localization

- ARB files: `lib/l10n/app_en.arb` and `lib/l10n/app_bg.arb`.
- After editing ARBs, regenerate: `flutter gen-l10n`.
- The drift guard `test/l10n/arb_drift_test.dart` fails the build if ARBs and generated code diverge.
- The active locale comes from `BudgetController.locale` (`User.languageCode`, null = follow device). `localeString` is the BCP-47 string for `intl` formatters.
- All user-facing strings — including error copy mapped from `AuthError` / `PartnershipError` / `ApiException.code` — go through `AppLocalizations`. **No English literals in widget code.**

---

## 10. Theming (`lib/theme.dart`)

`buildSproutTheme(seed, brightness)` produces a `ThemeData` with:

- `SproutBrand.primary` as the seed color.
- Custom shapes (rounded corners, soft elevation).
- A brand gradient used for goal progress bars, FABs, and confetti.

The app currently ships **light only** — `app.dart` hard-codes `Brightness.light` regardless of `User.themeMode`. (The model field is reserved for when dark mode ships.)

---

## 11. Cross-cutting concerns

### 11.1 Money & dates

- All amounts are `double` in the user's `currencyCode`. **No client-side FX conversion** — the backend converts shared figures to the viewer's currency when partners differ (`PartnerSummary.rateAsOf` carries the rate date).
- All dates serialize as ISO-8601. The client uses local time for "is today / this month" queries.

### 11.2 Privacy (Phase 9)

The partner-visibility contract:

1. **Shared goals** they jointly own (`Goal.partnershipId == partnership.id`).
2. **Shared transactions** marked `isShared == true` at log time.
3. **Monthly totals of categories** the other partner has set `sharedWithPartner = true` on — sum only, never the underlying transactions.

Never: overall monthly spend, total savings, monthly budget, personal goals, personal transactions, or any non-opted-in category. **Filtering is server-side**; the client must not assume server payloads are pre-filtered safely if it implements its own checks. See [`partner_plan.md`](partner_plan.md) for full rules, edge cases, voice strings, and acceptance criteria.

### 11.3 Round-up & shared transactions

When `roundUpEnabled` and a primary goal exists:
- Personal tx: boost = `ceil(amount) − amount`.
- Shared tx: round-up runs **only when the current user is the payer**, and rounds **the user's own share** (not the full amount). See `BudgetController.createSharedTransaction`.

### 11.4 Recurring transactions (Phase 8)

Marking a transaction `isPlanned = true` makes it a monthly template. The backend ensures one matching copy exists per month (matched by category + amount + note). The client calls `ensureRecurringTransactions()` on every `bootstrap()` — the endpoint is idempotent.

### 11.5 Streaks

- `StreakInfo.current` / `longest` come from the backend.
- The streak compute unions days that have any transaction **with** days flagged in `User.noSpendDays`.
- Streaks are **per-user** — shared activity does not bleed into the partner's streak.

---

## 12. Setup, run, and quality gates

### 12.1 Prerequisites

- Flutter SDK (stable, run `flutter doctor`).
- iOS: Xcode + CocoaPods (`sudo gem install cocoapods`).
- Android: Android Studio + emulator or device.
- A running instance of the Sprout backend reachable from the device.

### 12.2 Setup

```sh
flutter pub get
# Edit .env at the project root:
# BACKEND_URL=https://your-backend-host/v1
```

`.env` is bundled as an asset and is **required** at launch.

### 12.3 Run

```sh
flutter devices
flutter run -d "iPhone 17 Pro"
flutter run -d android
```

Hot-reload: `r` · hot-restart: `R` · quit: `q`.

### 12.4 Quality gates

```sh
flutter analyze    # must report: No issues found!
flutter test       # unit tests (models, formatters, l10n drift)
flutter gen-l10n   # after any ARB edit
```

`flutter analyze` must stay at zero issues before merge.

---

## 13. Glossary

| Term | Meaning |
|---|---|
| **Boost** | A single contribution to a goal (one `GoalBoost`). |
| **Cooldown** | 30 s breath before logging an unplanned spend ≥ threshold. |
| **Daily nudge** | Sprout's encouragement banner (`noSpend` / `aheadOfPace` / `treatDay`). |
| **Effective monthly budget** | `User.monthlyBudget + topUpThisMonth`. |
| **Partner Plan** | Phase 9 1:1 link letting two users share goals/transactions/category totals without exposing personal finances. |
| **Pot** | Communal balance for a shared goal with `fundingMode == sharedPot`. |
| **Round-up** | Auto-boost the primary goal by `ceil(amount) − amount` on each spend. |
| **Streak** | Consecutive days the user logged a transaction or flagged no-spend. |
| **Top-up** | One-off bonus added to a single month's budget without changing the recurring monthly budget. |

---

## 14. Companion docs

- [`README.md`](../README.md) — quickstart for developers.
- [`partner_plan.md`](partner_plan.md) — full Phase 9 spec (data model, REST additions, screens, voice strings, edge cases).
- `lib/data/budget_api.dart` — authoritative REST contract.
- `lib/state/budget_controller.dart` — authoritative state model.
