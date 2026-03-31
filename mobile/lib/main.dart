import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mama_app/app.dart';
import 'package:mama_app/services/database/database.dart';
import 'package:mama_app/services/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final database = AppDatabase();
  
  // Initialize sync service
  final syncService = SyncService(database);
  
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        syncServiceProvider.overrideWithValue(syncService),
      ],
      child: const MamaApp(),
    ),
  );
}
