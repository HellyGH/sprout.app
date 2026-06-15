import '../models/category.dart';
import '../models/goal.dart';
import '../models/insight.dart';
import '../models/partnership.dart';
import '../models/transaction.dart';
import '../models/user.dart';

/// Locale-independent failure modes for auth + form input. The UI maps
/// each to a localized string. Used in place of throwing English-only
/// FormatExceptions from the API layer.
enum AuthError {
  nameRequired,
  emailLooksOff,
  passwordTooShort,
  accountExists,
  noMatch,
}

class AuthException implements Exception {
  final AuthError code;
  const AuthException(this.code);
}

/// Фаза 9. Независими от езика грешки в потока за партньори. UI-ът съпоставя
/// всяка от тях към съответния текст в стила на Sprout.
enum PartnershipError {
  alreadyLinked, // caller is already partnered
  targetLinked, // target email already partnered with someone else
  emailUnknown, // no Sprout account for that email
  inviteExpired, // accepting an invite past its 7-day window
  notSharedPot, // pot-deposit on a non-pot goal
}

class PartnershipException implements Exception {
  final PartnershipError code;
  const PartnershipException(this.code);
}

/// Catch-all for backend errors that aren't a known auth/partnership code:
/// `unauthorized` (401), `notFound` (404), `invalidRequest` (400), transport
/// failures, etc. [code] is the backend's locale-agnostic `error.code` (or a
/// synthetic one for transport/parse failures); [status] is the HTTP status.
class ApiException implements Exception {
  final int status;
  final String code;
  const ApiException(this.status, this.code);

  @override
  String toString() => 'ApiException($status, $code)';
}

class AuthSession {
  final String token;
  final User user;
  const AuthSession({required this.token, required this.user});
}

class StreakInfo {
  final int current;
  final int longest;
  final DateTime? lastLogDate;
  const StreakInfo({
    required this.current,
    required this.longest,
    this.lastLogDate,
  });
}

abstract class BudgetApi {
  // Auth
  Future<AuthSession> signup({
    required String name,
    required String email,
    required String password,
  });
  Future<AuthSession> login({required String email, required String password});
  Future<void> logout();

  // User
  Future<User> getMe();
  Future<User> updateMe(User user);
  Future<User> completeOnboarding({
    required String currencyCode,
    required double monthlyBudget,
    required Goal primaryGoal,
    required SpendingPersonality personality,
  });

  // Transactions
  Future<List<Transaction>> getTransactions({
    DateTime? from,
    DateTime? to,
    String? categoryId,
  });
  Future<Transaction> createTransaction(Transaction tx);
  Future<Transaction> updateTransaction(Transaction tx);
  Future<void> deleteTransaction(String id);

  /// Phase 8. For each [Transaction] with `isPlanned: true`, ensures one
  /// copy exists in the current calendar month (matched by category +
  /// amount + note). Idempotent — safe to call on every bootstrap.
  Future<void> ensureRecurringTransactions();

  // Categories
  Future<List<Category>> getCategories();
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);

  // Goals
  Future<List<Goal>> getGoals();
  Future<Goal> createGoal(Goal goal);
  Future<Goal> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
  Future<Goal> boostGoal({
    required String goalId,
    required double amount,
    String? contributorUserId,
  });

  // Insights & streak (computed on backend; mock derives them)
  Future<List<Insight>> getInsights();
  Future<StreakInfo> getStreak();

  // Partnership (Phase 9)

  /// Invite a user by email. Returns the resulting status from the caller's
  /// point of view ([PartnershipStatus.pendingOutbound]). Throws
  /// [PartnershipException] on 409/404.
  Future<PartnershipStatus> invitePartner(String email);

  /// The invite waiting on the current user, or null if there is none.
  Future<PendingInvite?> getPendingInvite();

  /// Accept the inbound invite. Throws [PartnershipException] if expired.
  Future<Partnership> acceptPartnership();

  /// Decline the inbound invite, or cancel an outbound one.
  Future<void> declinePartnership();

  /// Unlink the partnership. Server reverts shared categories + emits an
  /// unlink event to both sides. Shared-goal resolution is applied by the
  /// caller (via goal updates/deletes) *before* this call.
  Future<void> unlinkPartnership();

  /// The privacy-filtered summary of the partner's shared data. Filtered
  /// server-side — only ever shared goals/tx/opted-in category totals.
  Future<PartnerSummary> getPartnerSummary();

  /// Resolve the linked partner's [User] record (for name/initials/currency),
  /// or null when solo. Never carries the partner's private finances.
  Future<User?> getPartner();

  /// Deposit into a shared-pot goal. Throws [PartnershipException]
  /// ([PartnershipError.notSharedPot]) when the goal isn't a shared pot.
  Future<Goal> depositToSharedPot({
    required String goalId,
    required double amount,
    String? contributorUserId,
  });
}
