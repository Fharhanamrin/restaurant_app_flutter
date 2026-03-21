import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/favorite_repository.dart';
import 'data/repositories/favorite_repository_impl.dart';
import 'data/repositories/restaurant_repository.dart';
import 'data/repositories/restaurant_repository_impl.dart';
import 'providers/favorite_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/restaurant_detail_provider.dart';
import 'providers/restaurant_list_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/screens/main/main_screen.dart';

class App extends StatelessWidget {
  final SharedPreferences prefs;

  const App({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RestaurantRepository>(
          create: (_) => RestaurantRepositoryImpl(),
        ),
        Provider<FavoriteRepository>(
          create: (_) => FavoriteRepositoryImpl(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RestaurantListProvider(context.read<RestaurantRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RestaurantDetailProvider(context.read<RestaurantRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              SearchProvider(context.read<RestaurantRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              FavoriteProvider(context.read<FavoriteRepository>()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = context.watch<ThemeProvider>();
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(
              themeProvider.seedColor,
              themeProvider.selectedFont.textTheme,
            ),
            darkTheme: AppTheme.dark(
              themeProvider.seedColor,
              themeProvider.selectedFont.textTheme,
            ),
            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
