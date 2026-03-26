import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/widgets/user_Widget.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/create_post_screen.dart';
import 'package:mini_reddit_v2/features/feed/presentation/pages/feed_screen.dart';
import 'package:mini_reddit_v2/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:mini_reddit_v2/features/profile/presentation/pages/profile_screen.dart';
import 'package:mini_reddit_v2/core/riverpod/ui_visibility_provider.dart';

class MainNavigationLayout extends ConsumerStatefulWidget {
  const MainNavigationLayout({super.key});

  @override
  ConsumerState<MainNavigationLayout> createState() =>
      _MainNavigationLayoutState();
}

class _MainNavigationLayoutState extends ConsumerState<MainNavigationLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const Scaffold(), // Future feature
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(uiVisibilityProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: isVisible ? Offset.zero : const Offset(0, 1),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePostScreen(),
                ),
              );
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_outlined),
              selectedIcon: Icon(Icons.add),
              label: 'Create',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Inbox',
            ),
            NavigationDestination(
              icon: UserWidget(),
              selectedIcon: UserWidget(),
              label: 'me',
            ),
            // NavigationDestination(
            //   icon: Icon(Icons.person_outline),
            //   selectedIcon: Icon(Icons.person),
            //   label: 'Profile',
            // ),
          ],
        ),
      ),
    );
  }
}
