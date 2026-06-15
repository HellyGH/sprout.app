import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/budget_controller.dart';
import '../../utils/formatters.dart';
import '../../widgets/achievement_badges.dart';
import '../../widgets/add_category_sheet.dart';
import '../../widgets/amount_entry_sheet.dart';
import '../../widgets/budget_top_up_sheet.dart';
import '../../widgets/partner_panel.dart';
import '../../widgets/recurring_list.dart';
import '../../widgets/language_panel.dart';
import '../../widgets/round_up_panel.dart';
import '../../widgets/streak_chip.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final user = budget.user;
    final code = budget.currency.code;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Text(
            user?.name ?? l.navYou,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _StatTile(
            label: l.youMonthlyBudget,
            value: formatCurrencyRounded(
                user?.monthlyBudget ?? 0, code,
                locale: localeStr),
            onTap: () async {
              final controller = context.read<BudgetController>();
              final amount = await showAmountEntrySheet(
                context,
                title: l.youMonthlyBudget,
                subtitle: l.editBudgetSubtitle,
                confirmLabel: l.commonSave,
                initialValue: user?.monthlyBudget ?? 0,
                max: kMaxMonthlyBudget,
              );
              if (amount != null) await controller.setMonthlyBudget(amount);
            },
          ),
          if (budget.topUpThisMonth > 0)
            _StatTile(
              label: l.youTopUpThisMonth(
                formatCurrencyRounded(budget.topUpThisMonth, code,
                    locale: localeStr),
              ),
              value: '🌱',
            ),
          _StatTile(
            label: l.youSpentThisMonth,
            value: formatCurrency(
                budget.spentThisMonth, code,
                locale: localeStr),
          ),
          _ActionTile(
            icon: Icons.add_card_rounded,
            label: l.youTopUpAction,
            color: const Color(0xFF3FBF7F),
            onTap: () => showBudgetTopUpSheet(context),
          ),
          const SizedBox(height: 10),
          const StreakBigCard(),
          const SizedBox(height: 10),
          if (user != null && user.cooldownSaved > 0)
            _StatTile(
              label: l.youTalkedOutOf,
              value:
                  '${formatCurrencyRounded(user.cooldownSaved, code, locale: localeStr)} 🌱',
            ),
          const SizedBox(height: 16),
          if (user != null) const _CooldownPanel(),
          const SizedBox(height: 10),
          const RoundUpPanel(),
          const SizedBox(height: 16),
          const RecurringList(),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.add_circle_outline_rounded,
            label: l.youAddCategory,
            color: Theme.of(context).colorScheme.primary,
            onTap: () => showAddCategorySheet(context),
          ),
          const SizedBox(height: 16),
          const LanguagePanel(),
          const SizedBox(height: 18),
          const AchievementBadges(),
          const SizedBox(height: 18),
          const PartnerPanel(),
          const SizedBox(height: 18),
          _LogoutTile(
            onTap: () => context.read<BudgetController>().logout(),
          ),
          const SizedBox(height: 18),
          const _VersionLabel(),
        ],
      ),
    );
  }
}

/// App version label.
class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Sprout v1.0',
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.28),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CooldownPanel extends StatelessWidget {
  const _CooldownPanel();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final user = budget.user!;
    final code = budget.currency.code;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
        children: [
          Row(
            children: [
              Icon(
                Icons.self_improvement_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.youCooldownTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.youCooldownSubtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: user.cooldownEnabled,
                activeThumbColor: Theme.of(context).colorScheme.primary,
                onChanged: (v) =>
                    context.read<BudgetController>().setCooldownEnabled(v),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: user.cooldownEnabled
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l.youCooldownTriggerAbove,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              formatCurrencyRounded(
                                  user.cooldownThreshold, code,
                                  locale: localeStr),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor:
                                Theme.of(context).colorScheme.primary,
                            thumbColor:
                                Theme.of(context).colorScheme.primary,
                            inactiveTrackColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.18),
                            overlayColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.15),
                          ),
                          child: Slider(
                            min: 5,
                            max: 200,
                            divisions: 39,
                            value: user.cooldownThreshold.clamp(5, 200),
                            onChanged: (v) => context
                                .read<BudgetController>()
                                .setCooldownThreshold(v),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFFFF6B6B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                l.youLogOut,
                style: const TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatTile({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Row(
            children: [
              Text(
                value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.edit_rounded,
                    size: 16, color: Colors.black38),
              ],
            ],
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}
