import 'package:flutter/material.dart';

import '../models/exercise.dart';
import 'animated_exercise_card.dart';

class AnimationTestWidget extends StatefulWidget {
  const AnimationTestWidget({super.key});

  @override
  State<AnimationTestWidget> createState() => _AnimationTestWidgetState();
}

class _AnimationTestWidgetState extends State<AnimationTestWidget> {
  late Exercise _testExercise;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _testExercise = Exercise(
      id: 'test-1',
      name: 'Test Exercise',
      description: 'This is a test exercise for animation testing',
      muscleGroups: [],
      tips: [],
      commonMistakes: [],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.beginner,
      imageUrl: '',
      isFavorite: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      _testExercise = _testExercise.copyWith(isFavorite: _isFavorite);
    });

    print('🎯 Test: Toggle favorite to $_isFavorite');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animation Test'), backgroundColor: Colors.blue),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tap the heart to test animation', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            AnimatedExerciseCard(
              exercise: _testExercise,
              index: 0,
              onFavoriteToggle: _toggleFavorite,
              onTap: () => print('🎯 Test: Card tapped'),
              onLongPress: () => print('🎯 Test: Card long pressed'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleFavorite,
              child: Text(_isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
            ),
          ],
        ),
      ),
    );
  }
}
