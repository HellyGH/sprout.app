import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/widgets.dart' show Locale;

import '../data/budget_api.dart';
import '../models/achievement.dart';
import '../models/category.dart';
import '../models/currency.dart';
import '../models/goal.dart';
import '../models/insight.dart';
import '../models/partnership.dart';
import '../models/transaction.dart';
import '../models/user.dart';

/// Upper bound for a recurring monthly budget. Generous so higher earners
/// aren't boxed in, but bounded to keep inputs sane.
const double kMaxMonthlyBudget = 50000;

/// Where to send the user next, derived from auth + onboarding state.
enum AuthStatus { booting, signedOut, needsOnboarding, ready }

/// Sprout's daily nudge variant. The UI maps each kind to a localized
/// string; [amount] is only meaningful for [DailyNudgeKind.aheadOfPace].
enum DailyNudgeKind { noSpend, aheadOfPace, treatDay }

class DailyNudge {
  final DailyNudgeKind kind;
  final double? amount;
  const DailyNudge({required this.kind, this.amount});
}

/// Returned by [BudgetController.boostGoal]. [milestone] is the highest
/// threshold (0.25, 0.5, 0.75, 1.0) crossed by this boost; null if none.
class BoostResult {
  final Goal goal;
  final double? milestone;

  const BoostResult({required this.goal, this.milestone});
}

/// App-wide budgeting state. Owns lists of transactions / categories / goals
/// and proxies all reads/writes through [BudgetApi]. UI reads via
/// `context.watch<BudgetController>()` and mutates via `context.read<...>()`.
class BudgetController extends ChangeNotifier {
  final BudgetApi api;

  BudgetController(this.api);

  User? _user;
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  List<Goal> _goals = [];
  List<Insight> _insights = [];
  StreakInfo _streak = const StreakInfo(current: 0, longest: 0);

  // Phase 9 partner state.
  User? _partner;
  Partnership? _partnership;
  PartnerSummary? _partnerSummary;
  PendingInvite? _pendingInvite;

  bool _booted = false;
  bool _loading = false;
  String? _error;

  // ---------- getters ----------

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Category> get categories => List.unmodifiable(_categories);
  List<Goal> get goals => List.unmodifiable(_goals);
  List<Insight> get insights => List.unmodifiable(_insights);
  StreakInfo get streak => _streak;
  bool get loading => _loading;
  String? get error => _error;

  // ---------- partner getters (Phase 9) ----------

  User? get partner => _partner;
  Partnership? get partnership => _partnership;
  PartnerSummary? get partnerSummary => _partnerSummary;
  PendingInvite? get pendingInvite => _pendingInvite;

  /// Effective partnership status for this user. Inbound invites are derived
  /// from a pending invite targeting this user.
  PartnershipStatus get partnershipStatus {
    final u = _user;
    if (u == null) return PartnershipStatus.none;
    if (u.partnership == PartnershipStatus.linked) {
      return PartnershipStatus.linked;
    }
    if (_pendingInvite != null) return PartnershipStatus.pendingInbound;
    if (u.partnership == PartnershipStatus.pendingOutbound) {
      return PartnershipStatus.pendingOutbound;
    }
    return PartnershipStatus.none;
  }

  bool get isPartnered => partnershipStatus == PartnershipStatus.linked;

  /// Goals jointly owned with the partner.
  List<Goal> get sharedGoals =>
      _goals.where((g) => g.partnershipId != null).toList();

  /// The user's own (non-shared) goals.
  List<Goal> get personalGoals =>
      _goals.where((g) => g.partnershipId == null).toList();

  Insight? insightOf(InsightKind kind) {
    for (final i in _insights) {
      if (i.kind == kind) return i;
    }
    return null;
  }

  /// True if the user has any transaction logged today.
  bool get todayHasTransaction {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _transactions.any(
      (t) =>
          !t.dateTime.isBefore(today) &&
          t.dateTime.isBefore(today.add(const Duration(days: 1))),
    );
  }

  /// True if the user has flagged today as a no-spend day.
  bool get isTodayNoSpend {
    final u = _user;
    if (u == null) return false;
    final now = DateTime.now();
    return u.noSpendDays.any((d) =>
        d.year == now.year && d.month == now.month && d.day == now.day);
  }

