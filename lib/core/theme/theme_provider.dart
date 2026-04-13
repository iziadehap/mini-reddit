// theme_provider.dart
import 'package:flutter/material.dart' hide Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/services/cash.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

Future<void> setThemeMode(WidgetRef ref, ThemeMode mode) async {
  debugPrint('🔥 Setting theme mode to $mode');
  await saveThemeMode(mode);
  ref.read(themeModeProvider.notifier).state = mode;
}

Future<void> saveThemeMode(ThemeMode mode) async {
  int modeInt = mode.index;
  debugPrint('🔥 Mode int: $modeInt');
  await CashService().save(Key.themeMode, modeInt);
  debugPrint('🔥 Saving theme mode to $modeInt');
}

Future<ThemeMode> getThemeMode() async {
  int modeInt = await CashService().get(Key.themeMode);
  debugPrint('🔥 Mode int: $modeInt');
  return ThemeMode.values[modeInt];
}
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
