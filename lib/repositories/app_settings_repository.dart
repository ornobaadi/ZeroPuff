import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return const AppSettingsRepository();
});

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final mode = await ref.read(appSettingsRepositoryProvider).loadThemeMode();
    state = mode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(appSettingsRepositoryProvider).saveThemeMode(mode);
  }
}

class AppSettingsRepository {
  const AppSettingsRepository();

  static const _themeModeKey = 'app.theme_mode';

  Future<ThemeMode> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    return _parseThemeMode(preferences.getString(_themeModeKey));
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, mode.name);
  }

  ThemeMode _parseThemeMode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
