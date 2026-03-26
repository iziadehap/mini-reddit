// theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
//   return ThemeNotifier();
// });

// class ThemeNotifier extends Notifier<ThemeMode> {
//   static const _themeKey = 'theme_mode';

//   @override
//   ThemeMode build() {
//     _loadTheme();
//     return ThemeMode.system;
//   }

//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final themeIndex = prefs.getInt(_themeKey);
//     if (themeIndex != null) {
//       state = ThemeMode.values[themeIndex];
//     }
//   }

//   Future<void> setTheme(ThemeMode mode) async {
//     state = mode;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(_themeKey, mode.index);
//   }

//   Future<void> toggleTheme() async {
//     if (state == ThemeMode.dark) {
//       await setTheme(ThemeMode.light);
//     } else {
//       await setTheme(ThemeMode.dark);
//     }
//   }
// }
