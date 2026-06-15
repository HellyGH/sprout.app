import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import 'sprout_mascot.dart';

/// Shows a confetti burst + Sprout cheer for ~1.6 seconds, then dismisses.
/// Used when a goal crosses a 25/50/75/100% threshold.
Future<void> showMilestoneCelebration(
  BuildContext context, {
  required String goalName,
  required double milestone,
}) async {
  HapticFeedback.heavyImpact();
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => _MilestoneDialog(
      goalName: goalName,
      milestone: milestone,
    ),
  );
}

class _MilestoneDialog extends StatefulWidget {
  final String goalName;
  final double milestone;

  const _MilestoneDialog({
    required this.goalName,
    required this.milestone,
  });

  @override
  State<_MilestoneDialog> createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<_MilestoneDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    final rand = Random();
    _particles = List.generate(
      28,
      (_) => _Particle(
        angle: rand.nextDouble() * 2 * pi,
        distance: 80 + rand.nextDouble() * 140,
        size: 6 + rand.nextDouble() * 6,
        color: _palette[rand.nextInt(_palette.length)],
        spin: (rand.nextDouble() - 0.5) * 4,
        delay: rand.nextDouble() * 0.2,
      ),
    );
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _palette = [
    Color(0xFF3FBF7F),
    Color(0xFF60A5FA),
    Color(0xFFA78BFA),
    Color(0xFFFFB74D),
    Color(0xFFF472B6),
  ];

  String _label(AppLocalizations l, double t) {
    if (t >= 1.0) return l.milestoneComplete;
    return l.milestonePercent((t * 100).round());
  }

  String _subtitle(AppLocalizations l, double t) {
    if (t >= 1.0) return l.milestoneCompleteSub(widget.goalName);
    return l.milestoneKeepGoing(widget.goalName);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _ctrl.value;
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                ..._particles.map((p) => _renderParticle(p, t)),
                Container(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: 0.8 +
                            0.4 *
                                Curves.elasticOut.transform(
                                  t.clamp(0.0, 1.0),
                                ),
                        child: const SproutMascot(
                          state: SproutState.cheering,
                          size: 110,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _label(l, widget.milestone),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle(l, widget.milestone),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _renderParticle(_Particle p, double t) {
    final phase = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
    final eased = Curves.easeOut.transform(phase);
    final dx = cos(p.angle) * p.distance * eased;
    final dy =
        sin(p.angle) * p.distance * eased + 60 * eased * eased; // gravity-ish
    final opacity = (1 - phase).clamp(0.0, 1.0);
    return Positioned(
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Transform.rotate(
          angle: p.spin * eased,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: p.size,
              height: p.size * 0.55,
              decoration: BoxDecoration(
                color: p.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double spin;
  final double delay;

  const _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.spin,
    required this.delay,
  });
}
