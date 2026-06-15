import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/insight.dart';
import '../../state/budget_controller.dart';
import '../../widgets/calendar_heatmap.dart';
import '../../widgets/category_card.dart';
import '../../widgets/donut_chart_card.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/what_if_simulator.dart';
import '../category_detail/category_detail_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetController>();
    final byCategory = budget.spendByCategoryThisMonth;
    final currencyCode = budget.currency.code;
    final localeStr = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final monthLabel =
        '${DateFormat.MMMM(localeStr).format(now)} ${now.year}';
    final latte = budget.insightOf(InsightKind.latteFactor);
    final mood = budget.insightOf(InsightKind.moodPattern);
    final recap = budget.insightOf(InsightKind.weeklyRecap);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<BudgetController>().bootstrap(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (recap != null) ...[
                InsightCard(insight: recap),
                const SizedBox(height: 10),
              ],
              const CalendarHeatmap(),
              const SizedBox(height: 12),
              if (latte != null) ...[
                InsightCard(insight: latte),
                const SizedBox(height: 10),
              ],
              DonutChartCard(
                currencyCode: currencyCode,
                currentMonth: monthLabel,
                slices: [
                  for (final cat in budget.categories)
                    DonutSlice(
                      label: cat.name,
                      value: byCategory[cat.id] ?? 0,
                      color: cat.color,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const WhatIfSimulator(),
              if (mood != null) ...[
                const SizedBox(height: 10),
                InsightCard(insight: mood),
              ],
              const SizedBox(height: 10),
              for (final cat in budget.categories)
                CategoryCard(
                  category: cat,
                  spent: byCategory[cat.id] ?? 0,
                  currencyCode: currencyCode,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CategoryDetailScreen(categoryId: cat.id),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
