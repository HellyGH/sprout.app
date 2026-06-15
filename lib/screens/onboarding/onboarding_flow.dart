import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/currency.dart';
import '../../models/goal.dart';
import '../../models/user.dart';
import '../../state/budget_controller.dart';
import 'budget_step.dart';
import 'goal_step.dart';
import 'personality_quiz_step.dart';
import 'welcome_step.dart';

/// Mutable draft populated as the user steps through onboarding.
class OnboardingDraft {
  String currencyCode;
  double monthlyBudget;
  Goal? primaryGoal;
  SpendingPersonality? personality;

  OnboardingDraft({
    this.currencyCode = 'EUR',
    this.monthlyBudget = 400,
    this.primaryGoal,
    this.personality,
  });
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageCtrl = PageController();
  final _draft = OnboardingDraft();
  int _index = 0;
  bool _submitting = false;

  static const _steps = 4;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  bool get _canAdvance {
    switch (_index) {
      case 0:
        return true;
      case 1:
        return _draft.monthlyBudget > 0;
      case 2:
        final g = _draft.primaryGoal;
        return g != null && g.name.trim().isNotEmpty && g.targetAmount > 0;
      case 3:
        return _draft.personality != null;
      default:
        return false;
    }
  }

  Future<void> _next() async {
    if (_index < _steps - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await context.read<BudgetController>().completeOnboarding(
        currency: Currency.fromCode(_draft.currencyCode),
        monthlyBudget: _draft.monthlyBudget,
        primaryGoal: _draft.primaryGoal!,
        personality: _draft.personality!,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _back() {
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _steps - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  const WelcomeStep(),
                  BudgetStep(
                    draft: _draft,
                    onChanged: () => setState(() {}),
                  ),
                  GoalStep(
                    draft: _draft,
                    onChanged: () => setState(() {}),
                  ),
                  PersonalityQuizStep(
                    draft: _draft,
                    onChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
            _Footer(
              index: _index,
              steps: _steps,
              canAdvance: _canAdvance,
              isLast: isLast,
              submitting: _submitting,
              onNext: _next,
              onBack: _index == 0 ? null : _back,
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final int index;
  final int steps;
  final bool canAdvance;
  final bool isLast;
  final bool submitting;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const _Footer({
    required this.index,
    required this.steps,
    required this.canAdvance,
    required this.isLast,
    required this.submitting,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < steps; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == index
                        ? Colors.deepPurple
                        : Colors.deepPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: onBack == null
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: onBack,
                        child: Text(
                          l.commonBack,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: (canAdvance && !submitting) ? onNext : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isLast ? l.onbLetsGrow : l.commonNext,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(width: 80),
            ],
          ),
        ],
      ),
    );
  }
}
