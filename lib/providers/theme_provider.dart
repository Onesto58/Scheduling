import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Key for storage
const String _themeKey = 'theme_mode';

// We provide the SharedPreferences instance through a provider
// This will be overridden in main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeMode> {
  late SharedPreferences _prefs;

  @override
  ThemeMode build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    
    // Load saved theme, default to dark if not set
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme == 'light') return ThemeMode.light;
    if (savedTheme == 'dark') return ThemeMode.dark;
    return ThemeMode.dark; // Default
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    // Save to persistence
    _prefs.setString(_themeKey, mode.name);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
