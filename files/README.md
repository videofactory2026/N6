# NutriWalk AI - Flutter Edition

**AI-Powered Adaptive Metabolic Coaching Application**

NutriWalk AI is a comprehensive health and nutrition tracking app that combines AI-powered meal recognition, step tracking, and intelligent nudging to help users achieve their metabolic health goals.

---

## 🎯 Project Overview

### Core Features

**1. AI Meal Recognition**
- Photo-based meal logging using camera
- Automatic calorie calculation via LogMeal API + USDA fallback
- Manual meal editing and refinement
- Daily meal history with nutritional breakdown

**2. Activity Tracking**
- Step counting via Health Connect (Android) / HealthKit (iOS)
- Pedometer fallback for devices without health integration
- Daily step goals with adaptive targets
- Calorie-to-walk conversion (shows walk time needed to burn meals)

**3. Weight & Progress Tracking**
- Daily weight logging
- Visual progress charts (weight trends, calorie intake)
- Weekly insights and analytics
- Behavioral pattern recognition

**4. Smart Nudges & Adaptive Learning**
- Evening nudges (8-9 PM) encouraging activity
- Adaptive nudge tone based on user engagement
- Weekly intelligence reports
- Phase 1 adaptive learning:
  - Dynamic step target adjustment (7-day rolling average)
  - Nudge effectiveness tracking
  - Behavioral profile building

**5. Security & Privacy**
- Local AES-256 encryption for all user data
- Secure key storage using FlutterSecureStorage
- No cloud data sync (privacy-first approach)
- SQLite database with encrypted blobs

---

## 📁 Project Structure

```
nutriwalk_flutter_complete/
├── android/                          # Android native configuration
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml  # Permissions & Health Connect setup
│   │   │   └── kotlin/...           # Native Android code
│   │   └── build.gradle             # App-level Gradle config
│   ├── gradle/
│   └── build.gradle                 # Project-level Gradle config
│
├── ios/                              # iOS native configuration
│   ├── Runner/
│   │   ├── Info.plist               # iOS permissions & HealthKit setup
│   │   └── AppDelegate.swift
│   ├── Podfile                      # CocoaPods dependencies
│   └── Runner.xcworkspace
│
├── lib/                              # Main Flutter application code
│   ├── main.dart                    # App entry point
│   │
│   ├── screens/                     # UI Screens
│   │   ├── onboarding_screen.dart   # User profile setup
│   │   ├── home_screen.dart         # Main dashboard (Today view)
│   │   ├── meal_camera_screen.dart  # Camera for meal photos
│   │   ├── meal_recognition_screen.dart  # AI processing & results
│   │   ├── add_meal_screen.dart     # Manual meal entry
│   │   ├── progress_screen.dart     # Charts & analytics
│   │   ├── weekly_insights_screen.dart  # Weekly reports
│   │   └── settings_screen.dart     # App settings
│   │
│   ├── widgets/                     # Reusable UI components
│   │   ├── meal_card.dart           # Meal log display card
│   │   ├── stat_card.dart           # Dashboard stat cards
│   │   ├── progress_chart.dart      # Weight/calorie charts
│   │   └── custom_button.dart       # Themed buttons
│   │
│   ├── models/                      # Data models
│   │   ├── user_profile.dart        # User settings & goals
│   │   ├── meal_log.dart            # Meal entries
│   │   ├── activity_log.dart        # Steps & activity data
│   │   └── behavior_profile.dart    # Adaptive learning data
│   │
│   ├── services/                    # Business logic & APIs
│   │   ├── database_service.dart    # SQLite operations
│   │   ├── encrypted_storage_service.dart  # AES encryption wrapper
│   │   ├── health_service.dart      # Health Connect / HealthKit
│   │   ├── food_recognition_service.dart  # LogMeal API integration
│   │   └── notification_service.dart  # Local notifications
│   │
│   ├── engines/                     # AI & Intelligence modules
│   │   ├── calorie_movement_engine.dart  # Calorie-to-walk conversion
│   │   ├── smart_nudge_engine.dart  # Evening nudge logic
│   │   ├── adaptive_learning_engine.dart  # Behavioral adaptation
│   │   └── weekly_intelligence_engine.dart  # Weekly reports
│   │
│   ├── providers/                   # State management
│   │   └── app_state_provider.dart  # Global app state (Provider)
│   │
│   └── utils/                       # Helper utilities
│       ├── constants.dart           # App-wide constants
│       └── helpers.dart             # Utility functions
│
├── assets/                           # Static resources
│   ├── images/                      # App images/icons
│   └── fonts/                       # Custom fonts
│
├── test/                             # Unit & widget tests
│   └── widget_test.dart
│
├── .github/                          # GitHub configuration
│   └── workflows/
│       └── ci.yml                   # GitHub Actions CI
│
├── codemagic.yaml                   # Codemagic CI/CD configuration
├── pubspec.yaml                     # Flutter dependencies
├── .gitignore                       # Git ignore rules
└── README.md                        # This file
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.19.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for platform-specific builds)
- LogMeal API Key (for meal recognition)
- Supabase account (optional, for backend sync)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/nutriwalk-flutter.git
   cd nutriwalk-flutter
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the project root:
   ```env
   LOGMEAL_API_KEY=your_logmeal_api_key_here
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Run the app**
   
   For Android:
   ```bash
   flutter run --debug
   ```
   
   For iOS:
   ```bash
   flutter run --debug
   ```

