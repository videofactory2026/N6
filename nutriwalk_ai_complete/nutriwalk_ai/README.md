# NutriWalk AI - Intelligent Adaptive Metabolic Coaching

Version 1.0.0 - Production Ready Flutter Application

## 📱 Overview

NutriWalk AI is an AI-powered adaptive metabolic coaching application that creates a closed-loop system connecting:
- 📸 AI Meal Recognition
- 🦶 Real-time Step Tracking
- ⚖ Daily Weight Tracking
- 🧠 Adaptive Behavioral Learning
- 🌙 Smart Evening Nudges
- 📊 Weekly Metabolic Intelligence

## 🏗️ Architecture

**Frontend**: Flutter 3.19+ (Dart)
**Database**: SQLite (local storage)
**Encryption**: AES-256 with SecureStorage
**CI/CD**: Codemagic
**Platforms**: Android 8+ (iOS support ready)

## 📋 Prerequisites

1. **Flutter SDK** 3.19.0 or higher
2. **Android Studio** with Android SDK 26+
3. **Codemagic Account** (for CI/CD)
4. **LogMeal API Key** (for food recognition)

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd nutriwalk_ai
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure API Keys

Create `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String logMealApiToken = 'YOUR_LOGMEAL_API_TOKEN_HERE';
  static const String logMealApiUrl = 'https://api.logmeal.es/v2';
}
```

Then update `lib/services/food_recognition_service.dart`:
```dart
import '../config/api_config.dart';
// ...
static const String _apiToken = ApiConfig.logMealApiToken;
```

### 4. Run the App
```bash
flutter run
```

## 🔐 Signing Setup (Production)

### Android Keystore

1. Generate keystore:
```bash
keytool -genkey -v -keystore nutriwalk-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias nutriwalk
```

2. Create `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=nutriwalk
storeFile=../nutriwalk-release-key.jks
```

3. Add to `.gitignore`:
```
*.jks
key.properties
```

## ⚙️ Codemagic Configuration

The project includes `codemagic.yaml` configured for:
- Android AAB builds
- iOS IPA builds
- Automated versioning
- Play Store deployment

### Required Environment Variables in Codemagic:

**Android:**
- `KEYSTORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`
- `KEYSTORE_PATH`
- `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`

**iOS:**
- Apple Developer credentials (auto-configured in Codemagic)

**Common:**
- `RECIPIENT_EMAIL` - for build notifications

## 📂 Project Structure

```
nutriwalk_ai/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/                      # Data models
│   │   ├── user_profile.dart
│   │   ├── meal_log.dart
│   │   ├── activity_log.dart
│   │   └── behavior_profile.dart
│   ├── services/                    # Core services
│   │   ├── database_service.dart
│   │   ├── encrypted_storage_service.dart
│   │   ├── food_recognition_service.dart
│   │   └── health_service.dart
│   ├── engines/                     # Intelligence engines
│   │   ├── calorie_movement_engine.dart
│   │   ├── weekly_intelligence_engine.dart
│   │   ├── adaptive_learning_engine.dart
│   │   └── smart_nudge_engine.dart
│   ├── screens/                     # UI screens
│   │   ├── home_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── meal_capture_screen.dart
│   │   ├── weekly_insights_screen.dart
│   │   ├── weight_tracking_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/                     # Reusable widgets
│   │   ├── daily_summary_card.dart
│   │   ├── movement_recommendation_card.dart
│   │   └── meal_list_widget.dart
│   └── providers/                   # State management
│       └── app_state_provider.dart
├── android/                         # Android configuration
├── ios/                            # iOS configuration
├── codemagic.yaml                  # CI/CD configuration
└── pubspec.yaml                    # Dependencies
```

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 🏗️ Building

### Development Build
```bash
flutter build apk --debug
```

### Production Build
```bash
flutter build appbundle --release
```

## 🎯 Core Features Implementation

### ✅ Implemented Features

1. **AI Meal Recognition**
   - Image capture & compression
   - LogMeal API integration
   - Portion size adjustment (0.5x - 2x)
   - Confidence scoring
   - Manual food search fallback

2. **Health Connect Integration**
   - Step tracking with aggregation
   - Distance calculation
   - Pedometer fallback
   - Background sync (30 min intervals)
   - Manual entry override

3. **Calorie → Movement Engine**
   - BMR calculation (Mifflin-St Jeor)
   - TDEE computation
   - Dynamic step targets
   - Time/distance recommendations
   - Before-sleep suggestions

4. **Weekly Intelligence**
   - 7-day deficit tracking
   - Average metrics calculation
   - Compliance monitoring
   - Advisory generation
   - Anti-punishment logic

5. **Adaptive Learning**
   - Behavior profiling
   - Compliance rate tracking
   - Dynamic target adjustment
   - Preferred activity hour detection
   - Personalized messaging

6. **Smart Evening Nudges**
   - Time-window enforcement (8-9 PM)
   - Suppression rules (max 1/day)
   - Ignore-rate tracking
   - Context-aware messaging
   - User feedback recording

7. **Weight Tracking**
   - Daily weight logging
   - 7-day moving average
   - Trend visualization
   - Plateau detection (14 days)

8. **Data Security**
   - AES-256 encryption
   - SecureStorage for keys
   - GDPR compliance
   - Data reset options
   - Privacy controls

## 🔧 Troubleshooting

### Health Connect Issues
- Ensure Health Connect is installed on device
- Grant all requested permissions
- Check background sync is enabled

### Food Recognition Timeout
- Check internet connection
- Verify LogMeal API key
- Try smaller image sizes

### Build Failures
- Run `flutter clean` and `flutter pub get`
- Verify Gradle and Kotlin versions
- Check Android SDK installation

## 📊 Performance Metrics

Target metrics as per PRD:
- Daily Active Users: > 40% retention
- 30-day retention: > 25%
- Avg daily steps increase: +1,500
- 3kg loss in 3 months: ≥ 70%
- AI recognition accuracy: ≥ 85%
- Evening nudge fatigue: < 15%

## 🔮 Future Roadmap (v2+)

- Conversational AI coach
- Cloud sync + multi-device
- Lab tracking dashboard
- Grocery planner
- Apple Health integration
- Smartwatch haptics
- Advanced ML metabolic prediction

## 📄 License

Proprietary - All rights reserved

## 👥 Support

For support, please contact: [Your Support Email]

## 🙏 Acknowledgments

- LogMeal API for food recognition
- Flutter team for the framework
- Health Connect team for health data integration

---

**Launch Status**: ✅ PRODUCTION READY

All PRD requirements implemented. Ready for Codemagic deployment.
