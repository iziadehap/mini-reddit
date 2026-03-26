// import 'package:flutter/material.dart';

// class AppTheme {
//   // Brand Palette
//   static const Color color1 = Color(0xFF0A1931); // Primary
//   static const Color color2 = Color(0xFFB3CFE5); // Light accent
//   static const Color color3 = Color(0xFF4A7FA7); // Secondary
//   static const Color color4 = Color(0xFF1A3D63); // Dark secondary
//   static const Color color5 = Color(0xFFF6FAFD); // Light background

//   // Light Mode Colors
//   static const Color lightBackground = color5;
//   static const Color lightSurface = Colors.white;
//   static const Color lightOnSurface = Color(0xFF1A1A1A);
//   static const Color lightOnPrimary = Colors.white;
//   static const Color lightBorder = Color(0xFFE3ECF3);
//   static const Color lightMutedText = Color(0xFF6B7280);

//   // Dark Mode Colors
//   static const Color darkBackground = Color(0xFF08111F);
//   static const Color darkSurface = Color(0xFF101C2E);
//   static const Color darkOnSurface = Color(0xFFEAF2F8);
//   static const Color darkOnPrimary = Colors.white;
//   static const Color darkBorder = Color(0xFF22344D);
//   static const Color darkMutedText = Color(0xFF9AA8B7);

//   static ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.light,
//     scaffoldBackgroundColor: lightBackground,
//     colorScheme: const ColorScheme.light(
//       primary: color1,
//       secondary: color3,
//       surface: lightSurface,
//       onPrimary: lightOnPrimary,
//       onSecondary: Colors.white,
//       onSurface: lightOnSurface,
//     ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: lightSurface,
//       foregroundColor: color1,
//       elevation: 0,
//       centerTitle: false,
//       surfaceTintColor: Colors.transparent,
//       titleTextStyle: TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: color1,
//       ),
//     ),
//     cardTheme: CardThemeData(
//       color: lightSurface,
//       elevation: 0,
//       surfaceTintColor: Colors.transparent,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: const BorderSide(color: lightBorder, width: 1),
//       ),
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color1,
//         foregroundColor: lightOnPrimary,
//         minimumSize: const Size(double.infinity, 48),
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//         textStyle: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     ),
//     outlinedButtonTheme: OutlinedButtonThemeData(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: color1,
//         side: const BorderSide(color: color3),
//         minimumSize: const Size(double.infinity, 48),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//       ),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: lightBorder),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: lightBorder),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: color3, width: 1.5),
//       ),
//       hintStyle: const TextStyle(color: lightMutedText),
//     ),
//     textTheme: const TextTheme(
//       headlineLarge: TextStyle(
//         fontSize: 24,
//         fontWeight: FontWeight.bold,
//         color: color1,
//       ),
//       titleMedium: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: lightOnSurface,
//       ),
//       bodyLarge: TextStyle(
//         fontSize: 14,
//         color: lightOnSurface,
//       ),
//       bodyMedium: TextStyle(
//         fontSize: 12,
//         color: lightMutedText,
//       ),
//     ),
//     dividerColor: lightBorder,
//   );

//   static ThemeData darkTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.dark,
//     scaffoldBackgroundColor: darkBackground,
//     colorScheme: const ColorScheme.dark(
//       primary: color2,
//       secondary: color3,
//       surface: darkSurface,
//       onPrimary: color1,
//       onSecondary: Colors.white,
//       onSurface: darkOnSurface,
//     ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: darkSurface,
//       foregroundColor: darkOnSurface,
//       elevation: 0,
//       centerTitle: false,
//       surfaceTintColor: Colors.transparent,
//       titleTextStyle: TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: darkOnSurface,
//       ),
//     ),
//     cardTheme: CardThemeData(
//       color: darkSurface,
//       elevation: 0,
//       surfaceTintColor: Colors.transparent,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: const BorderSide(color: darkBorder, width: 1),
//       ),
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color2,
//         foregroundColor: color1,
//         minimumSize: const Size(double.infinity, 48),
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//         textStyle: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     ),
//     outlinedButtonTheme: OutlinedButtonThemeData(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: color2,
//         side: const BorderSide(color: color3),
//         minimumSize: const Size(double.infinity, 48),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//       ),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: darkSurface,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: darkBorder),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: darkBorder),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: color2, width: 1.5),
//       ),
//       hintStyle: const TextStyle(color: darkMutedText),
//     ),
//     textTheme: const TextTheme(
//       headlineLarge: TextStyle(
//         fontSize: 24,
//         fontWeight: FontWeight.bold,
//         color: darkOnSurface,
//       ),
//       titleMedium: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: darkOnSurface,
//       ),
//       bodyLarge: TextStyle(
//         fontSize: 14,
//         color: darkOnSurface,
//       ),
//       bodyMedium: TextStyle(
//         fontSize: 12,
//         color: darkMutedText,
//       ),
//     ),
//     dividerColor: darkBorder,
//   );
// }