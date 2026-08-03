import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências globais leves; dados de treino permanecem no SQLite.
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const _keyTheme = 'theme_mode';
  static const _keyDefaultRest = 'default_rest_seconds';
  static const _validRestSeconds = {30, 45, 60, 90, 120};

  ThemeMode _themeMode = ThemeMode.dark;
  int _defaultRestSeconds = 60;

  ThemeMode get themeMode => _themeMode;
  int get defaultRestSeconds => _defaultRestSeconds;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_keyTheme);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    final restSeconds = prefs.getInt(_keyDefaultRest);
    if (restSeconds != null && _validRestSeconds.contains(restSeconds)) {
      _defaultRestSeconds = restSeconds;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
  }

  Future<void> setDefaultRestSeconds(int seconds) async {
    if (!_validRestSeconds.contains(seconds)) return;
    _defaultRestSeconds = seconds;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDefaultRest, seconds);
  }
}