  /// Phase 6 achievement badges. Derived from current state, not stored.
  List<Achievement> get achievements {
    final goalSaved =
        _goals.fold<double>(0, (s, g) => s + g.currentAmount);
    final anyComplete = _goals.any((g) => g.isComplete);
    final streakHigh = _streak.longest >= 7 || _streak.current >= 7;
    final cooldownWins = (_user?.cooldownWinCount ?? 0) >= 10;
    return [
      Achievement(
        kind: AchievementKind.firstAmountSaved,
        emoji: '💰',
        unlocked: goalSaved >= 100,
        amount: 100,
      ),
      Achievement(
        kind: AchievementKind.streak7,
        emoji: '🔥',
        unlocked: streakHigh,
      ),
      Achievement(
        kind: AchievementKind.cooldowns10,
        emoji: '🌱',
        unlocked: cooldownWins,
      ),
      Achievement(
        kind: AchievementKind.firstGoalHit,
        emoji: '🎉',
        unlocked: anyComplete,
      ),
    ];
  }

  /// Sprout's daily nudge for the Home banner. Returns a structured value
  /// so the UI can localize the copy; null when there's nothing to say.
  DailyNudge? get dailyNudge {
    final u = _user;
    if (u == null || u.monthlyBudget <= 0) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dailyTarget = u.monthlyBudget / daysInMonth;
    final spentToday = _transactions
        .where((t) =>
            !t.dateTime.isBefore(today) &&
            t.dateTime.isBefore(today.add(const Duration(days: 1))))
        .fold<double>(0, (s, t) => s + t.amount);
    if (spentToday == 0) {
      return const DailyNudge(kind: DailyNudgeKind.noSpend);
    }
    if (spentToday < dailyTarget) {
      return DailyNudge(
        kind: DailyNudgeKind.aheadOfPace,
        amount: dailyTarget - spentToday,
      );
    }
    return const DailyNudge(kind: DailyNudgeKind.treatDay);
  }

  AuthStatus get authStatus {
    if (!_booted) return AuthStatus.booting;
    final u = _user;
    if (u == null) return AuthStatus.signedOut;
    if (!u.hasOnboarded) return AuthStatus.needsOnboarding;
    return AuthStatus.ready;
  }

  Currency get currency =>
      Currency.fromCode(_user?.currencyCode ?? Currency.eur.code);

  /// App locale. Null means "follow device locale" — MaterialApp will then
  /// fall through to its `localeResolutionCallback` / system default.
  Locale? get locale {
    final code = _user?.languageCode;
    if (code == null) return null;
    return Locale(code);
  }

  /// BCP-47 string of the active UI locale, suitable for `intl` formatters.
  /// Falls back to 'en' before a user exists.
  String get localeString => _user?.languageCode ?? 'en';

  Future<void> setLocale(String? code) async {
    final u = _user;
    if (u == null) return;
    _user = await api.updateMe(u.copyWith(languageCode: code));
    notifyListeners();
  }

