import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'database_service.dart';

part 'database_service_provider.g.dart';

/// Provider for the DatabaseService singleton instance
@riverpod
DatabaseService databaseService(Ref ref) {
  return DatabaseService.getInstance();
}



