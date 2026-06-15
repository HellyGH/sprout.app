import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

/// 90-day GitHub-style heatmap. Cell color encodes that day's spend as a
/// fraction of the user's daily target (`monthlyBudget / 30`). Tap a cell
/// to see that day's transactions.
class CalendarHeatmap extends StatelessWidget {
  const CalendarHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final budget = context.watch<BudgetController>();
    final user = budget.user;
    if (user == null) return const SizedBox.shrink();
    final dailyTarget = user.monthlyBudget > 0
        ? user.monthlyBudget / 30
        : 1;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 89));
    final perDay = <DateTime, double>{};
    for (final t in budget.transactions) {
      final d = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      if (d.isBefore(start)) continue;
      perDay.update(d, (v) => v + t.amount, ifAbsent: () => t.amount);
    }

    final cols = 13;
    final rows = 7;
    final lastDayOfWeek = today.weekday % 7;
    final totalCells = rows * cols;
    final pad = (rows - 1) - lastDayOfWeek;
    final dates = <DateTime?>[];
    for (int i = 0; i < totalCells - pad; i++) {
      dates.add(today.subtract(Duration(days: totalCells - pad - 1 - i)));
    }
    while (dates.length < totalCells) {
      dates.add(null);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
              const Text('📆', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                l.statsLast90Days,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 3.0;
              final cellSize =
                  (constraints.maxWidth - gap * (cols - 1)) / cols;
              return Column(
                children: [
                  for (int r = 0; r < rows; r++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: gap),
                      child: Row(
                        children: [
                          for (int c = 0; c < cols; c++) ...[
                            _Cell(
                              date: dates[r + c * rows],
                              spend: dates[r + c * rows] == null
                                  ? 0
                                  : perDay[dates[r + c * rows]!] ?? 0,
                              dailyTarget: dailyTarget.toDouble(),
                              size: cellSize,
                            ),
                            if (c < cols - 1) const SizedBox(width: gap),
                          ],
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          const _Legend(),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final DateTime? date;
  final double spend;
  final double dailyTarget;
  final double size;

  const _Cell({
    required this.date,
    required this.spend,
    required this.dailyTarget,
    required this.size,
  });

  Color get _color {
    if (date == null) return Colors.transparent;
    if (spend == 0) return const Color(0xFFE5E7EB);
    final ratio = spend / dailyTarget;
    if (ratio < 0.5) return const Color(0xFF86EFAC);
    if (ratio < 0.9) return const Color(0xFF3FBF7F);
    if (ratio < 1.1) return const Color(0xFFFBBF24);
    return const Color(0xFFFF6B6B);
  }

  @override
  Widget build(BuildContext context) {
    final cell = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
    if (date == null) return cell;
    return GestureDetector(
      onTap: () => _showDay(context, date!),
      child: cell,
    );
  }

  void _showDay(BuildContext context, DateTime day) {
    final budget = context.read<BudgetController>();
    final code = budget.currency.code;
    final next = day.add(const Duration(days: 1));
    final txs = budget.transactions
        .where((t) => !t.dateTime.isBefore(day) && t.dateTime.isBefore(next))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DaySheet(
        day: day,
        txs: txs,
        currencyCode: code,
        controller: budget,
      ),
    );
  }
}

class _DaySheet extends StatelessWidget {
  final DateTime day;
  final List<Transaction> txs;
  final String currencyCode;
  final BudgetController controller;

  const _DaySheet({
    required this.day,
    required this.txs,
    required this.currencyCode,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final total = txs.fold<double>(0, (s, t) => s + t.amount);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFEDF1F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            formatRelativeShort(
              day,
              today: l.dateToday,
              yesterday: l.dateYesterday,
              locale: localeStr,
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            txs.isEmpty
                ? l.statsNoSpendDay
                : l.statsDaySummary(
                    formatCurrency(total, currencyCode, locale: localeStr),
                    l.statsLogsCount(txs.length),
                  ),
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          if (txs.isEmpty)
            const SizedBox.shrink()
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: txs.length,
                itemBuilder: (_, i) {
                  final t = txs[i];
                  final cat = controller.categoryById(t.categoryId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          if (cat != null) ...[
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: cat.color,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cat.icon,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Text(
                              t.note?.isNotEmpty == true
                                  ? t.note!
                                  : (cat == null
                                      ? '—'
                                      : categoryDisplayName(l, cat)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            formatCurrency(t.amount, currencyCode,
                                locale: localeStr),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget swatch(Color c) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(2),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          l.statsHeatmapLess,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const SizedBox(width: 4),
        swatch(const Color(0xFFE5E7EB)),
        swatch(const Color(0xFF86EFAC)),
        swatch(const Color(0xFF3FBF7F)),
        swatch(const Color(0xFFFBBF24)),
        swatch(const Color(0xFFFF6B6B)),
        const SizedBox(width: 4),
        Text(
          l.statsHeatmapMore,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}
