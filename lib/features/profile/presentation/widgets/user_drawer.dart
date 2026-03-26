// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mini_reddit_v2/core/theme/theme_provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class UserDrawer extends ConsumerWidget {
//   const UserDrawer({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final themeMode = ref.watch(themeProvider);
//     final user = Supabase.instance.client.auth.currentUser;
//     final isDark = themeMode == ThemeMode.dark ||
//                   (themeMode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);

//     return Drawer(
//       child: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             CircleAvatar(
//               radius: 40,
//               backgroundColor: Colors.grey[300],
//               child: const Icon(Icons.person, size: 50, color: Colors.white),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               user?.email ?? 'Guest User',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Divider(),
//             ListTile(
//               leading: const Icon(Icons.person_outline),
//               title: const Text('My Profile'),
//               onTap: () {
//                 // Navigate to profile
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings_outlined),
//               title: const Text('User Settings'),
//               onTap: () {
//                 // Navigate to settings
//                 Navigator.pop(context);
//               },
//             ),
//             const Spacer(),
//             const Divider(),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         isDark ? Icons.dark_mode : Icons.light_mode,
//                         color: isDark ? Colors.blueAccent : Colors.orange,
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Dark Mode',
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                     ],
//                   ),
//                   Switch(
//                     value: isDark,
//                     onChanged: (value) {
//                       ref.read(themeProvider.notifier).setTheme(
//                             value ? ThemeMode.dark : ThemeMode.light,
//                           );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.redAccent),
//               title: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
//               onTap: () async {
//                 await Supabase.instance.client.auth.signOut();
//                 Navigator.pop(context);
//               },
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }
