import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../models/meal_log.dart';

class FoodRecognitionService {
  static final FoodRecognitionService _instance = FoodRecognitionService._internal();
  factory FoodRecognitionService() => _instance;
  FoodRecognitionService._internal();

  // TODO: Replace with actual LogMeal API credentials
  static const String _apiUrl = 'https://api.logmeal.es/v2';
  static const String _apiToken = 'YOUR_LOGMEAL_API_TOKEN'; // Replace in production

  Future<List<FoodItem>> recognizeFood(File imageFile) async {
    try {
      // Step 1: Compress image
      final compressedImage = await _compressImage(imageFile);

      // Step 2: Upload to LogMeal API
      final recognitionResult = await _uploadToLogMeal(compressedImage);

      // Step 3: Parse and normalize results
      final foodItems = _parseLogMealResponse(recognitionResult);

      return foodItems;
    } catch (e) {
      print('Food recognition error: $e');
      // Return mock data for development
      return _getMockFoodItems();
    }
  }

  Future<File> _compressImage(File imageFile) async {
    final originalImage = img.decodeImage(await imageFile.readAsBytes());
    
    if (originalImage == null) throw Exception('Failed to decode image');

    // Resize to max 1024px on longest side
    img.Image resized;
    if (originalImage.width > originalImage.height) {
      resized = img.copyResize(originalImage, width: 1024);
    } else {
      resized = img.copyResize(originalImage, height: 1024);
    }

    // Compress to JPEG with 85% quality
    final compressed = img.encodeJpg(resized, quality: 85);

    // Save to temp file
    final tempPath = '${imageFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressedFile = File(tempPath);
    await compressedFile.writeAsBytes(compressed);

    return compressedFile;
  }

  Future<Map<String, dynamic>> _uploadToLogMeal(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiUrl/recognition/dish'),
      );

      request.headers['Authorization'] = 'Bearer $_apiToken';
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 5),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('LogMeal API error: ${response.statusCode}');
      }
    } catch (e) {
      print('LogMeal upload error: $e');
      rethrow;
    }
  }

  List<FoodItem> _parseLogMealResponse(Map<String, dynamic> response) {
    List<FoodItem> items = [];

    // Parse LogMeal API response structure
    // Actual structure depends on LogMeal API documentation
    if (response.containsKey('recognition_results')) {
      List results = response['recognition_results'];
      
      for (var result in results) {
        if (result['prob'] >= 0.5) { // Confidence threshold
          items.add(FoodItem(
            name: result['name'] ?? 'Unknown Food',
            calories: (result['nutritional_info']?['calories'] ?? 0).toDouble(),
            protein: (result['nutritional_info']?['protein'] ?? 0).toDouble(),
            carbs: (result['nutritional_info']?['carbs'] ?? 0).toDouble(),
            fat: (result['nutritional_info']?['fat'] ?? 0).toDouble(),
            portionMultiplier: 1.0,
            confidence: (result['prob'] ?? 0).toDouble(),
          ));
        }
      }
    }

    return items.isEmpty ? _getMockFoodItems() : items;
  }

  List<FoodItem> _getMockFoodItems() {
    // Mock data for development/testing
    return [
      FoodItem(
        name: 'Grilled Chicken Breast',
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6,
        portionMultiplier: 1.0,
        confidence: 0.89,
      ),
      FoodItem(
        name: 'Rice (cooked)',
        calories: 130,
        protein: 2.7,
        carbs: 28,
        fat: 0.3,
        portionMultiplier: 1.0,
        confidence: 0.92,
      ),
    ];
  }

  // Optional USDA fallback
  Future<FoodItem?> searchUSDA(String foodName) async {
    try {
      // TODO: Implement USDA API integration if needed
      // This is optional as per PRD
      return null;
    } catch (e) {
      print('USDA search error: $e');
      return null;
    }
  }

  Future<List<FoodItem>> manualSearch(String query) async {
    // Simple manual search fallback
    // In production, this could query USDA or other food databases
    return _getMockFoodItems().where((item) => 
      item.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
