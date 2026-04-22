import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_mode';

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    return saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final current = state.valueOrNull ?? ThemeMode.light;
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, next == ThemeMode.dark ? 'dark' : 'light');
    state = AsyncData(next);
  }
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
