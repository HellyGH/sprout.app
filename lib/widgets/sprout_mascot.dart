import 'dart:math';

import 'package:flutter/material.dart';

enum SproutState { idle, cheering, sad, sleeping, waving }

/// Sprout mascot — a tiny coin-faced sprout. Phase 7 ships per-state
/// animations: idle bobs gently, cheering bounces with scale pulses,
/// sad droops with a slow sway, sleeping rises/falls slowly, waving
/// sways side-to-side with a tilt.
class SproutMascot extends StatefulWidget {
  final SproutState state;
  final double size;

  const SproutMascot({
    super.key,
    this.state = SproutState.idle,
    this.size = 80,
  });

  @override
  State<SproutMascot> createState() => _SproutMascotState();
}

class _SproutMascotState extends State<SproutMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: _durationFor(widget.state),
    )..repeat(reverse: _reverseFor(widget.state));
  }

  @override
  void didUpdateWidget(covariant SproutMascot old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      _ctrl.stop();
      _ctrl.duration = _durationFor(widget.state);
      _ctrl.repeat(reverse: _reverseFor(widget.state));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Duration _durationFor(SproutState s) => switch (s) {
        SproutState.idle => const Duration(milliseconds: 1600),
        SproutState.cheering => const Duration(milliseconds: 600),
        SproutState.sad => const Duration(milliseconds: 2400),
        SproutState.sleeping => const Duration(milliseconds: 2600),
        SproutState.waving => const Duration(milliseconds: 900),
      };

  bool _reverseFor(SproutState s) => switch (s) {
        SproutState.cheering => false, // full-cycle bounce
        SproutState.waving => false,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => _buildForState(context, _ctrl.value),
    );
  }

  Widget _buildForState(BuildContext context, double t) {
    final tint = _tintFor(widget.state);
    final emoji = _emojiFor(widget.state);
    double dx = 0;
    double dy = 0;
    double scale = 1;
    double angle = 0;
    String? overlay;

    switch (widget.state) {
      case SproutState.idle:
        dy = -4 * Curves.easeInOut.transform(t);
      case SproutState.cheering:
        // Two arcs per cycle so bounce feels punchy.
        final phase = (t * 2) % 1.0;
        final bounce = sin(phase * pi);
        dy = -14 * bounce;
        scale = 1 + 0.08 * bounce;
      case SproutState.sad:
        dy = 4 * Curves.easeInOut.transform(t);
        angle = (t - 0.5) * 0.18; // small sway each side of center
      case SproutState.sleeping:
        dy = -2 + 4 * Curves.easeInOut.transform(t);
        angle = -0.04 + 0.08 * t;
        overlay = '💤';
      case SproutState.waving:
        final phase = sin(t * 2 * pi);
        dx = 8 * phase;
        angle = phase * 0.18;
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tint,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(
              angle: angle,
              child: Transform.scale(
                scale: scale,
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: widget.size * 0.55),
                ),
              ),
            ),
          ),
          if (overlay != null)
            Positioned(
              right: widget.size * 0.05,
              top: widget.size * 0.04,
              child: Opacity(
                opacity: (0.4 + 0.6 * t).clamp(0.0, 1.0),
                child: Text(
                  overlay,
                  style: TextStyle(fontSize: widget.size * 0.22),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _tintFor(SproutState state) {
    switch (state) {
      case SproutState.cheering:
        return const Color(0xFF3FBF7F).withValues(alpha: 0.22);
      case SproutState.sad:
        return const Color(0xFFFF6B6B).withValues(alpha: 0.18);
      case SproutState.sleeping:
        return const Color(0xFF9CA3AF).withValues(alpha: 0.18);
      case SproutState.waving:
      case SproutState.idle:
        return const Color(0xFF3FBF7F).withValues(alpha: 0.12);
    }
  }

  String _emojiFor(SproutState state) {
    switch (state) {
      case SproutState.cheering:
        return '🌱';
      case SproutState.sad:
        return '🥀';
      case SproutState.sleeping:
        return '😴';
      case SproutState.waving:
        return '👋';
      case SproutState.idle:
        return '🌱';
    }
  }
}
