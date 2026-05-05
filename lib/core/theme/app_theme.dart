import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.light(
    primary: Color(0xFF1E40AF),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDBEAFE),
    onPrimaryContainer: Color(0xFF0F172A),
    secondary: Color(0xFF3B82F6),
    onSecondary: Colors.white,
    tertiary: Color(0xFFF59E0B),
    onTertiary: Color(0xFF0F172A),
    error: Color(0xFFDC2626),
    onError: Colors.white,
    surface: Color(0xFFF8FAFC),
    onSurface: Color(0xFF0F172A),
    onSurfaceVariant: Color(0xFF475569),
    outlineVariant: Color(0xFFCBD5E1),
  );

  return ThemeData(
    extensions: const <ThemeExtension<dynamic>>[TradingSemanticColors()],
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      isDense: true,
    ),
    chipTheme: const ChipThemeData(
      shape: StadiumBorder(),
      side: BorderSide.none,
    ),
  );
}

@immutable
class TradingSemanticColors extends ThemeExtension<TradingSemanticColors> {
  const TradingSemanticColors({
    this.success = const Color(0xFF16A34A),
    this.bullish = const Color(0xFF26A69A),
    this.bearish = const Color(0xFFEF5350),
  });

  final Color success;
  final Color bullish;
  final Color bearish;

  @override
  ThemeExtension<TradingSemanticColors> copyWith({
    Color? success,
    Color? bullish,
    Color? bearish,
  }) {
    return TradingSemanticColors(
      success: success ?? this.success,
      bullish: bullish ?? this.bullish,
      bearish: bearish ?? this.bearish,
    );
  }

  @override
  ThemeExtension<TradingSemanticColors> lerp(
    covariant ThemeExtension<TradingSemanticColors>? other,
    double t,
  ) {
    if (other is! TradingSemanticColors) {
      return this;
    }

    return TradingSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      bullish: Color.lerp(bullish, other.bullish, t) ?? bullish,
      bearish: Color.lerp(bearish, other.bearish, t) ?? bearish,
    );
  }
}
