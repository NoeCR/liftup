import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar las imágenes de fondo de las rutinas
class BackgroundImageService {
  static const String _prefsKey = 'routine_background_images';

  // Imágenes por defecto disponibles
  static const List<String> _defaultImages = [
    'assets/images/bench_press.png',
    'assets/images/pull_ups.png',
    'assets/images/squats.png',
    'assets/images/default_exercise.png',
  ];

  /// Obtiene la imagen de fondo para una rutina específica
  static Future<String?> getBackgroundImageForRoutine(String routineId) async {
    final prefs = await SharedPreferences.getInstance();
    final imagesJson = prefs.getString('$_prefsKey:$routineId');

    if (imagesJson != null) {
      return imagesJson;
    }

    return null;
  }

  /// Establece la imagen de fondo para una rutina específica
  static Future<void> setBackgroundImageForRoutine(String routineId, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefsKey:$routineId', imagePath);
  }

  /// Obtiene todas las imágenes por defecto disponibles
  static List<String> getDefaultImages() {
    return List.from(_defaultImages);
  }

  /// Obtiene todas las imágenes personalizadas del usuario
  static Future<List<String>> getCustomImages() async {
    final prefs = await SharedPreferences.getInstance();
    final customImagesJson = prefs.getString('custom_background_images');

    if (customImagesJson != null) {
      try {
        final List<dynamic> customImages = json.decode(customImagesJson);
        return customImages.cast<String>();
      } catch (e) {
        return [];
      }
    }

    return [];
  }

  /// Agrega una nueva imagen personalizada
  static Future<void> addCustomImage(String imagePath) async {
    final customImages = await getCustomImages();
    customImages.add(imagePath);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_background_images', json.encode(customImages));
  }

  /// Elimina una imagen personalizada
  static Future<void> removeCustomImage(String imagePath) async {
    final customImages = await getCustomImages();
    customImages.remove(imagePath);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_background_images', json.encode(customImages));
  }

  /// Obtiene todas las imágenes disponibles (por defecto + personalizadas)
  static Future<List<String>> getAllAvailableImages() async {
    final defaultImages = getDefaultImages();
    final customImages = await getCustomImages();
    return [...defaultImages, ...customImages];
  }

  /// Verifica si una imagen existe
  static Future<bool> imageExists(String imagePath) async {
    if (imagePath.startsWith('assets/')) {
      // Para assets, asumimos que existe si está en la lista
      return _defaultImages.contains(imagePath);
    } else {
      // Para archivos del sistema
      return await File(imagePath).exists();
    }
  }

  /// Obtiene un color de fondo basado en el nombre de la rutina
  static Color getRoutineColor(String routineName) {
    final hash = routineName.hashCode;
    return Color.fromARGB(255, (hash & 0xFF0000) >> 16, (hash & 0x00FF00) >> 8, hash & 0x0000FF);
  }

  /// Obtiene un gradiente de fondo basado en el nombre de la rutina
  static LinearGradient getRoutineGradient(String routineName) {
    final color = getRoutineColor(routineName);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.6)],
    );
  }
}
