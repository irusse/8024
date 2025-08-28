part of './theme.dart';

class ThemeTextStyles extends ThemeExtension<ThemeTextStyles> {
  final TextStyle titleLarge;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;

  ThemeTextStyles({
    required this.titleLarge,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
  });

  @override
  ThemeExtension<ThemeTextStyles> copyWith({
    TextStyle? titleLarge,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
  }) {
    return ThemeTextStyles(
      titleLarge: titleLarge ?? this.titleLarge,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
    );
  }

  @override
  ThemeExtension<ThemeTextStyles> lerp(
    ThemeExtension<ThemeTextStyles>? other,
    double t,
  ) {
    if (other is! ThemeTextStyles) {
      return this;
    }

    return ThemeTextStyles(
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
    );
  }

  static get dark => ThemeTextStyles(
      titleLarge: titleL.copyWith(
        color: DarkModeColors.base100,
        fontWeight: FontWeight.w500,
        fontFamily: 'Onest',
      ),
      titleSmall: titleS.copyWith(
        fontWeight: FontWeight.w600,
        color: DarkModeColors.base100,
        fontFamily: 'Onest',
        height: 24 / 20,
        letterSpacing: -0.4,
      ),
      bodyLarge: bodyL.copyWith(
        color: DarkModeColors.base100,
        fontWeight: FontWeight.w400,
        fontFamily: 'Onest',
        height: 22 / 16,
        letterSpacing: -0.32,
      ),
      bodyMedium: bodyM.copyWith(
        color: DarkModeColors.base100,
        fontWeight: FontWeight.w400,
        fontFamily: 'Onest',
        height: 20 / 14,
        letterSpacing: 0.2,
      ),
      bodySmall: bodyS.copyWith(
        color: DarkModeColors.base100,
        fontWeight: FontWeight.w400,
        fontFamily: 'Onest',
        height: 16 / 13,
        letterSpacing: 0.2,
      ),
      labelLarge: labelL.copyWith(
        color: DarkModeColors.base100,
        fontWeight: FontWeight.w400,
        fontFamily: 'Onest',
      ));

  static get light => ThemeTextStyles(
      titleLarge: titleL.copyWith(
        color: LightModeColors.base0,
        fontWeight: FontWeight.w500,
        fontFamily: 'Onest',
      ),
      titleSmall: titleS.copyWith(
        fontWeight: FontWeight.w600,
        color: DarkModeColors.base0,
        fontFamily: 'Onest',
        height: 24 / 20,
        letterSpacing: -0.4,
      ),
      bodyLarge: bodyL.copyWith(
        color: DarkModeColors.base0,
        fontWeight: FontWeight.w400,
        fontFamily: 'Onest',
        height: 22 / 16,
        letterSpacing: -0.32,
      ),
      bodyMedium: bodyM.copyWith(
        color: DarkModeColors.base0,
        fontWeight: FontWeight.w400,
        fontFamily: 'Onest',
        height: 20 / 14,
        letterSpacing: 0.2,
      ),
      bodySmall: bodyS.copyWith(
        color: DarkModeColors.base0,
        fontWeight: FontWeight.w400,
        fontFamily: 'Onest',
        height: 16 / 13,
        letterSpacing: 0.2,
      ),
      labelLarge: labelL.copyWith(
        color: DarkModeColors.base0,
        fontWeight: FontWeight.w400,
        fontFamily: 'Onest',
      ));
}
