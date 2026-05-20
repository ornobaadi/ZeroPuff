import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeropuff/repositories/app_settings_repository.dart';

void main() {
  group('AppSettingsRepository', () {
    test('defaults to system theme mode', () async {
      SharedPreferences.setMockInitialValues({});

      final mode = await const AppSettingsRepository().loadThemeMode();

      expect(mode, ThemeMode.system);
    });

    test('persists selected theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      const repository = AppSettingsRepository();

      await repository.saveThemeMode(ThemeMode.dark);

      expect(await repository.loadThemeMode(), ThemeMode.dark);
    });
  });
}
