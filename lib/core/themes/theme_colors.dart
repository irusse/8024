part of './theme.dart';

class ThemeColors extends ThemeExtension<ThemeColors> {
  final Color background;
  final Color primaryText;
  final Color secondaryText;
  final Color primary;
  final Color secondary;
  final Color basicRed;
  final Color tertiary;

  const ThemeColors({
    required this.primaryText,
    required this.secondaryText,
    required this.primary,
    required this.background,
    required this.secondary,
    required this.basicRed,
    required this.tertiary,
  });

  @override
  ThemeColors copyWith({
    Color? primaryText,
    Color? secondaryText,
    Color? primary,
    Color? background,
    Color? secondary,
    Color? tertiary,
    Color? basicRed,
  }) {
    return ThemeColors(
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      primary: primary ?? this.primary,
      background: background ?? this.background,
      secondary: secondary ?? this.secondary,
      basicRed: basicRed ?? this.basicRed,
      tertiary: tertiary ?? this.tertiary,
    );
  }

  @override
  ThemeColors lerp(ThemeExtension<ThemeColors>? other, double t) {
    if (other is! ThemeColors) {
      return this;
    }

    return ThemeColors(
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      background: Color.lerp(background, other.background, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      basicRed: Color.lerp(basicRed, other.basicRed, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
    );
  }

  static get dark => const ThemeColors(
      background: DarkModeColors.base0,
      primary: DarkModeColors.green100,
      primaryText: DarkModeColors.base100,
      basicRed: DarkModeColors.red100,
      secondaryText: DarkModeColors.base30,
      tertiary: DarkModeColors.base40,
      secondary: DarkModeColors.base10);

  static get light => const ThemeColors(
      background: LightModeColors.base100,
      primary: LightModeColors.green100,
      basicRed: LightModeColors.red100,
      primaryText: LightModeColors.base0,
      secondaryText: LightModeColors.base20,
      tertiary: DarkModeColors.base40,
      secondary: LightModeColors.base80);
}
