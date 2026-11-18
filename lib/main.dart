import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/pawpal_app.dart';
import 'core/data/local_database.dart';
import 'core/data/legacy_data_migration.dart';
import 'core/providers/app_providers.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = LocalDatabase();
  await database.open();
  try { await LegacyDataMigration.run(database); } catch (_) { /* Keep legacy preferences intact if migration needs recovery. */ }
  runApp(ProviderScope(overrides: [databaseProvider.overrideWithValue(database)], child: const PawPalApp()));
}
