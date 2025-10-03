import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      'assets/locales/${locale.languageCode}.json',
    );
    _localizedStrings = json.decode(jsonString);
    return true;
  }

  String translate(String key) {
    final keys = key.split('.');
    dynamic value = _localizedStrings;

    for (String k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return key if translation not found
      }
    }

    return value is String ? value : key;
  }

  // App translations
  String get appTitle => translate('app.title');
  String get appWelcome => translate('app.welcome');
  String get createFirstRoutine => translate('app.createFirstRoutine');
  String get createRoutine => translate('app.createRoutine');

  // Home translations
  String get homeTitle => translate('home.title');
  String get today => translate('home.today');
  String get chest => translate('home.chest');
  String get legs => translate('home.legs');
  String get cardio => translate('home.cardio');
  String get monday => translate('home.monday');
  String get tuesday => translate('home.tuesday');
  String get wednesday => translate('home.wednesday');
  String get thursday => translate('home.thursday');
  String get friday => translate('home.friday');
  String get saturday => translate('home.saturday');
  String get sunday => translate('home.sunday');
  String get noRoutineForToday => translate('home.noRoutineForToday');
  String get enjoyRestDay => translate('home.enjoyRestDay');
  String get addExercises => translate('home.addExercises');
  String get tapToAddExercises => translate('home.tapToAddExercises');

  // Exercise translations
  String get exercisesTitle => translate('exercises.title');
  String get searchPlaceholder => translate('exercises.searchPlaceholder');
  String get all => translate('exercises.all');
  String get back => translate('exercises.back');
  String get shoulders => translate('exercises.shoulders');
  String get arms => translate('exercises.arms');
  String get core => translate('exercises.core');
  String get fullBody => translate('exercises.fullBody');
  String get noExercisesFound => translate('exercises.noExercisesFound');
  String get tryOtherSearchTerms => translate('exercises.tryOtherSearchTerms');
  String get errorLoadingExercises =>
      translate('exercises.errorLoadingExercises');
  String get musclesWorked => translate('exercises.musclesWorked');
  String get tips => translate('exercises.tips');
  String get commonMistakes => translate('exercises.commonMistakes');
  String get demoVideo => translate('exercises.demoVideo');
  String get videoNotAvailable => translate('exercises.videoNotAvailable');
  String get beginner => translate('exercises.beginner');
  String get intermediate => translate('exercises.intermediate');
  String get advanced => translate('exercises.advanced');

  // Session translations
  String get sessionTitle => translate('session.title');
  String get workoutTime => translate('session.workoutTime');
  String get pause => translate('session.pause');
  String get finish => translate('session.finish');
  String get noActiveSession => translate('session.noActiveSession');
  String get startNewSession => translate('session.startNewSession');
  String get startSession => translate('session.startSession');
  String get train => translate('session.train');

  // Statistics translations
  String get statisticsTitle => translate('statistics.title');

  // Settings translations
  String get settingsTitle => translate('settings.title');

  // Common translations
  String get series => translate('common.series');
  String get reps => translate('common.reps');
  String get weight => translate('common.weight');
  String get completed => translate('common.completed');
  String get markAsCompleted => translate('common.markAsCompleted');
  String get retry => translate('common.retry');
  String get error => translate('common.error');
  String get loading => translate('common.loading');
  String get save => translate('common.save');
  String get cancel => translate('common.cancel');
  String get delete => translate('common.delete');
  String get edit => translate('common.edit');
  String get add => translate('common.add');
  String get search => translate('common.search');
  String get filter => translate('common.filter');
  String get export => translate('common.export');
  String get import => translate('common.import');
  String get share => translate('common.share');

  // Progression translations
  String get progressionTitle => translate('progression.title');
  String get configureProgression => translate('progression.configureProgression');
  String get globalProgression => translate('progression.globalProgression');
  String get globalProgressionDescription => translate('progression.globalProgressionDescription');
  String get selectProgressionType => translate('progression.selectProgressionType');
  String get progressionTypes => translate('progression.progressionTypes');
  String get freeTraining => translate('progression.freeTraining');
  String get freeTrainingDescription => translate('progression.freeTrainingDescription');
  String get automaticProgression => translate('progression.automaticProgression');
  String get automaticProgressionDescription => translate('progression.automaticProgressionDescription');
  String get configureProgressionQuestion => translate('progression.configureProgressionQuestion');
  String selectedProgression(String type) => translate('progression.selectedProgression').replaceAll('{type}', type);
  String get progressionContinue => translate('progression.continue');
  String get progressionChange => translate('progression.change');
  String get progressionDisable => translate('progression.disable');
  String get disableProgression => translate('progression.disableProgression');
  String get disableProgressionQuestion => translate('progression.disableProgressionQuestion');
  String get progressionDisabled => translate('progression.progressionDisabled');
  String errorDisablingProgression(String error) => translate('progression.errorDisablingProgression').replaceAll('{error}', error);
  String activeProgression(String type) => translate('progression.activeProgression').replaceAll('{type}', type);
  String get noProgression => translate('progression.noProgression');
  String get progressionConfigure => translate('progression.configure');
  String errorLoadingProgression(String error) => translate('progression.errorLoadingProgression').replaceAll('{error}', error);
  String get progressionConfiguration => translate('progression.progressionConfiguration');
  String get basicConfiguration => translate('progression.basicConfiguration');
  String get advancedConfiguration => translate('progression.advancedConfiguration');
  String get customParameters => translate('progression.customParameters');
  String get progressionUnit => translate('progression.progressionUnit');
  String get progressionUnitHelper => translate('progression.progressionUnitHelper');
  String get primaryTarget => translate('progression.primaryTarget');
  String get primaryTargetHelper => translate('progression.primaryTargetHelper');
  String get secondaryTarget => translate('progression.secondaryTarget');
  String get secondaryTargetHelper => translate('progression.secondaryTargetHelper');
  String get progressionNone => translate('progression.none');
  String get incrementValue => translate('progression.incrementValue');
  String get incrementValueHelper => translate('progression.incrementValueHelper');
  String get incrementFrequency => translate('progression.incrementFrequency');
  String get incrementFrequencyHelper => translate('progression.incrementFrequencyHelper');
  String get progressionSessions => translate('progression.sessions');
  String get progressionWeeks => translate('progression.weeks');
  String get cycleLength => translate('progression.cycleLength');
  String get cycleLengthHelper => translate('progression.cycleLengthHelper');
  String get deloadWeek => translate('progression.deloadWeek');
  String get deloadWeekHelper => translate('progression.deloadWeekHelper');
  String get progressionWeek => translate('progression.week');
  String get deloadPercentage => translate('progression.deloadPercentage');
  String get deloadPercentageHelper => translate('progression.deloadPercentageHelper');
  String get saveProgression => translate('progression.saveProgression');
  String get progressionSaving => translate('progression.saving');
  String progressionConfiguredSuccessfully(String type) => translate('progression.progressionConfiguredSuccessfully').replaceAll('{type}', type);
  String get minReps => translate('progression.minReps');
  String get minRepsHelper => translate('progression.minRepsHelper');
  String get maxReps => translate('progression.maxReps');
  String get maxRepsHelper => translate('progression.maxRepsHelper');

  // Progression types
  String get linearProgression => translate('progression.types.linear');
  String get linearProgressionDescription => translate('progression.types.linearDescription');
  String get undulatingProgression => translate('progression.types.undulating');
  String get undulatingProgressionDescription => translate('progression.types.undulatingDescription');
  String get steppedProgression => translate('progression.types.stepped');
  String get steppedProgressionDescription => translate('progression.types.steppedDescription');
  String get doubleProgression => translate('progression.types.double');
  String get doubleProgressionDescription => translate('progression.types.doubleDescription');
  String get waveProgression => translate('progression.types.wave');
  String get waveProgressionDescription => translate('progression.types.waveDescription');
  String get staticProgression => translate('progression.types.static');
  String get staticProgressionDescription => translate('progression.types.staticDescription');
  String get reverseProgression => translate('progression.types.reverse');
  String get reverseProgressionDescription => translate('progression.types.reverseDescription');
  String get noProgressionType => translate('progression.types.none');

  // Progression units
  String get progressionUnitSession => translate('progression.units.session');
  String get progressionUnitWeek => translate('progression.units.week');
  String get progressionUnitMonth => translate('progression.units.month');

  // Progression targets
  String get progressionTargetWeight => translate('progression.targets.weight');
  String get progressionTargetReps => translate('progression.targets.reps');
  String get progressionTargetSets => translate('progression.targets.sets');
  String get progressionTargetVolume => translate('progression.targets.volume');

  // Progression difficulties
  String get progressionDifficultyBeginner => translate('progression.difficulties.beginner');
  String get progressionDifficultyIntermediate => translate('progression.difficulties.intermediate');
  String get progressionDifficultyAdvanced => translate('progression.difficulties.advanced');

  // Error translations
  String get pageNotFound => translate('errors.pageNotFound');
  String get pageNotFoundDescription =>
      translate('errors.pageNotFoundDescription');
  String get backToHome => translate('errors.backToHome');
  String get errorLoadingData => translate('errors.errorLoadingData');
  String get errorLoadingExercise => translate('errors.errorLoadingExercise');
  String get exerciseNotFound => translate('errors.exerciseNotFound');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