  Category? categoryById(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ---------- derived totals ----------

  /// Общо похарчено този месец, във валутата на потребителя. При споделените
  /// транзакции се брои само собственият дял на потребителя.
  double get spentThisMonth {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    return _transactions
        .where((t) => t.dateTime.isAfter(start) || t.dateTime.isAtSameMomentAs(start))
        .fold(0.0, (sum, t) => sum + budgetShareOf(t));
  }

  /// Суми по категории за този месец. При споделените транзакции се брои само
  /// собственият дял на потребителя.
  Map<String, double> get spendByCategoryThisMonth {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final out = <String, double>{};
    for (final t in _transactions) {
      if (t.dateTime.isBefore(start)) continue;
      out.update(t.categoryId, (v) => v + budgetShareOf(t),
          ifAbsent: () => budgetShareOf(t));
    }
    return out;
  }

  /// Money you set aside into goals this month that draws down *your* balance:
  /// your own goal boosts + your share of shared-pot / split deposits. Never
  /// counts the partner's contributions. Boosts with no contributor (personal
  /// goals) are always yours.
  double get savedThisMonth {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final meId = _user?.id;
    double total = 0;
    for (final g in _goals) {
      for (final b in g.boosts) {
        if (b.dateTime.isBefore(start)) continue;
        if (b.contributorUserId == null || b.contributorUserId == meId) {
          total += b.amount;
        }
      }
    }
    return total;
  }

  /// 'yyyy-MM' key for the current month — how per-month top-ups are stored.
  static String _monthKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

  /// One-off top-up applied to the current month only (0 if none).
  double get topUpThisMonth =>
      _user?.budgetTopUps[_monthKey(DateTime.now())] ?? 0;

  /// This month's spendable budget: the recurring [User.monthlyBudget] plus
  /// any one-off top-up for this month.
  double get effectiveMonthlyBudget =>
      (_user?.monthlyBudget ?? 0) + topUpThisMonth;

  /// Remaining balance this month. The monthly budget acts as a balance:
  /// both spending *and* money set aside into goals/pots draw it down.
  /// May be negative.
  double get remainingThisMonth =>
      effectiveMonthlyBudget - spentThisMonth - savedThisMonth;

  /// Change the recurring monthly budget — applies from now on (e.g. after a
  /// raise). Clamped to (0, [kMaxMonthlyBudget]]. One-off top-ups are kept.
  Future<void> setMonthlyBudget(double amount) async {
    final u = _user;
    if (u == null) return;
    final clamped = amount.clamp(0.0, kMaxMonthlyBudget);
    if (clamped <= 0) return;
    _user = await api.updateMe(u.copyWith(monthlyBudget: clamped));
    notifyListeners();
  }

  /// Add a one-off bonus to this month's budget (e.g. a June-only €400). Adds
  /// to any existing top-up for the month; leaves future months untouched.
  Future<void> addBudgetTopUp(double amount) async {
    final u = _user;
    if (u == null || amount == 0) return;
    final key = _monthKey(DateTime.now());
    final next = Map<String, double>.from(u.budgetTopUps);
    next[key] = (next[key] ?? 0) + amount;
    _user = await api.updateMe(u.copyWith(budgetTopUps: next));
    notifyListeners();
  }

  /// True if any single category has exceeded its monthly cap.
  bool get isOverBudget {
    final byCat = spendByCategoryThisMonth;
    for (final cat in _categories) {
      if ((byCat[cat.id] ?? 0) > cat.monthlyCap) return true;
    }
    return false;
  }

  Goal? get primaryGoal {
    final personal = personalGoals;
    if (personal.isNotEmpty) return personal.first;
    return _goals.isEmpty ? null : _goals.first;
  }

  /// Частта от [t], която се отчита към бюджета на *този* потребител. При
  /// споделена транзакция това е делът на потребителя (`100 − partnerSharePercent`);
  /// при лична — цялата сума.
  double budgetShareOf(Transaction t) {
    if (!t.isShared) return t.amount;
    final partnerPct = (t.partnerSharePercent ?? 50).clamp(0, 100);
    return t.amount * (1 - partnerPct / 100);
  }

  // ---------- lifecycle ----------

  Future<void> bootstrap() async {
    _setLoading(true);
    try {
      _user = await api.getMe();
      // Phase 8: ensure recurring tx for this month before reading.
      await api.ensureRecurringTransactions();
      await _refreshAll();
    } catch (_) {
      _user = null;
      _transactions = [];
      _categories = [];
      _goals = [];
      _streak = const StreakInfo(current: 0, longest: 0);
    } finally {
      _booted = true;
      _setLoading(false);
    }
  }

  Future<void> _refreshAll() async {
    final results = await Future.wait([
      api.getTransactions(),
      api.getCategories(),
      api.getGoals(),
      api.getStreak(),
      api.getInsights(),
    ]);
    _transactions = results[0] as List<Transaction>;
    _categories = results[1] as List<Category>;
    _goals = results[2] as List<Goal>;
    _streak = results[3] as StreakInfo;
    _insights = results[4] as List<Insight>;
    await _refreshPartnerState();
    notifyListeners();
  }

  /// Loads partner-related state from the API based on the current user's
  /// partnership status. Called as part of [_refreshAll].
  Future<void> _refreshPartnerState() async {
    final u = _user;
    if (u == null) {
      _partner = null;
      _partnership = null;
      _partnerSummary = null;
      _pendingInvite = null;
      return;
    }
    if (u.partnership == PartnershipStatus.linked) {
      _partner = await api.getPartner();
      _partnerSummary = await api.getPartnerSummary();
      _pendingInvite = null;
    } else {
      _partner = null;
      _partnerSummary = null;
      _pendingInvite = await api.getPendingInvite();
    }
  }

  Future<void> _refreshInsights() async {
    _insights = await api.getInsights();
    notifyListeners();
  }

  // ---------- auth ----------

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final session = await api.signup(name: name, email: email, password: password);
      _user = session.user;
      await _refreshAll();
      _error = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final session = await api.login(email: email, password: password);
      _user = session.user;
      await _refreshAll();
      _error = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await api.logout();
    _user = null;
    _transactions = [];
    _categories = [];
    _goals = [];
    _streak = const StreakInfo(current: 0, longest: 0);
    _partner = null;
    _partnership = null;
    _partnerSummary = null;
    _pendingInvite = null;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required Currency currency,
    required double monthlyBudget,
    required Goal primaryGoal,
    required SpendingPersonality personality,
  }) async {
    _user = await api.completeOnboarding(
      currencyCode: currency.code,
      monthlyBudget: monthlyBudget,
      primaryGoal: primaryGoal,
      personality: personality,
    );
    await _refreshAll();
  }

  // ---------- cooldown (Phase 4) ----------

  Future<void> setCooldownEnabled(bool enabled) async {
    final u = _user;
    if (u == null) return;
    _user = await api.updateMe(u.copyWith(cooldownEnabled: enabled));
    notifyListeners();
  }

  Future<void> setCooldownThreshold(double threshold) async {
    final u = _user;
    if (u == null) return;
    _user = await api.updateMe(u.copyWith(cooldownThreshold: threshold));
    notifyListeners();
  }

  /// User cancelled a logged spend during the cooldown breath. Add the
  /// avoided amount to the lifetime "talked yourself out of" total and
  /// bump the win counter.
  Future<void> recordCooldownWin(double amount) async {
    final u = _user;
    if (u == null) return;
    _user = await api.updateMe(
      u.copyWith(
        cooldownSaved: u.cooldownSaved + amount,
        cooldownWinCount: u.cooldownWinCount + 1,
      ),
    );
    notifyListeners();
  }

  // ---------- round-up savings (Phase 8) ----------

  Future<void> setRoundUpEnabled(bool enabled) async {
    final u = _user;
    if (u == null) return;
    _user = await api.updateMe(u.copyWith(roundUpEnabled: enabled));
    notifyListeners();
  }

  /// Phase 6: flag today as no-spend so it counts toward the streak.
  /// Idempotent — if already flagged, this is a no-op.
  Future<void> markTodayNoSpend() async {
    final u = _user;
    if (u == null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (u.noSpendDays.any((d) =>
        d.year == today.year &&
        d.month == today.month &&
        d.day == today.day)) {
      return;
    }
    _user = await api.updateMe(
      u.copyWith(noSpendDays: [...u.noSpendDays, today]),
    );
    _streak = await api.getStreak();
    notifyListeners();
  }

  // ---------- transactions ----------

  /// Logs a transaction. If round-up savings is enabled and a primary
  /// goal exists, also boosts the goal by `ceil(amount) − amount` and
  /// returns the [BoostResult] (so the caller can fire confetti on a
  /// crossed milestone). Returns null when no auto-boost ran.
  Future<BoostResult?> addTransaction({
    required double amount,
    required String categoryId,
    String? note,
    int? mood,
    bool isPlanned = false,
    DateTime? when,
  }) async {
    final tx = Transaction(
      id: '',
      dateTime: when ?? DateTime.now(),
      amount: amount,
      currencyCode: currency.code,
      categoryId: categoryId,
      note: note,
      mood: mood,
      isPlanned: isPlanned,
      createdAt: DateTime.now(),
    );
    final created = await api.createTransaction(tx);
    _transactions = [created, ..._transactions];
    _streak = await api.getStreak();
    notifyListeners();
    await _refreshInsights();

    // Phase 8 round-up auto-boost.
    final u = _user;
    final goal = primaryGoal;
    if (u != null && u.roundUpEnabled && goal != null && !goal.isComplete) {
      final roundUp = amount.ceilToDouble() - amount;
      if (roundUp > 0.001) {
        return await boostGoal(goal.id, roundUp);
      }
    }
    return null;
  }

  Future<void> updateTransaction(Transaction tx) async {
    final updated = await api.updateTransaction(tx);
    _transactions = [
      for (final t in _transactions) if (t.id == updated.id) updated else t,
    ];
    notifyListeners();
    await _refreshInsights();
  }

  Future<void> deleteTransaction(String id) async {
    await api.deleteTransaction(id);
    _transactions = _transactions.where((t) => t.id != id).toList();
    notifyListeners();
    await _refreshInsights();
  }

  // ---------- categories ----------

  Future<void> updateCategory(Category category) async {
    final updated = await api.updateCategory(category);
    _categories = [
      for (final c in _categories) if (c.id == updated.id) updated else c,
    ];
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    final created = await api.createCategory(category);
    _categories = [..._categories, created];
    notifyListeners();
  }

  // ---------- goals ----------

  Future<void> addGoal(Goal goal) async {
    final created = await api.createGoal(goal);
    _goals = [..._goals, created];
    notifyListeners();
  }

  Future<void> updateGoal(Goal goal) async {
    final updated = await api.updateGoal(goal);
    _goals = [
      for (final g in _goals) if (g.id == updated.id) updated else g,
    ];
    notifyListeners();
  }

  /// Result of a boost call. [milestone] is the highest threshold (0.25,
  /// 0.50, 0.75, 1.0) crossed by this boost — null if none. The UI uses it
  /// to fire a confetti burst.
  Future<BoostResult> boostGoal(
    String goalId,
    double amount, {
    String? contributorUserId,
  }) async {
    final before = _goals.firstWhere((g) => g.id == goalId);
    final updated = await api.boostGoal(
      goalId: goalId,
      amount: amount,
      contributorUserId: contributorUserId,
    );
    _goals = [
      for (final g in _goals) if (g.id == updated.id) updated else g,
    ];
    if (updated.partnershipId != null) await refreshPartnerSummary();
    notifyListeners();
    const thresholds = [0.25, 0.5, 0.75, 1.0];
    double? hit;
    for (final t in thresholds) {
      if (before.progress < t && updated.progress >= t) hit = t;
    }
    return BoostResult(goal: updated, milestone: hit);
  }

  Future<void> deleteGoal(String id) async {
    await api.deleteGoal(id);
    _goals = _goals.where((g) => g.id != id).toList();
    notifyListeners();
  }

  // ---------- partnership (Phase 9) ----------

  /// The partnership id shared goals are tagged with. Prefers the loaded
  /// [Partnership], falls back to an existing shared goal's tag.
  String? get _partnershipId {
    final p = _partnership?.id;
    if (p != null) return p;
    for (final g in _goals) {
      if (g.partnershipId != null) return g.partnershipId;
    }
    return null;
  }

  /// Invite a partner by email. Reloads partner state. Propagates
  /// [PartnershipException].
  Future<void> invitePartner(String email) async {
    final status = await api.invitePartner(email);
    _user = await api.getMe();
    if (status == PartnershipStatus.linked) {
      await _refreshAll();
    } else {
      await _refreshPartnerState();
      notifyListeners();
    }
  }

  Future<void> acceptPartnership() async {
    _partnership = await api.acceptPartnership();
    _user = await api.getMe();
    await _refreshAll();
  }

  Future<void> declinePartnership() async {
    await api.declinePartnership();
    _user = await api.getMe();
    _pendingInvite = null;
    await _refreshPartnerState();
    notifyListeners();
  }

  /// Cancel an outbound invite (alias for [declinePartnership], which clears
  /// both inbound and outbound invites for the caller).
  Future<void> cancelInvite() => declinePartnership();

  Future<void> refreshPartnerSummary() async {
    if (!isPartnered) return;
    _partnerSummary = await api.getPartnerSummary();
    notifyListeners();
  }

  /// Unlink. Applies each shared-goal [resolution] first (assign to me →
  /// becomes personal; assign to partner / delete → removed from my view),
  /// then unlinks server-side and reloads.
  Future<void> unlinkPartner({
    required List<SharedGoalResolution> resolutions,
  }) async {
    for (final r in resolutions) {
      final goal = _goals.where((g) => g.id == r.goalId).firstOrNull;
      if (goal == null) continue;
      switch (r.action) {
        case SharedGoalAction.assignToMe:
          await api.updateGoal(goal.copyWith(
            partnershipId: null,
            fundingMode: null,
          ));
        case SharedGoalAction.assignToPartner:
        case SharedGoalAction.delete:
          await api.deleteGoal(goal.id);
      }
    }
    await api.unlinkPartnership();
    _partnership = null;
    _user = await api.getMe();
    await _refreshAll();
  }

  Future<void> toggleCategoryShared(String categoryId) async {
    final cat = categoryById(categoryId);
    if (cat == null) return;
    await updateCategory(
      cat.copyWith(sharedWithPartner: !cat.sharedWithPartner),
    );
    await refreshPartnerSummary();
  }

  /// Create a shared goal in the current partnership.
  Future<Goal> createSharedGoal(Goal goal, GoalFundingMode mode) async {
    final shared = goal.copyWith(
      partnershipId: _partnershipId,
      fundingMode: mode,
    );
    final created = await api.createGoal(shared);
    _goals = [..._goals, created];
    await refreshPartnerSummary();
    notifyListeners();
    return created;
  }

  /// Deposit into a shared-pot goal. [contributorUserId] defaults to the
  /// current user; pass the partner's id to attribute their deposit.
  Future<BoostResult> depositToSharedPot(
    String goalId,
    double amount, {
    String? contributorUserId,
  }) async {
    final before = _goals.firstWhere((g) => g.id == goalId);
    final updated = await api.depositToSharedPot(
      goalId: goalId,
      amount: amount,
      contributorUserId: contributorUserId,
    );
    _goals = [
      for (final g in _goals) if (g.id == updated.id) updated else g,
    ];
    await refreshPartnerSummary();
    notifyListeners();
    const thresholds = [0.25, 0.5, 0.75, 1.0];
    double? hit;
    for (final t in thresholds) {
      if (before.progress < t && updated.progress >= t) hit = t;
    }
    return BoostResult(goal: updated, milestone: hit);
  }

  /// Записва споделена транзакция, разделена [partnerSharePercent]/остатък,
  /// платена от [paidByUserId]. Закръгляването нагоре се прилага само когато
  /// текущият потребител е платецът, и закръгля собствения му дял.
  Future<BoostResult?> createSharedTransaction({
    required double amount,
    required String categoryId,
    required double partnerSharePercent,
    required String paidByUserId,
    String? note,
    int? mood,
    DateTime? when,
  }) async {
    final tx = Transaction(
      id: '',
      dateTime: when ?? DateTime.now(),
      amount: amount,
      currencyCode: currency.code,
      categoryId: categoryId,
      note: note,
      mood: mood,
      createdAt: DateTime.now(),
      isShared: true,
      partnerSharePercent: partnerSharePercent,
      paidByUserId: paidByUserId,
    );
    final created = await api.createTransaction(tx);
    _transactions = [created, ..._transactions];
    _streak = await api.getStreak();
    await refreshPartnerSummary();
    notifyListeners();
    await _refreshInsights();

    // Закръгляване нагоре само когато аз съм платецът, върху собствения ми дял.
    final u = _user;
    final goal = primaryGoal;
    final iAmPayer = paidByUserId == u?.id;
    if (u != null &&
        u.roundUpEnabled &&
        iAmPayer &&
        goal != null &&
        !goal.isComplete) {
      final myShare = budgetShareOf(created);
      final roundUp = myShare.ceilToDouble() - myShare;
      if (roundUp > 0.001) {
        return await boostGoal(goal.id, roundUp);
      }
    }
    return null;
  }

  // ---------- helpers ----------

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
