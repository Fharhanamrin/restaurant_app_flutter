import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/restaurant_detail_provider.dart';
import '../../../providers/search_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/restaurant_card.dart';
import '../restaurant_detail/restaurant_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari restoran...',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => context.read<SearchProvider>().search(value),
        ),
        actions: [
          Builder(
            builder: (context) {
              final state = context.watch<SearchProvider>().state;
              if (state is SearchInitial) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  context.read<SearchProvider>().clearResults();
                },
              );
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final provider = context.watch<SearchProvider>();
          return switch (provider.state) {
            SearchInitial() => _EmptyPrompt(),
            SearchLoading() => const LoadingIndicator(),
            SearchError(:final message) => ErrorView(message: message),
            SearchLoaded(:final restaurants, :final query) =>
              restaurants.isEmpty
                  ? _NoResults(query: query)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurants[index];
                        return RestaurantCard(
                          restaurant: restaurant,
                          heroTagPrefix: 'search_',
                          onTap: () {
                            context
                                .read<RestaurantDetailProvider>()
                                .fetchDetail(restaurant.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RestaurantDetailScreen(
                                  restaurantId: restaurant.id,
                                  heroTagPrefix: 'search_',
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

class _EmptyPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Cari restoran favorit kamu',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada hasil untuk "$query"',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
