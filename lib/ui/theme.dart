import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Design tokens — Forkast Design Brief v0.2 §1
// ---------------------------------------------------------------------------

const _primary = Color(0xFFD85A30);
// ignore: unused_element
const _primaryPressed = Color(0xFFB8431F);
const _ink = Color(0xFF2C2C2A);
const _inkMuted = Color(0xFF5F5E5A);
const _surfacePage = Color(0xFFFAF8F3);
const _surfaceCard = Color(0xFFFFFFFF);
const _border = Color(0xFFE7E3DA);
const _success = Color(0xFF2E7D52);
const _warning = Color(0xFFC9871F);

const _darkInk = Color(0xFFF2EFE9);
const _darkInkMuted = Color(0xFFA3A099);
const _darkSurfacePage = Color(0xFF1A1917);
const _darkSurfaceCard = Color(0xFF232220);

// ---------------------------------------------------------------------------
// Extension for accessing custom tokens from any widget via
// Theme.of(context).extension<ForkastTokens>()
// ---------------------------------------------------------------------------

@immutable
class ForkastTokens extends ThemeExtension<ForkastTokens> {
  const ForkastTokens({
    required this.ink,
    required this.inkMuted,
    required this.surfacePage,
    required this.surfaceCard,
    required this.border,
    required this.success,
    required this.warning,
  });

  final Color ink;
  final Color inkMuted;
  final Color surfacePage;
  final Color surfaceCard;
  final Color border;
  final Color success;
  final Color warning;

  static const light = ForkastTokens(
    ink: _ink,
    inkMuted: _inkMuted,
    surfacePage: _surfacePage,
    surfaceCard: _surfaceCard,
    border: _border,
    success: _success,
    warning: _warning,
  );

  static const dark = ForkastTokens(
    ink: _darkInk,
    inkMuted: _darkInkMuted,
    surfacePage: _darkSurfacePage,
    surfaceCard: _darkSurfaceCard,
    border: _border,
    success: _success,
    warning: _warning,
  );

  @override
  ForkastTokens copyWith({
    Color? ink,
    Color? inkMuted,
    Color? surfacePage,
    Color? surfaceCard,
    Color? border,
    Color? success,
    Color? warning,
  }) {
    return ForkastTokens(
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      surfacePage: surfacePage ?? this.surfacePage,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  ForkastTokens lerp(ForkastTokens? other, double t) {
    if (other is! ForkastTokens) return this;
    return ForkastTokens(
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      surfacePage: Color.lerp(surfacePage, other.surfacePage, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

// ---------------------------------------------------------------------------
// Typography — Brief §2: one font, two weights (400/500), sentence case.
// Hierarchy: title ~22/500, body ~16/500 ink, meta ~13/400 ink-muted.
// ---------------------------------------------------------------------------

TextTheme _buildTextTheme(Color ink, Color inkMuted) {
  return TextTheme(
    // Screen title — ~22px / 500
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: ink,
    ),
    // Section titles — ~18px / 500
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: ink,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: ink,
    ),
    // Dish name / list item — ~16px / 500 ink
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: ink,
    ),
    // Regular body text — ~14px / 400
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ink,
    ),
    // Metadata, quantities, units — ~13px / 400 ink-muted
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: inkMuted,
    ),
    // Section headers (uppercase labels)
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.8,
      color: inkMuted,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: inkMuted,
    ),
  );
}

// ---------------------------------------------------------------------------
// Shared component themes
// ---------------------------------------------------------------------------

CardThemeData _cardTheme(Color surface, Color border) => CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );

AppBarTheme _appBarTheme(Color background, Color foreground) => AppBarTheme(
      backgroundColor: background,
      foregroundColor: foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    );

NavigationBarThemeData _navBarTheme({
  required Color background,
  required Color indicator,
  required Color selectedIcon,
  required Color unselectedIcon,
  required Color selectedLabel,
  required Color unselectedLabel,
}) =>
    NavigationBarThemeData(
      backgroundColor: background,
      elevation: 0,
      indicatorColor: indicator,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: selectedIcon, size: 22);
        }
        return IconThemeData(color: unselectedIcon, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selectedLabel,
          );
        }
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: unselectedLabel,
        );
      }),
      height: 64,
    );

DividerThemeData _dividerTheme(Color color) => DividerThemeData(
      color: color,
      thickness: 0.5,
      space: 0.5,
    );

ListTileThemeData _listTileTheme(Color ink) => ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      minVerticalPadding: 8,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
    );

FloatingActionButtonThemeData _fabTheme() =>
    const FloatingActionButtonThemeData(
      elevation: 2,
      shape: StadiumBorder(),
    );

InputDecorationTheme _inputTheme(Color border, Color ink) =>
    InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: false,
    );

ChipThemeData _chipTheme(Color border, Color surface) => ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: border, width: 0.5),
      ),
      backgroundColor: surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );

// ---------------------------------------------------------------------------
// Public ThemeData builders
// ---------------------------------------------------------------------------

final ThemeData forkastLightTheme = _build(Brightness.light);
final ThemeData forkastDarkTheme = _build(Brightness.dark);

ThemeData _build(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final ink = isLight ? _ink : _darkInk;
  final inkMuted = isLight ? _inkMuted : _darkInkMuted;
  final surfacePage = isLight ? _surfacePage : _darkSurfacePage;
  final surfaceCard = isLight ? _surfaceCard : _darkSurfaceCard;
  final border = isLight ? _border : const Color(0xFF3A3835);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: _primary,
    primary: _primary,
    brightness: brightness,
    surface: surfacePage,
    onSurface: ink,
    onSurfaceVariant: inkMuted,
    outline: border,
    outlineVariant: border,
    error: const Color(0xFFB3261E),
  );

  final textTheme = _buildTextTheme(ink, inkMuted);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: surfacePage,
    textTheme: textTheme,
    appBarTheme: _appBarTheme(surfacePage, ink),
    navigationBarTheme: _navBarTheme(
      background: surfaceCard,
      indicator: _primary.withValues(alpha: 0.12),
      selectedIcon: _primary,
      unselectedIcon: inkMuted,
      selectedLabel: _primary,
      unselectedLabel: inkMuted,
    ),
    cardTheme: _cardTheme(surfaceCard, border),
    dividerTheme: _dividerTheme(border),
    listTileTheme: _listTileTheme(ink),
    floatingActionButtonTheme: _fabTheme(),
    inputDecorationTheme: _inputTheme(border, ink),
    chipTheme: _chipTheme(border, surfaceCard),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primary,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: ink,
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(surfaceCard),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: 0.5),
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12),
      ),
      hintStyle: WidgetStatePropertyAll(
        TextStyle(color: inkMuted, fontSize: 14, fontWeight: FontWeight.w400),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return _primary;
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primary.withValues(alpha: 0.3);
        }
        return null;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return _primary;
        return null;
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    extensions: [
      isLight ? ForkastTokens.light : ForkastTokens.dark,
    ],
  );
}
