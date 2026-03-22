import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/navigation_provider.dart';
import '../favorite/favorite_screen.dart';
import '../restaurant_list/restaurant_list_screen.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _screens = <Widget>[
    RestaurantListScreen(),
    FavoriteScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final navIndex = context.watch<NavigationProvider>().currentIndex;
        return Scaffold(
          body: IndexedStack(index: navIndex, children: _screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: navIndex,
            onDestinationSelected: (index) =>
                context.read<NavigationProvider>().setIndex(index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.restaurant_outlined),
                selectedIcon: Icon(Icons.restaurant),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite),
                label: 'Favorit',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Pengaturan',
              ),
            ],
          ),
        );
      },
    );
  }
}
