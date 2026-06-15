import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart' as model;
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

class WhatIfSimulator extends StatefulWidget {
  const WhatIfSimulator({super.key});

  @override
  State<WhatIfSimulator> createState() => _WhatIfSimulatorState();
}

class _WhatIfSimulatorState extends State<WhatIfSimulator> {
  String? _categoryId;
  double _cutPercent = 30;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final goal = budget.primaryGoal;
    final spendByCat = budget.spendByCategoryThisMonth;
    final code = budget.currency.code;

    if (goal == null) {
      return _shell(
        title: l.whatIfTitle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            l.whatIfEmpty,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    final cats = budget.categories;
    if (cats.isEmpty) return const SizedBox.shrink();
    final defaultCat = () {
      final sorted = [...cats]..sort(
          (a, b) =>
              (spendByCat[b.id] ?? 0).compareTo(spendByCat[a.id] ?? 0),
        );
      return sorted.first;
    }();
    final selected = cats.firstWhere(
      (c) => c.id == _categoryId,
      orElse: () => defaultCat,
    );

    final monthlySpend = spendByCat[selected.id] ?? 0;
    final monthlySaved = monthlySpend * (_cutPercent / 100);
    final weeklySaved = monthlySaved / 4.33;
    final remaining = (goal.targetAmount - goal.currentAmount).clamp(
      0.0,
      double.infinity,
    );
    final weeksToGoal = weeklySaved > 0 ? remaining / weeklySaved : null;

    return _shell(
      title: l.whatIfTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.whatIfCutByPercent(
                categoryDisplayName(l, selected), _cutPercent.round()),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                height: 1.4,
              ),
              children: [
                TextSpan(text: l.whatIfSave),
                TextSpan(
                  text: l.whatIfPerMonth(
                    formatCurrencyRounded(monthlySaved, code,
                        locale: localeStr),
                  ),
                  style: TextStyle(
                    color: selected.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: l.whatIfReach),
                TextSpan(
                  text: goal.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (weeksToGoal != null) ...[
                  TextSpan(text: l.whatIfIn),
                  TextSpan(
                    text: l.whatIfWeeks(weeksToGoal.round()),
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else ...[
                  TextSpan(text: l.whatIfNoTick),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: selected.color,
              thumbColor: selected.color,
              inactiveTrackColor: selected.color.withValues(alpha: 0.18),
              overlayColor: selected.color.withValues(alpha: 0.15),
            ),
            child: Slider(
              min: 0,
              max: 100,
              divisions: 20,
              value: _cutPercent,
              onChanged: (v) => setState(() => _cutPercent = v),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in cats)
                _CategoryPill(
                  category: c,
                  selected: c.id == selected.id,
                  onTap: () => setState(() => _categoryId = c.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shell({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔮', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final model.Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? category.color.withValues(alpha: 0.16)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? category.color : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 14, color: category.color),
            const SizedBox(width: 4),
            Text(
              categoryDisplayName(l, category),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? category.color : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
