import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/goal.dart';
import '../models/partnership.dart';
import '../utils/formatters.dart';
import 'partner_common.dart';

/// Card for a goal jointly owned with a partner. Shows both partners' avatars,
/// a funding-mode badge (split / shared pot), and a brand-gradient progress
/// bar. Reused on the Goals "Together" section and the Together tab.
class SharedGoalCard extends StatelessWidget {
  final Goal goal;
  final String currencyCode;
  final String localeStr;
  final String meName;
  final String partnerName;
  final VoidCallback onTap;

  const SharedGoalCard({
    super.key,
    required this.goal,
    required this.currencyCode,
    required this.localeStr,
    required this.meName,
    required this.partnerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final badge = goal.fundingMode == GoalFundingMode.sharedPot
        ? l.goalFundingPot
        : l.goalFundingSplit;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: goal.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(goal.icon, color: goal.color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      goal.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  _Badge(label: badge, color: accent),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Stack(
                      children: [
                        PartnerAvatar(name: meName, color: accent),
                        Positioned(
                          left: 16,
                          child: PartnerAvatar(
                            name: partnerName,
                            color: goal.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: goal.progress),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => Stack(
                          children: [
                            Container(
                              height: 10,
                              color: Colors.grey.shade200,
                            ),
                            FractionallySizedBox(
                              widthFactor: v.clamp(0.0, 1.0),
                              child: Container(
                                height: 10,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF2765CF),
                                      Color(0xFF633CA5),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${formatCurrencyRounded(goal.currentAmount, currencyCode, locale: localeStr)} ${l.goalOfTarget(formatCurrencyRounded(goal.targetAmount, currencyCode, locale: localeStr))}',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
