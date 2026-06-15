import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import 'onboarding_flow.dart';

class _Option {
  final String Function(AppLocalizations l) labelOf;
  final SpendingPersonality tag;
  const _Option(this.labelOf, this.tag);
}

class _Question {
  final String Function(AppLocalizations l) promptOf;
  final List<_Option> options;
  const _Question(this.promptOf, this.options);
}

final _questions = <_Question>[
  _Question((l) => l.onbQuizQ1, [
    _Option((l) => l.onbQuizQ1Saver, SpendingPersonality.saver),
    _Option((l) => l.onbQuizQ1Treater, SpendingPersonality.treater),
    _Option((l) => l.onbQuizQ1GoalChaser, SpendingPersonality.goalChaser),
    _Option((l) => l.onbQuizQ1Impulse, SpendingPersonality.impulse),
  ]),
  _Question((l) => l.onbQuizQ2, [
    _Option((l) => l.onbQuizQ2Saver, SpendingPersonality.saver),
    _Option((l) => l.onbQuizQ2Treater, SpendingPersonality.treater),
    _Option((l) => l.onbQuizQ2GoalChaser, SpendingPersonality.goalChaser),
    _Option((l) => l.onbQuizQ2Impulse, SpendingPersonality.impulse),
  ]),
  _Question((l) => l.onbQuizQ3, [
    _Option((l) => l.onbQuizQ3Saver, SpendingPersonality.saver),
    _Option((l) => l.onbQuizQ3Treater, SpendingPersonality.treater),
    _Option((l) => l.onbQuizQ3GoalChaser, SpendingPersonality.goalChaser),
    _Option((l) => l.onbQuizQ3Impulse, SpendingPersonality.impulse),
  ]),
  _Question((l) => l.onbQuizQ4, [
    _Option((l) => l.onbQuizQ4Daily, SpendingPersonality.saver),
    _Option((l) => l.onbQuizQ4Weekly, SpendingPersonality.goalChaser),
    _Option((l) => l.onbQuizQ4Monthly, SpendingPersonality.treater),
    _Option((l) => l.onbQuizQ4Decline, SpendingPersonality.impulse),
  ]),
  _Question((l) => l.onbQuizQ5, [
    _Option((l) => l.onbQuizQ5Saver, SpendingPersonality.saver),
    _Option((l) => l.onbQuizQ5Treater, SpendingPersonality.treater),
    _Option((l) => l.onbQuizQ5GoalChaser, SpendingPersonality.goalChaser),
    _Option((l) => l.onbQuizQ5Impulse, SpendingPersonality.impulse),
  ]),
];

class PersonalityQuizStep extends StatefulWidget {
  final OnboardingDraft draft;
  final VoidCallback onChanged;

  const PersonalityQuizStep({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<PersonalityQuizStep> createState() => _PersonalityQuizStepState();
}

class _PersonalityQuizStepState extends State<PersonalityQuizStep> {
  final List<SpendingPersonality?> _answers =
      List<SpendingPersonality?>.filled(_questions.length, null);

  void _select(int qIndex, SpendingPersonality tag) {
    setState(() => _answers[qIndex] = tag);
    final result = _resolve();
    widget.draft.personality = result;
    widget.onChanged();
  }

  SpendingPersonality? _resolve() {
    if (_answers.any((a) => a == null)) return null;
    final counts = <SpendingPersonality, int>{};
    for (final a in _answers) {
      counts[a!] = (counts[a] ?? 0) + 1;
    }
    int best = -1;
    SpendingPersonality? winner;
    for (final a in _answers) {
      final count = counts[a]!;
      if (count > best) {
        best = count;
        winner = a;
      }
    }
    return winner;
  }

  String _label(AppLocalizations l, SpendingPersonality p) => switch (p) {
        SpendingPersonality.saver => l.personalitySaver,
        SpendingPersonality.treater => l.personalityTreater,
        SpendingPersonality.goalChaser => l.personalityGoalChaser,
        SpendingPersonality.impulse => l.personalityImpulse,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final result = widget.draft.personality;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            l.onbQuizTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.onbQuizSubtitle,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _questions.length; i++)
            _QuestionBlock(
              index: i,
              question: _questions[i],
              selected: _answers[i],
              onSelect: (tag) => _select(i, tag),
            ),
          if (result != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3FBF7F).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.onbQuizResult(_label(l, result)),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestionBlock extends StatelessWidget {
  final int index;
  final _Question question;
  final SpendingPersonality? selected;
  final ValueChanged<SpendingPersonality> onSelect;

  const _QuestionBlock({
    required this.index,
    required this.question,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. ${question.promptOf(l)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          for (final opt in question.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: () => onSelect(opt.tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected == opt.tag
                          ? Colors.deepPurple
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected == opt.tag
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: selected == opt.tag
                            ? Colors.deepPurple
                            : Colors.black26,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(opt.labelOf(l))),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
