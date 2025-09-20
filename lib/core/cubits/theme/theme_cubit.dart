import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

@singleton
class ThemeCubit extends Cubit<ThemeState> {
  static const _themeKey = 'is_dark';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(ThemeState(true));

  void loadTheme() {
    final isDark = _prefs.getBool(_themeKey) ?? true;
    emit(ThemeState(isDark));
  }

  void setCurrentTheme(bool isDark) {
    _prefs.setBool(_themeKey, isDark);
    emit(ThemeState(isDark));
  }

  String get getThemeMap =>
      state.isDark ? DefaultConstants.mapBoxDark : DefaultConstants.mapBoxLight;
}
