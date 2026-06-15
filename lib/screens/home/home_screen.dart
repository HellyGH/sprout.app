import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/budget_controller.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/bar_chart_card.dart';
import '../../widgets/budget_top_up_sheet.dart';
import '../../widgets/category_card.dart';
import '../../widgets/header.dart';
import '../../widgets/nudge_banner.dart';
import '../../widgets/partner_home_card.dart';
import '../../widgets/sprout_mascot.dart';
import '../add_transaction/add_transaction_sheet.dart';
import '../category_detail/category_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final budget = context.watch<BudgetController>();
    final user = budget.user;
    final byCategory = budget.spendByCategoryThisMonth;
    final monthlyBudget = budget.effectiveMonthlyBudget;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<BudgetController>().bootstrap(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Header(),
            const SizedBox(height: 14),
            const NudgeBanner(),
            const _NoSpendCta(),
            const SizedBox(height: 14),
            BalanceCard(
              remaining: budget.remainingThisMonth,
              monthlyBudget: monthlyBudget,
              currency: budget.currency,
              isOverBudget: budget.isOverBudget,
              onSelectCurrency: (c) async {
                if (user == null) return;
                final controller = context.read<BudgetController>();
                await controller.api.updateMe(
                  user.copyWith(currencyCode: c.code),
                );
                await controller.bootstrap();
              },
              onLogSpend: () => showAddTransactionSheet(context),
              onTopUp: () => showBudgetTopUpSheet(context),
            ),
            const SizedBox(height: 14),
            const PartnerHomeCard(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '  ${l.homeSpending}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BarChartCard(totalSpent: budget.spentThisMonth),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '  ${l.homeCategories}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            for (final cat in budget.categories)
              CategoryCard(
                category: cat,
                spent: byCategory[cat.id] ?? 0,
                currencyCode: budget.currency.code,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CategoryDetailScreen(categoryId: cat.id),
                  ),
                ),
              ),
            if (budget.categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      const SproutMascot(
                        state: SproutState.waving,
                        size: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.homeNoCategoriesTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.homeNoCategoriesBody,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.55),
                          fontSize: 13,
                        ),
                      ),
                    ],
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

class _NoSpendCta extends StatelessWidget {
  const _NoSpendCta();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final budget = context.watch<BudgetController>();
    if (budget.todayHasTransaction || budget.isTodayNoSpend) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: () => context.read<BudgetController>().markTodayNoSpend(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF3FBF7F).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Text('🌿', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.homeMarkNoSpend,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1F7A4F),
                  ),
                ),
              ),
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF3FBF7F),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
