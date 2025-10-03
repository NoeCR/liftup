import 'package:mocktail/mocktail.dart';
import 'package:liftup/features/statistics/services/progress_service.dart';
import 'package:liftup/features/statistics/models/progress_data.dart';

class MockProgressService extends Mock implements ProgressService {
  static MockProgressService? _instance;

  static MockProgressService getInstance() {
    _instance ??= MockProgressService();
    return _instance!;
  }

  void setupMockBehavior() {
    // Setup default mock behavior
    when(() => getAllProgressData()).thenAnswer((_) async => []);
    when(() => saveProgressData(any())).thenAnswer((_) async {});
    when(() => getProgressForExercise(any())).thenAnswer((_) async => []);
    when(
      () => getProgressInDateRange(any(), any()),
    ).thenAnswer((_) async => []);
    when(() => clearAllProgressData()).thenAnswer((_) async {});
    when(() => refreshProgressData(any())).thenAnswer((_) async => []);
  }

  void clearMockData() {
    reset(this);
    setupMockBehavior();
  }

  void setupMockProgressData(List<ProgressData> progressData) {
    when(() => getAllProgressData()).thenAnswer((_) async => progressData);
  }

  void setupMockSaveProgressData() {
    when(() => saveProgressData(any())).thenAnswer((_) async {});
  }

  void setupMockGetProgressForExercise(List<ProgressData> progressData) {
    when(
      () => getProgressForExercise(any()),
    ).thenAnswer((_) async => progressData);
  }

  void setupMockGetProgressInDateRange(List<ProgressData> progressData) {
    when(
      () => getProgressInDateRange(any(), any()),
    ).thenAnswer((_) async => progressData);
  }

  void setupMockRefreshProgressData(List<ProgressData> progressData) {
    when(
      () => refreshProgressData(any()),
    ).thenAnswer((_) async => progressData);
  }
}
