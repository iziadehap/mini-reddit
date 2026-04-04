// ========================================
// 3. شاشة الإعدادات (Settings Screen)
// ========================================
// lib/features/profile/presentation/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/theme/theme_provider.dart';
import 'package:mini_reddit_v2/core/utils/assets_utils.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(myProfileProvider);
    final profile = profileState.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader(context, 'Account'),
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: profile != null ? 'u/${profile.username}' : 'Loading...',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle:
                Supabase.instance.client.auth.currentUser?.email ?? 'Unknown',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: 'Password',
            subtitle: 'Change your password',
            onTap: () {},
          ),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            child: Column(
              children: [
                _buildThemeOption(
                  context,
                  ref,
                  title: 'Light Mode',
                  icon: Icons.light_mode,
                  mode: ThemeMode.light,
                  currentMode: ref.watch(themeModeProvider),
                ),
                _buildDivider(context),
                _buildThemeOption(
                  context,
                  ref,
                  title: 'Dark Mode',
                  icon: Icons.dark_mode,
                  mode: ThemeMode.dark,
                  currentMode: ref.watch(themeModeProvider),
                ),
                _buildDivider(context),
                _buildThemeOption(
                  context,
                  ref,
                  title: 'System Default',
                  icon: Icons.settings_suggest_outlined,
                  mode: ThemeMode.system,
                  currentMode: ref.watch(themeModeProvider),
                ),
              ],
            ),
          ),

          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          _buildSwitchTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            value: true,
            onChanged: (value) {},
          ),
          _buildSwitchTile(
            context,
            icon: Icons.mark_chat_read_outlined,
            title: 'Messages',
            value: true,
            onChanged: (value) {},
          ),
          _buildSwitchTile(
            context,
            icon: Icons.comment_outlined,
            title: 'Comments',
            value: false,
            onChanged: (value) {},
          ),

          // Privacy Section
          _buildSectionHeader(context, 'Privacy'),
          _buildSettingsTile(
            context,
            icon: Icons.visibility_outlined,
            title: 'Profile Visibility',
            subtitle: 'Public',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.shield_outlined,
            title: 'Blocked Users',
            subtitle: '0 users',
            onTap: () {},
          ),

          // Support Section
          _buildSectionHeader(context, 'Support'),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    String emoji;
    switch (title) {
      case 'Appearance':
        emoji = AssetsUtils.emojiCalmSmile;
        break;
      case 'Notifications':
        emoji = AssetsUtils.emojiPlayfulTongue;
        break;
      case 'Privacy':
        emoji = AssetsUtils.emojiNervous;
        break;
      case 'Support':
        emoji = AssetsUtils.emojiSillyWink;
        break;
      default:
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0.5,
            ),
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Image.asset(emoji, width: 16, height: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface),
      ),
      child: SwitchListTile(
        secondary: Icon(icon),
        title: Text(title),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = currentMode == mode;

    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).state = mode;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (Theme.of(context).colorScheme.onSurface)
                  : (Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected
                      ? (Theme.of(context).colorScheme.onSurface)
                      : (Theme.of(context).colorScheme.onSurface),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
