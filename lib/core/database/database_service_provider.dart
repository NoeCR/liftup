import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'database_service.dart';

part 'database_service_provider.g.dart';

@riverpod
DatabaseService databaseService(DatabaseServiceRef ref) {
  return DatabaseService.getInstance();
}

