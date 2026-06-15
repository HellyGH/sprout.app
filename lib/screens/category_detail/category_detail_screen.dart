import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category.dart' as model;
import '../../models/transaction.dart';
import '../../state/budget_controller.dart';
import '../../utils/formatters.dart';
import '../../widgets/category_sparkline.dart';
import '../add_transaction/add_transaction_sheet.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryId;

  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final budget = context.watch<BudgetController>();
    final category = budget.categoryById(categoryId);
    if (category == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(child: Text(l.categoryNotFound)),
        ),
      );
    }
    final txs =
        budget.transactions.where((t) => t.categoryId == categoryId).toList();
    final spent = budget.spendByCategoryThisMonth[categoryId] ?? 0;
    final cap = category.monthlyCap;
    final ratio = cap <= 0 ? 0.0 : (spent / cap).clamp(0.0, 1.5);
    final overCap = spent > cap;
    final progressColor = overCap
        ? const Color(0xFFFF6B6B)
        : ratio > 0.9
            ? Colors.amber.shade700
            : category.color;
    final currency = budget.currency.code;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category.icon,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        categoryDisplayName(l, category),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_rounded),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => showAddTransactionSheet(
                        context,
                        presetCategoryId: categoryId,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _SummaryCard(
                  spent: spent,
                  cap: cap,
                  ratio: ratio.clamp(0.0, 1.0),
                  progressColor: progressColor,
                  overCap: overCap,
                  currencyCode: currency,
                  txs: txs,
                  color: category.color,
                  onAdjust: () => _openAdjustCap(context, category),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l.categoryDetailTransactions,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l.categoryDetailTotalCount(txs.length),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (txs.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 32),
                  child: Center(
                    child: Text(
                      l.categoryDetailEmpty,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: txs.length,
                  itemBuilder: (context, i) {
                    final tx = txs[i];
                    return _TransactionRow(
                      key: ValueKey(tx.id),
                      tx: tx,
                      currencyCode: currency,
                      onTap: () => showAddTransactionSheet(
                        context,
                        editing: tx,
                      ),
                      onDelete: () => context
                          .read<BudgetController>()
                          .deleteTransaction(tx.id),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  void _openAdjustCap(BuildContext context, model.Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdjustCapSheet(category: category),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double spent;
  final double cap;
  final double ratio;
  final Color progressColor;
  final bool overCap;
  final String currencyCode;
  final List<Transaction> txs;
  final Color color;
  final VoidCallback onAdjust;

  const _SummaryCard({
    required this.spent,
    required this.cap,
    required this.ratio,
    required this.progressColor,
    required this.overCap,
    required this.currencyCode,
    required this.txs,
    required this.color,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(spent, currencyCode, locale: localeStr),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: overCap ? const Color(0xFFFF6B6B) : Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  l.categoryDetailSpentOfCap(
                    formatCurrencyRounded(cap, currencyCode,
                        locale: localeStr),
                  ),
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.categoryDetailLast30,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          CategorySparkline(transactions: txs, color: color),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAdjust,
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: Text(l.categoryDetailAdjustCap),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction tx;
  final String currencyCode;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  const _TransactionRow({
    super.key,
    required this.tx,
    required this.currencyCode,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final amountFormatted =
        formatCurrency(tx.amount, currencyCode, locale: localeStr);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey('tx_${tx.id}'),
        direction: DismissDirection.endToStart,
        background: const SizedBox.shrink(),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline_rounded, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                l.commonDelete,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l.categoryDetailDeleteTxTitle),
              content: Text(
                tx.note?.isNotEmpty == true
                    ? l.categoryDetailDeleteTxNote(tx.note!, amountFormatted)
                    : l.categoryDetailDeleteTxNoNote(amountFormatted),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l.commonKeep),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B6B),
                  ),
                  child: Text(l.commonDelete),
                ),
              ],
            ),
          );
          return ok ?? false;
        },
        onDismissed: (_) => onDelete(),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                tx.note?.isNotEmpty == true ? tx.note! : '—',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (tx.isPlanned) ...[
                              const SizedBox(width: 6),
                              const Text('🔁',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatRelativeShort(
                            tx.dateTime,
                            today: l.dateToday,
                            yesterday: l.dateYesterday,
                            locale: localeStr,
                          ),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    amountFormatted,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Share total with partner" toggle inside the cap sheet. Disabled (with a
/// "link a partner first" helper) when the user isn't partnered.
class _ShareToggle extends StatelessWidget {
  final bool shared;
  final ValueChanged<bool> onChanged;

  const _ShareToggle({required this.shared, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final partnered = context.watch<BudgetController>().isPartnered;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 20,
                color: partnered ? accent : Colors.black26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.categoryShareToggle,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: partnered ? Colors.black87 : Colors.black38,
                  ),
                ),
              ),
              Switch.adaptive(
                value: shared && partnered,
                onChanged: partnered ? onChanged : null,
                activeThumbColor: accent,
              ),
            ],
          ),
          Text(
            partnered ? l.categoryShareHelper : l.categoryShareLinkFirst,
            style: const TextStyle(color: Colors.black45, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AdjustCapSheet extends StatefulWidget {
  final model.Category category;

  const _AdjustCapSheet({required this.category});

  @override
  State<_AdjustCapSheet> createState() => _AdjustCapSheetState();
}

class _AdjustCapSheetState extends State<_AdjustCapSheet> {
  late double _cap = widget.category.monthlyCap;
  late bool _shared = widget.category.sharedWithPartner;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final controller = context.read<BudgetController>();
      await controller.updateCategory(
        widget.category.copyWith(monthlyCap: _cap, sharedWithPartner: _shared),
      );
      if (controller.isPartnered) await controller.refreshPartnerSummary();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final code = context.read<BudgetController>().currency.code;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
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
            l.adjustCapTitle(categoryDisplayName(l, widget.category)),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.adjustCapSubtitle,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              formatCurrencyRounded(_cap, code, locale: localeStr),
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.category.color,
              thumbColor: widget.category.color,
              inactiveTrackColor:
                  widget.category.color.withValues(alpha: 0.18),
              overlayColor: widget.category.color.withValues(alpha: 0.15),
            ),
            child: Slider(
              min: 10,
              max: 800,
              divisions: 79,
              value: _cap.clamp(10, 800),
              onChanged: (v) => setState(() => _cap = v),
            ),
          ),
          const SizedBox(height: 8),
          _ShareToggle(
            shared: _shared,
            onChanged: (v) => setState(() => _shared = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(l.commonCancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l.commonSave,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
