import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/favorite_provider.dart';
import '../../../providers/restaurant_detail_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/restaurant_card.dart';
import '../restaurant_detail/restaurant_detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Favorit'),
      ),
      body: Builder(
        builder: (context) {
          final provider = context.watch<FavoriteProvider>();
          return switch (provider.state) {
            FavoriteInitial() => const LoadingIndicator(),
            FavoriteError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<FavoriteProvider>().loadFavorites(),
            ),
            FavoriteLoaded(:final restaurants) =>
              restaurants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada restoran favorit',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tambahkan dari halaman detail restoran',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurants[index];
                        return RestaurantCard(
                          restaurant: restaurant,
                          heroTagPrefix: 'fav_',
                          onTap: () {
                            context
                                .read<RestaurantDetailProvider>()
                                .fetchDetail(restaurant.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RestaurantDetailScreen(
                                  restaurantId: restaurant.id,
                                  heroTagPrefix: 'fav_',
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
