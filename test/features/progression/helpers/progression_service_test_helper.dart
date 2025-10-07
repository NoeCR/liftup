import 'package:liftly/features/progression/services/progression_service.dart';
import 'package:liftly/core/database/i_database_service.dart';
import '../../../mocks/mock_database_service.dart';

/// Helper class for testing ProgressionService with dependency injection
class ProgressionServiceTestHelper {
  static ProgressionService createWithMockDatabase() {
    final mockDatabase = MockDatabaseService();
    return ProgressionService(databaseService: mockDatabase);
  }

  static ProgressionService createWithCustomDatabase(IDatabaseService databaseService) {
    return ProgressionService(databaseService: databaseService);
  }
}
