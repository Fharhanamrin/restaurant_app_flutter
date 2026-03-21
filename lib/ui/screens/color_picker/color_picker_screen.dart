import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';

class ColorPickerScreen extends StatelessWidget {
  const ColorPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pilih Warna Tema'),
      ),
      body: Builder(
        builder: (context) {
          final theme = context.watch<ThemeProvider>();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ThemeProvider.availableColors.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final appColor = ThemeProvider.availableColors[index];
              final isSelected = theme.seedColor == appColor.color;

              return _ColorTile(
                appColor: appColor,
                isSelected: isSelected,
                onTap: () =>
                    context.read<ThemeProvider>().setColor(appColor.color),
              );
            },
          );
        },
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final AppColor appColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorTile({
    required this.appColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appColor.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: appColor.color.withAlpha(100),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  appColor.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
