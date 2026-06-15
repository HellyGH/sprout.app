import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/transaction.dart';
import '../../state/budget_controller.dart';
import '../../utils/formatters.dart';
import '../../widgets/create_shared_goal_sheet.dart';
import '../../widgets/partner_panel.dart';
import '../../widgets/shared_categories_sheet.dart';
import '../../widgets/shared_goal_card.dart';
import '../../widgets/sprout_mascot.dart';
import '../goals/shared_goal_detail_screen.dart';

/// Табът "Заедно". Винаги наличен (5-ти таб). Когато си сам, представя
/// функцията и позволява да поканиш партньор; когато си свързан, показва
/// таблото само със споделените данни. Тук нищо не разкрива общите финанси
/// на партньора.
class TogetherScreen extends StatefulWidget {
  const TogetherScreen({super.key});

  @override
  State<TogetherScreen> createState() => _TogetherScreenState();
}

class _TogetherScreenState extends State<TogetherScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Опресняване на споделените стойности, когато приложението се върне на преден план.
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<BudgetController>().refreshPartnerSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetController>();
    return SafeArea(
      child: budget.isPartnered ? const _LinkedView() : const _SoloView(),
    );
  }
}

class _SoloView extends StatelessWidget {
  const _SoloView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        const Center(child: SproutMascot(state: SproutState.waving, size: 110)),
        const SizedBox(height: 18),
        Text(
          l.togetherSoloTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l.togetherSoloBody,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
        const SizedBox(height: 24),
        const PartnerPanel(),
      ],
    );
  }
}

class _LinkedView extends StatelessWidget {
  const _LinkedView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final code = budget.currency.code;
    final meName = budget.user?.name ?? l.sharedGoalYou;
    final partnerName = budget.partner?.name ?? '';
    final summary = budget.partnerSummary;
    final sharedGoals = budget.sharedGoals;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final sharedTx = budget.transactions
        .where((t) => t.isShared && !t.dateTime.isBefore(monthStart))
        .toList();

    return RefreshIndicator(
      onRefresh: () => context.read<BudgetController>().refreshPartnerSummary(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            l.togetherHeader(partnerName),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          if (summary?.rateAsOf != null) ...[
            const SizedBox(height: 4),
            Text(
              l.togetherRatesAsOf(summary!.rateAsOf!),
              style: const TextStyle(color: Colors.black45, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),

          // Weekly recap pill.
          _WeeklyRecapPill(meName: meName),

          // Shared goals.
          _SectionHeader(title: l.togetherSharedGoals),
          if (sharedGoals.isEmpty)
            _EmptyNote(text: l.togetherNoSharedGoals)
          else
            ...sharedGoals.map(
              (g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SharedGoalCard(
                  goal: g,
                  currencyCode: code,
                  localeStr: localeStr,
                  meName: meName,
                  partnerName: partnerName,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SharedGoalDetailScreen(goalId: g.id),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => showCreateSharedGoalSheet(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l.togetherNewSharedGoal),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          // Shared this month.
          _SectionHeader(title: l.togetherSharedTxThisMonth),
          _SharedThisMonthCard(
            total: summary?.sharedTxThisMonthTotal ?? 0,
            transactions: sharedTx,
            currencyCode: code,
            localeStr: localeStr,
          ),

          // Shared categories.
          _SectionHeader(title: l.togetherSharedCategories),
          if (summary == null || summary.sharedCategoryTotals.isEmpty)
            _EmptyNote(text: l.togetherNoSharedCategories)
          else
            ...summary.sharedCategoryTotals.map((c) {
              // A category is "mine" if it exists in my own list; otherwise
              // it's the partner's (theirs to control).
              final mine = budget.categoryById(c.categoryId) != null;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            mine
                                ? l.togetherFromYou
                                : l.togetherFromPartner(partnerName),
                            style: const TextStyle(
                                color: Colors.black45, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatCurrency(c.total, code, locale: localeStr),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => showSharedCategoriesSheet(context),
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: Text(l.togetherManageShared),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRecapPill extends StatelessWidget {
  final String meName;
  const _WeeklyRecapPill({required this.meName});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final code = budget.currency.code;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // Most-funded shared goal in the last 7 days.
    String? goalName;
    double best = 0;
    for (final g in budget.sharedGoals) {
      final recent = g.boosts
          .where((b) => b.dateTime.isAfter(weekAgo))
          .fold<double>(0, (s, b) => s + b.amount);
      if (recent > best) {
        best = recent;
        goalName = g.name;
      }
    }
    if (goalName == null || best <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2765CF), Color(0xFF633CA5)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l.togetherWeeklyRecap(
                formatCurrencyRounded(best, code, locale: localeStr),
                goalName,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedThisMonthCard extends StatelessWidget {
  final double total;
  final List<Transaction> transactions;
  final String currencyCode;
  final String localeStr;

  const _SharedThisMonthCard({
    required this.total,
    required this.transactions,
    required this.currencyCode,
    required this.localeStr,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final budget = context.watch<BudgetController>();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatCurrency(total, currencyCode, locale: localeStr),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l.togetherNoSharedTx,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            )
          else
            ...transactions.map((t) {
              final cat = budget.categoryById(t.categoryId);
              final name = cat == null
                  ? ''
                  : categoryDisplayName(l, cat);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      cat?.icon ?? Icons.receipt_long_rounded,
                      size: 18,
                      color: cat?.color ?? Colors.black45,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.note?.isNotEmpty == true ? t.note! : name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      formatCurrency(t.amount, currencyCode, locale: localeStr),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 0, 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  final String text;
  const _EmptyNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black54, fontSize: 13),
      ),
    );
  }
}
