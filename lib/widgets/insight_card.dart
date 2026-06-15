import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/insight.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

class InsightCard extends StatelessWidget {
  final Insight insight;
  final VoidCallback? onAction;

  const InsightCard({super.key, required this.insight, this.onAction});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final controller = context.read<BudgetController>();
    final accent = _accentFor(insight.kind);
    final emoji = _emojiFor(insight.kind);
    final title = _title(l);
    final body = _body(l, localeStr, controller);
    final action = _action(l);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),
                if (action != null && onAction != null) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: accent,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        action,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _title(AppLocalizations l) {
    return switch (insight.kind) {
      InsightKind.weeklyRecap => l.insightWeeklyTitle,
      InsightKind.latteFactor => l.insightLatteTitle,
      InsightKind.moodPattern => l.insightMoodTitle,
      InsightKind.achievement => '',
    };
  }

  String _body(
    AppLocalizations l,
    String localeStr,
    BudgetController controller,
  ) {
    final d = insight.data;
    switch (insight.kind) {
      case InsightKind.weeklyRecap:
        final code = d['currencyCode'] as String? ?? 'EUR';
        final count = (d['count'] as int?) ?? 0;
        final total = (d['total'] as num?)?.toDouble() ?? 0;
        final topCategoryId = d['topCategoryId'] as String? ?? '';
        final topCategoryCat = controller.categoryById(topCategoryId);
        final topCategory = topCategoryCat == null
            ? (d['topCategory'] as String? ?? '')
            : categoryDisplayName(l, topCategoryCat);
        final topAmount = (d['topAmount'] as num?)?.toDouble() ?? 0;
        final topGoalName = d['topGoalName'] as String?;
        final topGoalAmount =
            (d['topGoalAmount'] as num?)?.toDouble() ?? 0;
        final streak = (d['streak'] as int?) ?? 0;
        final goalLine = (topGoalName != null && topGoalAmount > 0)
            ? l.insightWeeklyGoalLine(
                topGoalName,
                formatCurrencyRounded(topGoalAmount, code,
                    locale: localeStr),
              )
            : '';
        return l.insightWeeklyBody(
          count,
          formatCurrencyRounded(total, code, locale: localeStr),
          topCategory,
          formatCurrencyRounded(topAmount, code, locale: localeStr),
          goalLine,
          streak,
        );
      case InsightKind.latteFactor:
        final code = d['currencyCode'] as String? ?? 'EUR';
        final spent = (d['spent'] as num?)?.toDouble() ?? 0;
        final yearly = (d['yearly'] as num?)?.toDouble() ?? 0;
        return l.insightLatteBody(
          formatCurrencyRounded(spent, code, locale: localeStr),
          formatCurrencyRounded(yearly, code, locale: localeStr),
        );
      case InsightKind.moodPattern:
        final ratio = (d['ratio'] as num?)?.toDouble() ?? 1.0;
        return l.insightMoodBody(ratio.toStringAsFixed(1));
      case InsightKind.achievement:
        return '';
    }
  }

  String? _action(AppLocalizations l) {
    return switch (insight.kind) {
      InsightKind.latteFactor => l.insightLatteAction,
      _ => null,
    };
  }

  Color _accentFor(InsightKind kind) {
    switch (kind) {
      case InsightKind.latteFactor:
        return const Color(0xFFA67149);
      case InsightKind.moodPattern:
        return const Color(0xFFA78BFA);
      case InsightKind.weeklyRecap:
        return const Color(0xFF60A5FA);
      case InsightKind.achievement:
        return const Color(0xFF3FBF7F);
    }
  }

  String _emojiFor(InsightKind kind) {
    switch (kind) {
      case InsightKind.latteFactor:
        return '☕️';
      case InsightKind.moodPattern:
        return '💭';
      case InsightKind.weeklyRecap:
        return '📅';
      case InsightKind.achievement:
        return '🌱';
    }
  }
}
