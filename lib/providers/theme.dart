import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final String _themeModeKey = 'theme_mode';

  ThemeProvider() {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeModeValue = prefs.getString(_themeModeKey);
    if (themeModeValue != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (element) => element.toString() == themeModeValue,
        orElse: () => ThemeMode.system,
      );
    }
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());
    
    notifyListeners();
  }

  Future<void> toggleThemeMode() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> resetToDefaults() async {
    await setThemeMode(ThemeMode.system);
  }
}