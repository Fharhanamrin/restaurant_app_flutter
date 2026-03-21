import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/restaurant_detail_provider.dart';
import '../../../providers/restaurant_list_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/restaurant_card.dart';
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
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
                    heroTagPrefix: 'home_',
                    onTap: () {
                      context
                          .read<RestaurantDetailProvider>()
                          .fetchDetail(restaurant.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailScreen(
                            restaurantId: restaurant.id,
                            heroTagPrefix: 'home_',
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
