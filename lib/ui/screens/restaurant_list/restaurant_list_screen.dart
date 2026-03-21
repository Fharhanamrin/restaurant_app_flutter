import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/restaurant_detail_provider.dart';
import '../../../providers/restaurant_list_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/restaurant_card.dart';
import '../color_picker/color_picker_screen.dart';
import '../font_picker/font_picker_screen.dart';
import '../restaurant_detail/restaurant_detail_screen.dart';
import '../search/search_screen.dart';

class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Restoran'),
        actions: [
          Builder(
            builder: (context) {
              final theme = context.watch<ThemeProvider>();
              return IconButton(
                icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
                tooltip: theme.isDark ? 'Light mode' : 'Dark mode',
                onPressed: () => context.read<ThemeProvider>().toggle(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          PopupMenuButton<_SettingsMenu>(
            icon: const Icon(Icons.more_vert),
            onSelected: (menu) {
              switch (menu) {
                case _SettingsMenu.color:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ColorPickerScreen()),
                  );
                case _SettingsMenu.font:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FontPickerScreen()),
                  );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _SettingsMenu.color,
                child: ListTile(
                  leading: Icon(Icons.palette_outlined),
                  title: Text('Warna Tema'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: _SettingsMenu.font,
                child: ListTile(
                  leading: Icon(Icons.text_fields),
                  title: Text('Ganti Font'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final provider = context.watch<RestaurantListProvider>();
          return switch (provider.state) {
            RestaurantListInitial() => const SizedBox.shrink(),
            RestaurantListLoading() => const LoadingIndicator(),
            RestaurantListError(:final message) => ErrorView(
                message: message,
                onRetry: () =>
                    context.read<RestaurantListProvider>().fetchList(),
              ),
            RestaurantListLoaded(:final restaurants) => ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return RestaurantCard(
                    restaurant: restaurant,
                    onTap: () {
                      context
                          .read<RestaurantDetailProvider>()
                          .fetchDetail(restaurant.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailScreen(
                            restaurantId: restaurant.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          };
        },
      ),
    );
  }
}

enum _SettingsMenu { color, font }
