import 'dart:convert';

import 'package:finance_app/models/category.dart';
import 'package:finance_app/models/goal.dart';
import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Round-trips every model through jsonEncode → jsonDecode → fromJson
/// and asserts every field survives. Catches the "I added a field to
/// toJson but forgot fromJson" class of bug on next save.
void main() {
  test('User round-trips with every Phase 1-8 field populated', () {
    final original = User(
      id: 'u1',
      name: 'Val',
      email: 'val@example.com',
      currencyCode: 'BGN',
      monthlyBudget: 567.89,
      themeAccent: '#FF6B6B',
      hasOnboarded: true,
      personality: SpendingPersonality.goalChaser,
      cooldownEnabled: true,
      cooldownThreshold: 75,
      cooldownSaved: 123.45,
      cooldownWinCount: 7,
      noSpendDays: [
        DateTime(2026, 5, 20),
        DateTime(2026, 5, 21),
      ],
      themeMode: ThemePreference.dark,
      roundUpEnabled: true,
      languageCode: 'bg',
    );

    final round = User.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );

    expect(round.id, original.id);
    expect(round.name, original.name);
    expect(round.email, original.email);
    expect(round.currencyCode, original.currencyCode);
    expect(round.monthlyBudget, original.monthlyBudget);
    expect(round.themeAccent, original.themeAccent);
    expect(round.hasOnboarded, original.hasOnboarded);
    expect(round.personality, SpendingPersonality.goalChaser);
    expect(round.cooldownEnabled, true);
    expect(round.cooldownThreshold, 75);
    expect(round.cooldownSaved, 123.45);
    expect(round.cooldownWinCount, 7);
    expect(round.noSpendDays.length, 2);
    expect(round.noSpendDays.first, DateTime(2026, 5, 20));
    expect(round.themeMode, ThemePreference.dark);
    expect(round.roundUpEnabled, true);
    expect(round.languageCode, 'bg');
  });

  test('User defaults safely when optional fields are absent', () {
    final partial = jsonDecode(jsonEncode({
      'id': 'u2',
      'name': 'Guest',
      'email': 'guest@local',
    })) as Map<String, dynamic>;
    final round = User.fromJson(partial);
    expect(round.currencyCode, 'EUR');
    expect(round.themeMode, ThemePreference.system);
    expect(round.languageCode, isNull);
    expect(round.noSpendDays, isEmpty);
  });

  test('Transaction round-trips, including nullable note/mood + isPlanned', () {
    final original = Transaction(
      id: 't1',
      dateTime: DateTime(2026, 5, 24, 14, 30),
      amount: 12.5,
      currencyCode: 'EUR',
      categoryId: 'cat_coffee',
      note: 'Latte',
      mood: 4,
      isPlanned: true,
      createdAt: DateTime(2026, 5, 24, 14, 30, 1),
    );
    final round = Transaction.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );
    expect(round.id, 't1');
    expect(round.dateTime, original.dateTime);
    expect(round.amount, 12.5);
    expect(round.currencyCode, 'EUR');
    expect(round.categoryId, 'cat_coffee');
    expect(round.note, 'Latte');
    expect(round.mood, 4);
    expect(round.isPlanned, true);
    expect(round.createdAt, original.createdAt);
  });

  test('Goal round-trips including nested boosts list', () {
    final original = Goal(
      id: 'g1',
      name: 'Tokyo trip',
      icon: Icons.flight_takeoff_rounded,
      color: const Color(0xFF2765CF),
      targetAmount: 1200,
      currentAmount: 350,
      deadline: DateTime(2026, 12, 31),
      boosts: [
        GoalBoost(amount: 100, dateTime: DateTime(2026, 5, 1)),
        GoalBoost(amount: 250, dateTime: DateTime(2026, 5, 20)),
      ],
    );
    final round = Goal.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );
    expect(round.id, 'g1');
    expect(round.name, 'Tokyo trip');
    expect(round.icon.codePoint, Icons.flight_takeoff_rounded.codePoint);
    expect(round.color.toARGB32(), const Color(0xFF2765CF).toARGB32());
    expect(round.targetAmount, 1200);
    expect(round.currentAmount, 350);
    expect(round.deadline, DateTime(2026, 12, 31));
    expect(round.boosts.length, 2);
    expect(round.boosts[0].amount, 100);
    expect(round.boosts[0].dateTime, DateTime(2026, 5, 1));
    expect(round.boosts[1].amount, 250);
    expect(round.progress, closeTo(0.291, 0.01));
    expect(round.isComplete, false);
  });

  test('Category round-trips with IconData + Color', () {
    const original = Category(
      id: 'cat_custom',
      name: 'Books',
      icon: Icons.auto_stories_rounded,
      color: Color(0xFFA67149),
      monthlyCap: 45,
    );
    final round = Category.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );
    expect(round.id, 'cat_custom');
    expect(round.name, 'Books');
    expect(round.icon.codePoint, Icons.auto_stories_rounded.codePoint);
    expect(round.color.toARGB32(), const Color(0xFFA67149).toARGB32());
    expect(round.monthlyCap, 45);
  });
}
