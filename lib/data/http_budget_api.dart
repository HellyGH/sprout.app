import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import '../models/goal.dart';
import '../models/insight.dart';
import '../models/partnership.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import 'budget_api.dart';

/// Комуникира с Python REST бекенда. Bearer токенът се пази в
/// `shared_preferences` под ключа `auth_token` и се прикача към всяка
/// заявка, която не е към `/auth/*`.
class HttpBudgetApi implements BudgetApi {
  /// Base URL with no trailing slash, e.g. `https://api.sprout.app/v1`.
  final String baseUrl;
  final http.Client _client;

  HttpBudgetApi({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  static const _tokenKey = 'auth_token';
  SharedPreferences? _prefsCache;

  Future<SharedPreferences> get _prefs async =>
      _prefsCache ??= await SharedPreferences.getInstance();

  Future<String?> get _token async => (await _prefs).getString(_tokenKey);

  Future<void> _setToken(String token) async =>
      (await _prefs).setString(_tokenKey, token);

  Future<void> _clearToken() async => (await _prefs).remove(_tokenKey);

  // ---------------------------------------------------------------------------
  // Transport helpers
  // ---------------------------------------------------------------------------

  Future<Map<String, String>> _headers(String path) async {
    final headers = {'Content-Type': 'application/json'};
    if (!path.startsWith('/auth/')) {
      final token = await _token;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: {...uri.queryParameters, ...query});
  }

  Future<dynamic> _get(String path, [Map<String, String>? query]) async {
    final res = await _client.get(_uri(path, query), headers: await _headers(path));
    return _handle(res);
  }

  Future<dynamic> _post(String path, [Object? body]) async {
    final res = await _client.post(
      _uri(path),
      headers: await _headers(path),
      body: jsonEncode(body ?? const {}),
    );
    return _handle(res);
  }

  Future<dynamic> _put(String path, Object body) async {
    final res = await _client.put(
      _uri(path),
      headers: await _headers(path),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> _patch(String path, Object body) async {
    final res = await _client.patch(
      _uri(path),
      headers: await _headers(path),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> _delete(String path) async {
    final res = await _client.delete(_uri(path), headers: await _headers(path));
    return _handle(res);
  }

  /// Returns the decoded JSON body for 2xx (or `null` for an empty/204 body),
  /// and throws the matching exception for everything else.
  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    String code;
    try {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      code = (decoded['error'] as Map?)?['code'] as String? ?? 'invalidRequest';
    } catch (_) {
      code = 'invalidRequest';
    }
    _throwFor(res.statusCode, code);
  }

  Never _throwFor(int status, String code) {
    for (final e in AuthError.values) {
      if (e.name == code) throw AuthException(e);
    }
    for (final e in PartnershipError.values) {
      if (e.name == code) throw PartnershipException(e);
    }
    throw ApiException(status, code);
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  @override
  Future<AuthSession> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _post('/auth/signup', {
      'name': name,
      'email': email,
      'password': password,
    });
    return _session(json as Map<String, dynamic>);
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    return _session(json as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _post('/auth/logout');
    await _clearToken();
  }

  Future<AuthSession> _session(Map<String, dynamic> json) async {
    final token = json['token'] as String;
    await _setToken(token);
    return AuthSession(
      token: token,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  // ---------------------------------------------------------------------------
  // User & onboarding
  // ---------------------------------------------------------------------------

  @override
  Future<User> getMe() async =>
      User.fromJson(await _get('/me') as Map<String, dynamic>);

  @override
  Future<User> updateMe(User user) async =>
      User.fromJson(await _put('/me', user.toJson()) as Map<String, dynamic>);

  @override
  Future<User> completeOnboarding({
    required String currencyCode,
    required double monthlyBudget,
    required Goal primaryGoal,
    required SpendingPersonality personality,
  }) async {
    final json = await _post('/onboarding', {
      'currencyCode': currencyCode,
      'monthlyBudget': monthlyBudget,
      'primaryGoal': primaryGoal.toJson(),
      'personality': personality.name,
    });
    return User.fromJson(json as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // Transactions
  // ---------------------------------------------------------------------------

  @override
  Future<List<Transaction>> getTransactions({
    DateTime? from,
    DateTime? to,
    String? categoryId,
  }) async {
    final query = <String, String>{
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
      if (categoryId != null) 'category': categoryId,
    };
    final list = await _get('/transactions', query) as List;
    return [
      for (final e in list) Transaction.fromJson(e as Map<String, dynamic>),
    ];
  }

  @override
  Future<Transaction> createTransaction(Transaction tx) async {
    final body = tx.toJson()..remove('id');
    final json = await _post('/transactions', body);
    return Transaction.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<Transaction> updateTransaction(Transaction tx) async {
    final json = await _put('/transactions/${tx.id}', tx.toJson());
    return Transaction.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTransaction(String id) => _delete('/transactions/$id');

  @override
  Future<void> ensureRecurringTransactions() =>
      _post('/transactions/ensure-recurring');

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  @override
  Future<List<Category>> getCategories() async {
    final list = await _get('/categories') as List;
    return [for (final e in list) Category.fromJson(e as Map<String, dynamic>)];
  }

  @override
  Future<Category> createCategory(Category category) async {
    final body = category.toJson()..remove('id');
    final json = await _post('/categories', body);
    return Category.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final json = await _put('/categories/${category.id}', category.toJson());
    return Category.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCategory(String id) => _delete('/categories/$id');

  // ---------------------------------------------------------------------------
  // Goals
  // ---------------------------------------------------------------------------

  @override
  Future<List<Goal>> getGoals() async {
    final list = await _get('/goals') as List;
    return [for (final e in list) Goal.fromJson(e as Map<String, dynamic>)];
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    final body = goal.toJson()..remove('id');
    final json = await _post('/goals', body);
    return Goal.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final json = await _patch('/goals/${goal.id}', goal.toJson());
    return Goal.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> deleteGoal(String id) => _delete('/goals/$id');

  @override
  Future<Goal> boostGoal({
    required String goalId,
    required double amount,
    String? contributorUserId,
  }) async {
    final json = await _post('/goals/$goalId/boost', {
      'amount': amount,
      if (contributorUserId != null) 'contributorUserId': contributorUserId,
    });
    return Goal.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<Goal> depositToSharedPot({
    required String goalId,
    required double amount,
    String? contributorUserId,
  }) async {
    final json = await _post('/goals/$goalId/pot-deposit', {
      'amount': amount,
      if (contributorUserId != null) 'contributorUserId': contributorUserId,
    });
    return Goal.fromJson(json as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // Insights & streak
  // ---------------------------------------------------------------------------

  @override
  Future<List<Insight>> getInsights() async {
    final list = await _get('/insights') as List;
    return [for (final e in list) Insight.fromJson(e as Map<String, dynamic>)];
  }

  @override
  Future<StreakInfo> getStreak() async {
    final json = await _get('/streak') as Map<String, dynamic>;
    return StreakInfo(
      current: (json['current'] as num?)?.toInt() ?? 0,
      longest: (json['longest'] as num?)?.toInt() ?? 0,
      lastLogDate: json['lastLogDate'] == null
          ? null
          : DateTime.parse(json['lastLogDate'] as String),
    );
  }

  // ---------------------------------------------------------------------------
  // Partnership (Phase 9)
  // ---------------------------------------------------------------------------

  @override
  Future<PartnershipStatus> invitePartner(String email) async {
    final json = await _post('/partnership/invite', {'email': email});
    final status = (json as Map<String, dynamic>)['status'] as String?;
    return PartnershipStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => PartnershipStatus.pendingOutbound,
    );
  }

  @override
  Future<PendingInvite?> getPendingInvite() async {
    try {
      final json = await _get('/partnership/pending');
      return PendingInvite.fromJson(json as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Partnership> acceptPartnership() async =>
      Partnership.fromJson(await _post('/partnership/accept') as Map<String, dynamic>);

  @override
  Future<void> declinePartnership() => _post('/partnership/decline');

  @override
  Future<void> unlinkPartnership() => _delete('/partnership');

  @override
  Future<PartnerSummary> getPartnerSummary() async => PartnerSummary.fromJson(
    await _get('/partnership/partner-summary') as Map<String, dynamic>,
  );

  @override
  Future<User?> getPartner() async {
    try {
      final json = await _get('/partnership/partner');
      return User.fromJson(json as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }
}
