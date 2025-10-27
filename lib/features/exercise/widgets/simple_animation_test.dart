import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleAnimationTest extends StatefulWidget {
  const SimpleAnimationTest({super.key});

  @override
  State<SimpleAnimationTest> createState() => _SimpleAnimationTestState();
}

class _SimpleAnimationTestState extends State<SimpleAnimationTest> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    print('🎯 SimpleAnimationTest: Toggle favorite to $_isFavorite');

    if (_isFavorite) {
      // Feedback háptico
      HapticFeedback.lightImpact();

      // Animar
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Animation Test'), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tap the heart to test animation', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            // Card con animación
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Card(
                      elevation: 8,
                      margin: const EdgeInsets.all(16),
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Imagen simulada
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.fitness_center, size: 30, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),

                            // Título
                            const Text('Test Exercise', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),

                            // Descripción
                            const Text(
                              'This is a test exercise for animation testing',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 12),

                            // Botón de favorito
                            IconButton(
                              onPressed: _toggleFavorite,
                              icon: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.grey,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Botón de prueba
            ElevatedButton(
              onPressed: _toggleFavorite,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFavorite ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 12),

            // Estado actual
            Text(
              'Estado: ${_isFavorite ? "Favorito" : "No favorito"}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