### Health Permissions Setup

**Android (Health Connect)**
- Requires Android 14+ or Health Connect app installed
- Permissions are requested on first launch
- Configured in `android/app/src/main/AndroidManifest.xml`

**iOS (HealthKit)**
- Permissions configured in `ios/Runner/Info.plist`
- Requested on first launch

---

## 🔧 Backend Setup (Optional)

The app can work standalone, but for AI meal recognition, you need the backend:

```bash
cd backend
npm install
cp .env.example .env
# Fill in: LOGMEAL_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
npm run dev
```

Backend runs on `http://localhost:8787`

---

## 🏗️ Build & Deployment

### Local Builds

**Android APK**
```bash
flutter build apk --release
```

**Android App Bundle (for Play Store)**
```bash
flutter build appbundle --release
```

**iOS IPA**
```bash
flutter build ipa --release
```

### Automated CI/CD with Codemagic

This project includes a complete `codemagic.yaml` configuration for automated builds:

**Setup Steps:**

1. **Connect to Codemagic**
   - Sign in to [codemagic.io](https://codemagic.io)
   - Add your GitHub repository

2. **Configure Environment Variables**
   
   In Codemagic dashboard, add these environment variable groups:
   
   **Group: `nutriwalk_production`**
   - `KEYSTORE_PASSWORD` - Android keystore password
   - `KEY_PASSWORD` - Android key password
   - `KEY_ALIAS` - Android key alias
   - `RECIPIENT_EMAIL` - Email for build notifications
   - `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` - Google Play service account JSON
   
3. **Add Signing Certificates**
   
   **Android:**
   - Upload keystore file as `nutriwalk_keystore`
   
   **iOS:**
   - Connect App Store Connect API
   - Add distribution certificates & provisioning profiles

4. **Trigger Builds**
   - Push to `main` branch for production builds
   - Manual trigger via Codemagic dashboard

**Available Workflows:**
- `android-workflow` - Builds AAB and uploads to Google Play Internal Testing
- `ios-workflow` - Builds IPA and uploads to TestFlight

---

## 📦 Dependencies

### Core Dependencies
- `provider: ^6.1.1` - State management
- `google_fonts: ^6.1.0` - Custom fonts
- `fl_chart: ^0.66.0` - Charts & graphs

### Storage & Security
- `sqflite: ^2.3.0` - Local SQLite database
- `shared_preferences: ^2.2.2` - Simple key-value storage
- `flutter_secure_storage: ^9.0.0` - Secure key storage
- `encrypt: ^5.0.3` - AES encryption

### Health & Sensors
- `health: ^10.1.0` - Health Connect / HealthKit integration
- `pedometer: ^4.0.1` - Step counting fallback
- `permission_handler: ^11.1.0` - Permission management

### Media & Network
- `image_picker: ^1.0.7` - Camera & gallery access
- `http: ^1.1.2` - HTTP requests
- `dio: ^5.4.0` - Advanced HTTP client

### Notifications
- `flutter_local_notifications: ^16.3.0` - Local notifications
- `timezone: ^0.9.2` - Timezone support for scheduled notifications

---

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/widget_test.dart
```

Generate coverage report:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 🎨 Design System

### Color Palette
- **Primary:** `#6366F1` (Indigo)
- **Background:** `#F8FAFC` (Light Gray)
- **Card:** `#FFFFFF` (White)
- **Text:** `#0F172A` (Dark Slate)
- **Success:** `#10B981` (Green)
- **Warning:** `#F59E0B` (Amber)
- **Error:** `#EF4444` (Red)

### Typography
- **Font Family:** Inter (via Google Fonts)
- **Headings:** Bold, 24-32px
- **Body:** Regular, 14-16px
- **Captions:** Medium, 12-14px

### Components
- **Cards:** 16px border radius, no elevation, white background
- **Buttons:** 12px border radius, 16px vertical padding
- **Input Fields:** 8px border radius, outlined style

---

## 🔐 Security & Privacy

**Data Encryption:**
- All user data stored in encrypted JSON blobs
- AES-256 encryption using `encrypt` package
- Encryption keys stored in FlutterSecureStorage
- No plain-text sensitive data in database

**Privacy:**
- No analytics or telemetry by default
- No cloud sync (user data stays on device)
- Camera/health permissions requested with clear explanations
- Users can delete all data from settings

**Compliance:**
- GDPR-ready (data export/deletion)
- HIPAA considerations (local storage only)
- App Store privacy labels documented

---

## 📱 Supported Platforms

- ✅ Android 10+ (API 29+)
- ✅ iOS 14.0+
- ✅ Health Connect (Android 14+)
- ✅ HealthKit (iOS)

---

## 🛣️ Roadmap

### Phase 1 (MVP) - ✅ Complete
- [x] AI meal recognition
- [x] Step tracking
- [x] Weight logging
- [x] Smart nudges
- [x] Basic adaptive learning

### Phase 2 (Planned)
- [ ] Social features (optional friend challenges)
- [ ] Advanced meal planning
- [ ] Recipe suggestions
- [ ] Grocery list generation
- [ ] Integration with fitness trackers (Fitbit, Garmin)

### Phase 3 (Future)
- [ ] Personalized coaching AI
- [ ] Macro nutrient tracking
- [ ] Sleep tracking integration
- [ ] Mental health mood tracking
- [ ] Multi-language support

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

**Code Style:**
- Follow Dart style guide
- Run `flutter analyze` before committing
- Add tests for new features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **Your Name** - Initial work - [@yourusername](https://github.com/yourusername)

---

## 🙏 Acknowledgments

- LogMeal API for meal recognition
- Health Connect & HealthKit for health data
- Flutter community for amazing packages
- OpenAI for AI assistance in development

---

## 📞 Support

For issues, questions, or suggestions:
- 📧 Email: support@nutriwalk.ai
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/nutriwalk-flutter/issues)
- 💬 Discord: [Join our community](https://discord.gg/nutriwalk)

---

## 📊 Project Status

**Version:** 1.0.0  
**Status:** ✅ Production Ready  
**Last Updated:** February 2026

---

**Made with ❤️ using Flutter**
