import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/themes/app_theme.dart';
import '../services/background_image_service.dart';

/// Widget para seleccionar imagen de fondo de rutina
class BackgroundImageSelector extends StatefulWidget {
  final String routineId;
  final String routineName;
  final String? currentImagePath;
  final Function(String?) onImageSelected;

  const BackgroundImageSelector({
    super.key,
    required this.routineId,
    required this.routineName,
    this.currentImagePath,
    required this.onImageSelected,
  });

  @override
  State<BackgroundImageSelector> createState() =>
      _BackgroundImageSelectorState();
}

class _BackgroundImageSelectorState extends State<BackgroundImageSelector> {
  String? _selectedImagePath;
  List<String> _availableImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.currentImagePath;
    _loadAvailableImages();
  }

  Future<void> _loadAvailableImages() async {
    setState(() => _isLoading = true);

    try {
      final images = await BackgroundImageService.getAllAvailableImages();
      setState(() {
        _availableImages = images;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await BackgroundImageService.addCustomImage(image.path);
        await _loadAvailableImages();
        setState(() {
          _selectedImagePath = image.path;
        });
        widget.onImageSelected(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('home.errorPickingImage')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await BackgroundImageService.addCustomImage(image.path);
        await _loadAvailableImages();
        setState(() {
          _selectedImagePath = image.path;
        });
        widget.onImageSelected(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('home.errorPickingImage')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _removeCustomImage(String imagePath) async {
    try {
      await BackgroundImageService.removeCustomImage(imagePath);
      await _loadAvailableImages();

      if (_selectedImagePath == imagePath) {
        setState(() {
          _selectedImagePath = null;
        });
        widget.onImageSelected(null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('home.errorRemovingImage')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.image_outlined, color: colorScheme.primary),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    context.tr('home.selectBackgroundImage'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Add image buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(context.tr('home.fromGallery')),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(context.tr('home.fromCamera')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Current selection
            if (_selectedImagePath != null) ...[
              Text(
                context.tr('home.currentSelection'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  child: _buildImagePreview(_selectedImagePath!),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
            ],

            // Available images
            Text(
              context.tr('home.availableImages'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),

            // Images grid
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _availableImages.isEmpty
                      ? Center(
                        child: Text(
                          context.tr('home.noImagesAvailable'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      )
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: AppTheme.spacingS,
                              mainAxisSpacing: AppTheme.spacingS,
                              childAspectRatio: 1.2,
                            ),
                        itemCount: _availableImages.length,
                        itemBuilder: (context, index) {
                          final imagePath = _availableImages[index];
                          final isSelected = _selectedImagePath == imagePath;
                          final isCustom = !imagePath.startsWith('assets/');

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImagePath = imagePath;
                              });
                              widget.onImageSelected(imagePath);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusM,
                                ),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? colorScheme.primary
                                          : colorScheme.outline.withValues(
                                            alpha: 0.3,
                                          ),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusM,
                                    ),
                                    child: _buildImagePreview(imagePath),
                                  ),
                                  if (isSelected)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusM,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  if (isCustom)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap:
                                            () => _removeCustomImage(imagePath),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: colorScheme.error,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Bottom buttons
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImagePath = null;
                      });
                      widget.onImageSelected(null);
                    },
                    child: Text(context.tr('home.removeImage')),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.tr('common.save')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          );
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          );
        },
      );
    }
  }
}
