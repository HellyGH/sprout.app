import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/budget_controller.dart';
import '../widgets/bottom_nav_bar.dart';
import 'goals/goals_screen.dart';
import 'home/home_screen.dart';
import 'stats/stats_screen.dart';
import 'together/together_screen.dart';
import 'you/you_screen.dart';

/// Index of the Together tab in [_RootShellState._tabs].
const int kTogetherTabIndex = 3;

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  /// Switch the visible bottom-nav tab from anywhere below the shell, e.g.
  /// the Home partner promo jumping to the Together tab.
  static void goToTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_RootShellState>()?._setIndex(index);
  }

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _tabs = [
    HomeScreen(),
    StatsScreen(),
    GoalsScreen(),
    TogetherScreen(),
    YouScreen(),
  ];

  void _setIndex(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final loading = context.select<BudgetController, bool>((c) => c.loading);
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: loading
            ? const Center(
                key: ValueKey('loading'),
                child: CircularProgressIndicator(),
              )
            : KeyedSubtree(
                key: ValueKey(_index),
                child: _tabs[_index],
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _index,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
      ),
    );
  }
}

