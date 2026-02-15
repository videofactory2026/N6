import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/meal_log.dart';
import '../services/food_recognition_service.dart';
import '../providers/app_state_provider.dart';

class MealCaptureScreen extends StatefulWidget {
  const MealCaptureScreen({super.key});

  @override
  State<MealCaptureScreen> createState() => _MealCaptureScreenState();
}

class _MealCaptureScreenState extends State<MealCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final FoodRecognitionService _foodService = FoodRecognitionService();
  
  File? _imageFile;
  List<FoodItem> _recognizedItems = [];
  bool _isProcessing = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
      ),
      body: _imageFile == null ? _buildCapturePage() : _buildResultsPage(),
    );
  }

  Widget _buildCapturePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 120, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Take a photo of your meal',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI will recognize the food',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _captureImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPage() {
    return _isProcessing
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analyzing your meal...'),
              ],
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
              ),
              const SizedBox(height: 24),
              Text(
                'Recognized Items',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ..._recognizedItems.asMap().entries.map((entry) {
                return _buildFoodItemCard(entry.key, entry.value);
              }).toList(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveMeal,
                child: const Text('Save Meal'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _imageFile = null),
                child: const Text('Retake Photo'),
              ),
            ],
          );
  }

  Widget _buildFoodItemCard(int index, FoodItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(item.confidence * 100).round()}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${item.adjustedCalories.round()} kcal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMacroChip('P', item.adjustedProtein.round(), Colors.blue),
                const SizedBox(width: 8),
                _buildMacroChip('C', item.adjustedCarbs.round(), Colors.orange),
                const SizedBox(width: 8),
                _buildMacroChip('F', item.adjustedFat.round(), Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            Text('Portion size:', style: TextStyle(color: Colors.grey[600])),
            Slider(
              value: item.portionMultiplier,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: '${(item.portionMultiplier * 100).round()}%',
              onChanged: (value) {
                setState(() {
                  _recognizedItems[index] = item.copyWith(portionMultiplier: value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: ${value}g',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() => _imageFile = File(image.path));
      await _processImage();
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() => _imageFile = File(image.path));
      await _processImage();
    }
  }

  Future<void> _processImage() async {
    setState(() => _isProcessing = true);
    
    try {
      final items = await _foodService.recognizeFood(_imageFile!);
      setState(() {
        _recognizedItems = items;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to analyze image')),
        );
      }
    }
  }

  Future<void> _saveMeal() async {
    final totalCalories = _recognizedItems.fold<double>(
      0, (sum, item) => sum + item.adjustedCalories
    );
    final totalProtein = _recognizedItems.fold<double>(
      0, (sum, item) => sum + item.adjustedProtein
    );
    final totalCarbs = _recognizedItems.fold<double>(
      0, (sum, item) => sum + item.adjustedCarbs
    );
    final totalFat = _recognizedItems.fold<double>(
      0, (sum, item) => sum + item.adjustedFat
    );

    final meal = MealLog(
      id: const Uuid().v4(),
      date: DateTime.now(),
      items: _recognizedItems,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      imagePath: _imageFile?.path,
      createdAt: DateTime.now(),
    );

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    await appState.addMeal(meal);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
