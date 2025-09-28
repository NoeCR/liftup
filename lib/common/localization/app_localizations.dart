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
