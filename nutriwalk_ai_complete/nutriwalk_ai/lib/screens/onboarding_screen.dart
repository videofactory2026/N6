import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../providers/app_state_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  int _currentPage = 0;
  String _gender = 'male';
  int _age = 30;
  double _height = 170; // cm
  double _currentWeight = 75; // kg
  double _goalWeight = 70; // kg
  String _activityLevel = 'moderate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildBasicInfoPage(),
                  _buildGoalsPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPage < 2
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : _completeOnboarding,
                      child: Text(_currentPage < 2 ? 'Continue' : 'Get Started'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_walk_rounded,
            size: 120,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to NutriWalk AI',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your AI-powered adaptive metabolic coach that transforms food into personalized movement recommendations',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildFeatureItem(
            icon: Icons.camera_alt_rounded,
            title: 'AI Meal Recognition',
            description: 'Snap photos, get instant calorie estimates',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.show_chart_rounded,
            title: 'Smart Movement Goals',
            description: 'Personalized step targets based on your food',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.psychology_rounded,
            title: 'Adaptive Learning',
            description: 'Gets smarter as it learns your behavior',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us calculate your personalized targets',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          
          // Gender
          Text('Gender', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'male', label: Text('Male'), icon: Icon(Icons.male)),
              ButtonSegment(value: 'female', label: Text('Female'), icon: Icon(Icons.female)),
            ],
            selected: {_gender},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => _gender = newSelection.first);
            },
          ),
          const SizedBox(height: 24),
          
          // Age
          Text('Age: $_age years', style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _age.toDouble(),
            min: 18,
            max: 80,
            divisions: 62,
            label: _age.toString(),
            onChanged: (value) => setState(() => _age = value.round()),
          ),
          const SizedBox(height: 16),
          
          // Height
          Text('Height: ${_height.round()} cm', style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _height,
            min: 140,
            max: 220,
            divisions: 80,
            label: '${_height.round()} cm',
            onChanged: (value) => setState(() => _height = value),
          ),
          const SizedBox(height: 16),
          
          // Current Weight
          Text('Current Weight: ${_currentWeight.round()} kg', 
               style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _currentWeight,
            min: 40,
            max: 150,
            divisions: 110,
            label: '${_currentWeight.round()} kg',
            onChanged: (value) => setState(() => _currentWeight = value),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your goals',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your target weight and activity level',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          
          // Goal Weight
          Text('Goal Weight: ${_goalWeight.round()} kg', 
               style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _goalWeight,
            min: 40,
            max: _currentWeight,
            divisions: (_currentWeight - 40).round(),
            label: '${_goalWeight.round()} kg',
            onChanged: (value) => setState(() => _goalWeight = value),
          ),
          const SizedBox(height: 24),
          
          // Activity Level
          Text('Activity Level', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...['sedentary', 'light', 'moderate', 'active', 'very_active'].map((level) {
            return RadioListTile<String>(
              title: Text(_getActivityLabel(level)),
              subtitle: Text(_getActivityDescription(level)),
              value: level,
              groupValue: _activityLevel,
              onChanged: (value) => setState(() => _activityLevel = value!),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getActivityLabel(String level) {
    switch (level) {
      case 'sedentary': return 'Sedentary';
      case 'light': return 'Light';
      case 'moderate': return 'Moderate';
      case 'active': return 'Active';
      case 'very_active': return 'Very Active';
      default: return level;
    }
  }

  String _getActivityDescription(String level) {
    switch (level) {
      case 'sedentary': return 'Little or no exercise';
      case 'light': return 'Light exercise 1-3 days/week';
      case 'moderate': return 'Moderate exercise 3-5 days/week';
      case 'active': return 'Hard exercise 6-7 days/week';
      case 'very_active': return 'Very hard exercise daily';
      default: return '';
    }
  }

  Future<void> _completeOnboarding() async {
    final profile = UserProfile(
      id: const Uuid().v4(),
      age: _age,
      height: _height,
      currentWeight: _currentWeight,
      goalWeight: _goalWeight,
      activityLevel: _activityLevel,
      gender: _gender,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    await appState.saveUserProfile(profile);
    await appState.refreshAll();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
}
