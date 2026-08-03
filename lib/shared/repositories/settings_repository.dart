import 'package:flutter/material.dart';

import '../services/settings_service.dart';

/// Expõe preferências à UI sem acoplá-la ao serviço de persistência.
class SettingsRepository {
  final SettingsService _service;

  SettingsRepository({SettingsService? service})
    : _service = service ?? SettingsService();

  ThemeMode get themeMode => _service.themeMode;
  int get defaultRestSeconds => _service.defaultRestSeconds;
  Future<void> setThemeMode(ThemeMode mode) => _service.setThemeMode(mode);
  Future<void> setDefaultRestSeconds(int seconds) =>
      _service.setDefaultRestSeconds(seconds);
}
