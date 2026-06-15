import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/sprout_mascot.dart';
import 'login_form.dart';
import 'signup_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2765CF), Color(0xFF633CA5)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          const SproutMascot(
                            state: SproutState.idle,
                            size: 96,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l.appTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.appTagline,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDF1F5),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                TabBar(
                                  controller: _tabs,
                                  labelColor: Colors.deepPurple,
                                  unselectedLabelColor: Colors.black54,
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  indicatorColor: Colors.deepPurple,
                                  indicatorWeight: 3,
                                  dividerHeight: 0,
                                  tabs: [
                                    Tab(text: l.authLogIn),
                                    Tab(text: l.authSignUp),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                AnimatedBuilder(
                                  animation: _tabs,
                                  builder: (context, _) {
                                    return AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      curve: Curves.easeOut,
                                      alignment: Alignment.topCenter,
                                      child: _tabs.index == 0
                                          ? const LoginForm()
                                          : const SignupForm(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
