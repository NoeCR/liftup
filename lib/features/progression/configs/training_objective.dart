enum TrainingObjective {
  strength(
    titleKey: 'objective.strength.title',
    descriptionKey: 'objective.strength.description',
  ),
  hypertrophy(
    titleKey: 'objective.hypertrophy.title',
    descriptionKey: 'objective.hypertrophy.description',
  ),
  endurance(
    titleKey: 'objective.endurance.title',
    descriptionKey: 'objective.endurance.description',
  ),
  power(
    titleKey: 'objective.power.title',
    descriptionKey: 'objective.power.description',
  );

  const TrainingObjective({
    required this.titleKey,
    required this.descriptionKey,
  });
  final String titleKey;
  final String descriptionKey;
}
