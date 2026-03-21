import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';

class FontPickerScreen extends StatelessWidget {
  const FontPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pilih Font'),
      ),
      body: Builder(
        builder: (context) {
          final theme = context.watch<ThemeProvider>();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ThemeProvider.availableFonts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final appFont = ThemeProvider.availableFonts[index];
              final isSelected = theme.selectedFont.label == appFont.label;

              return _FontTile(
                appFont: appFont,
                isSelected: isSelected,
                onTap: () => context.read<ThemeProvider>().setFont(appFont),
              );
            },
          );
        },
      ),
    );
  }
}

class _FontTile extends StatelessWidget {
  final AppFont appFont;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontTile({
    required this.appFont,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appFont.label,
                      style: GoogleFonts.getFont(
                        appFont.label,
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Contoh teks restoran enak',
                      style: GoogleFonts.getFont(
                        appFont.label,
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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
