part of './theme.dart';

ThemeData createDarkTheme() {
  return ThemeData(

      textTheme: createTextTheme(),
      scaffoldBackgroundColor: DarkModeColors.base0,
      extensions: <ThemeExtension<dynamic>>[
        ThemeColors.dark,
        ThemeTextStyles.dark
      ],
      appBarTheme: const AppBarTheme(
        color: Colors.transparent,
      ));
}
