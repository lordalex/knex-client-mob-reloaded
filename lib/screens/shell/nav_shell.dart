import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation wrapper that provides the persistent tab bar
/// for the Home and Profile branches of the app.
///
/// This widget is used as the builder for [StatefulShellRoute.indexedStack]
/// in the GoRouter configuration, keeping each branch's navigation state
/// alive when switching tabs.
class NavShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Navigate to the initial location of the branch when tapping
          // the item that is already active.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
