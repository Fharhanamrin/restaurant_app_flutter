import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/reminder_provider.dart';
import '../../../providers/theme_provider.dart';
import '../color_picker/color_picker_screen.dart';
import '../font_picker/font_picker_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'Tema'),
          Builder(
            builder: (context) {
              final theme = context.watch<ThemeProvider>();
              return SwitchListTile(
                title: const Text('Mode Gelap'),
                subtitle: Text(theme.isDark ? 'Aktif' : 'Nonaktif'),
                secondary: Icon(
                  theme.isDark ? Icons.dark_mode : Icons.light_mode,
                ),
                value: theme.isDark,
                onChanged: (_) => context.read<ThemeProvider>().toggle(),
              );
            },
          ),
          const Divider(),
          _SectionHeader(title: 'Notifikasi'),
          Builder(
            builder: (context) {
              final reminder = context.watch<ReminderProvider>();
              return SwitchListTile(
                title: const Text('Pengingat Harian'),
                subtitle: const Text('Pukul 11.00 WIB'),
                secondary: const Icon(Icons.notifications_outlined),
                value: reminder.isEnabled,
                onChanged: (_) => context.read<ReminderProvider>().toggle(),
              );
            },
          ),
          const Divider(),
          _SectionHeader(title: 'Tampilan'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Warna Tema'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ColorPickerScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Ganti Font'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FontPickerScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
