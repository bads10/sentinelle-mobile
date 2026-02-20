import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

/// Point d'entrée de l'application Sentinelle Mobile
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation du cache local Hive
  await Hive.initFlutter();

  runApp(
    // ProviderScope requis par Riverpod
    const ProviderScope(
      child: SentinelleApp(),
    ),
  );
}
