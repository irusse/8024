part of './theme.dart';

ThemeData createLightTheme() {
  return ThemeData(

      textTheme: createTextTheme(),
      scaffoldBackgroundColor: LightModeColors.base100,
      extensions: <ThemeExtension<dynamic>>[
        ThemeColors.light,
        ThemeTextStyles.light
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
      ));
}
