import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

class _Template {
  final Transaction template;
  final int copies;
  const _Template(this.template, this.copies);
}

class RecurringList extends StatelessWidget {
  const RecurringList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final budget = context.watch<BudgetController>();
    final templates = _collect(budget.transactions);
    if (templates.isEmpty) return const SizedBox.shrink();
    final code = budget.currency.code;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: Text(
            l.youRecurringHeader,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
            children: [
              for (int i = 0; i < templates.length; i++) ...[
                _Row(
                  template: templates[i],
                  budget: budget,
                  currencyCode: code,
                ),
                if (i < templates.length - 1)
                  Divider(
                    height: 1,
                    indent: 56,
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<_Template> _collect(List<Transaction> txs) {
    final byKey = <String, List<Transaction>>{};
    for (final t in txs) {
      if (!t.isPlanned) continue;
      final key = '${t.categoryId}|${t.amount}|${t.note ?? ''}';
      byKey.putIfAbsent(key, () => []).add(t);
    }
    final out = <_Template>[];
    for (final entry in byKey.entries) {
      final list = entry.value
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      out.add(_Template(list.first, list.length));
    }
    out.sort((a, b) => a.template.amount.compareTo(b.template.amount));
    return out;
  }
}

class _Row extends StatelessWidget {
  final _Template template;
  final BudgetController budget;
  final String currencyCode;

  const _Row({
    required this.template,
    required this.budget,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final cat = budget.categoryById(template.template.categoryId);
    final accent = cat?.color ?? Theme.of(context).colorScheme.primary;
    final catName = cat == null ? '—' : categoryDisplayName(l, cat);
    final note = template.template.note?.isNotEmpty == true
        ? template.template.note!
        : catName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🔁', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cat == null
                      ? l.youRecurringAutoMonth
                      : l.youRecurringCategoryAutoMonth(catName),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(template.template.amount, currencyCode,
                locale: localeStr),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
