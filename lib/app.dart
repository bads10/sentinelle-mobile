import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

/// Widget racine de l'application Sentinelle
class SentinelleApp extends ConsumerWidget {
  const SentinelleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Sentinelle',
      debugShowCheckedModeBanner: false,

      // Thème News App
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Navigation
      routerConfig: router,
    );
  }
}
