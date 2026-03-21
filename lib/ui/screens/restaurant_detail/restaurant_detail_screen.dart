import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/customer_review.dart';
import '../../../data/models/menu_item.dart';
import '../../../data/models/restaurant.dart';
import '../../../data/models/restaurant_detail.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/restaurant_detail_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String restaurantId;
  final String heroTagPrefix;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    this.heroTagPrefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final provider = context.watch<RestaurantDetailProvider>();
        return switch (provider.state) {
          RestaurantDetailLoaded(:final restaurant) => Scaffold(
              body: _DetailBody(
                restaurant: restaurant,
                heroTagPrefix: heroTagPrefix,
              ),
            ),
          RestaurantDetailError(:final message) => Scaffold(
              appBar: AppBar(
                backgroundColor:
                    Theme.of(context).colorScheme.inversePrimary,
              ),
              body: ErrorView(
                message: message,
                onRetry: () => context
                    .read<RestaurantDetailProvider>()
                    .fetchDetail(restaurantId),
              ),
            ),
          _ => Scaffold(
              appBar: AppBar(
                backgroundColor:
                    Theme.of(context).colorScheme.inversePrimary,
              ),
              body: const LoadingIndicator(),
            ),
        };
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  final RestaurantDetail restaurant;
  final String heroTagPrefix;

  const _DetailBody({
    required this.restaurant,
    this.heroTagPrefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _HeroAppBar(restaurant: restaurant, heroTagPrefix: heroTagPrefix),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _InfoSection(restaurant: restaurant),
              const SizedBox(height: 16),
              _MenuSection(foods: restaurant.foods, drinks: restaurant.drinks),
              const SizedBox(height: 16),
              _ReviewSection(
                restaurantId: restaurant.id,
                reviews: restaurant.customerReviews,
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

class _HeroAppBar extends StatelessWidget {
  final RestaurantDetail restaurant;
  final String heroTagPrefix;

  const _HeroAppBar({
    required this.restaurant,
    this.heroTagPrefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        Builder(
          builder: (context) {
            final favProvider = context.watch<FavoriteProvider>();
            final isFav = favProvider.isFavorite(restaurant.id);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : null,
              ),
              tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
              onPressed: () {
                final r = Restaurant(
                  id: restaurant.id,
                  name: restaurant.name,
                  description: restaurant.description,
                  pictureId: restaurant.pictureId,
                  city: restaurant.city,
                  rating: restaurant.rating,
                );
                context.read<FavoriteProvider>().toggleFavorite(r);
              },
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          restaurant.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        background: Hero(
          tag: '${heroTagPrefix}restaurant_image_${restaurant.id}',
          child: Image.network(
            '${AppConstants.imageLarge}${restaurant.pictureId}',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.broken_image, size: 64),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final RestaurantDetail restaurant;

  const _InfoSection({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantDetailProvider>();
    final expanded = provider.isDescriptionExpanded;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${restaurant.city} · ${restaurant.address}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              restaurant.rating.toString(),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: restaurant.categories
              .map(
                (c) => Chip(
                  label: Text(c),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        Text(
          'Deskripsi',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          restaurant.description,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: expanded ? null : 3,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        TextButton(
          onPressed: () =>
              context.read<RestaurantDetailProvider>().toggleDescription(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(expanded ? 'Sembunyikan' : 'Lihat selengkapnya'),
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<MenuItem> foods;
  final List<MenuItem> drinks;

  const _MenuSection({required this.foods, required this.drinks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MenuColumn(
                title: 'Makanan',
                icon: Icons.restaurant,
                items: foods,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MenuColumn(
                title: 'Minuman',
                icon: Icons.local_drink,
                items: drinks,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuColumn extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<MenuItem> items;

  const _MenuColumn({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewSection extends StatefulWidget {
  final String restaurantId;
  final List<CustomerReview> reviews;

  const _ReviewSection({required this.restaurantId, required this.reviews});

  @override
  State<_ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<_ReviewSection> {
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<RestaurantDetailProvider>();
    final error = await provider.submitReview(
      id: widget.restaurantId,
      name: _nameController.text.trim(),
      review: _reviewController.text.trim(),
    );
    if (!mounted) return;
    if (error == null) {
      _nameController.clear();
      _reviewController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan berhasil dikirim!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ulasan',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...widget.reviews.map((r) => _ReviewCard(review: r)),
        const SizedBox(height: 16),
        Text(
          'Tulis Ulasan',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  labelText: 'Ulasan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ulasan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 10),
              Builder(
                builder: (context) {
                  final provider =
                      context.watch<RestaurantDetailProvider>();
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          provider.isSubmittingReview ? null : _submit,
                      child: provider.isSubmittingReview
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : const Text('Kirim Ulasan'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final CustomerReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    review.name.isNotEmpty
                        ? review.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        review.date,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.review,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
