import 'package:flutter/material.dart';

/// Brand defaults Sprout uses when no user is signed in (auth screen,
/// splash) and as the seed for ColorScheme when no override is set.
class SproutBrand {
  SproutBrand._();
  static const Color primary = Color(0xFF673AB7);
  static const Color sproutGreen = Color(0xFF3FBF7F);
  static const Color alertCoral = Color(0xFFFF6B6B);
  static const Color lightBackground = Color(0xFFEDF1F5);
  static const Color darkBackground = Color(0xFF111418);
  static const Color darkSurface = Color(0xFF1B1F26);

  /// Brand gradient — used by AuthScreen, SplashScreen, CooldownScreen.
  /// Stays fixed regardless of accent override.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2765CF), Color(0xFF633CA5)],
  );
}

/// Parses a `#RRGGBB` hex string. Returns [SproutBrand.primary] on
/// invalid input so the app never crashes if a user record is corrupt.
Color parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return SproutBrand.primary;
  var clean = hex.startsWith('#') ? hex.substring(1) : hex;
  if (clean.length == 6) clean = 'FF$clean';
  final value = int.tryParse(clean, radix: 16);
  return value == null ? SproutBrand.primary : Color(value);
}

/// Builds a Sprout [ThemeData] for [brightness] using [seed] as the
/// ColorScheme seed. Light keeps the soft off-white background; dark
/// uses our charcoal so the brand doesn't feel grey.
ThemeData buildSproutTheme({required Color seed, required Brightness brightness}) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  final isDark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        isDark ? SproutBrand.darkBackground : SproutBrand.lightBackground,
    cardColor: isDark ? SproutBrand.darkSurface : Colors.white,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
