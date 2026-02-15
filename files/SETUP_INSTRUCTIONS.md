# NutriWalk AI - Complete Setup Instructions

## 🎯 Current Project Status

### What's Included Now (40% Complete):
✅ **Core Configuration Files**
- Complete project structure
- codemagic.yaml (CI/CD configuration)
- pubspec.yaml (all dependencies)
- .gitignore
- Comprehensive README.md

✅ **Data Models (100% Complete)**
- user_profile.dart (with BMR/TDEE calculations)
- meal_log.dart (meal entries & food items)
- activity_log.dart (steps, distance, calories)
- behavior_profile.dart (adaptive learning)

✅ **Core Files**
- main.dart (app entry point with service initialization)
- app_state_provider.dart (state management)
- constants.dart (all app constants)
- helpers.dart (utility functions)

✅ **Platform Configuration**
- AndroidManifest.xml (Health Connect permissions)
- Info.plist (HealthKit permissions)
- GitHub Actions CI workflow

### What Still Needs To Be Created (60%):
⚠️ **8 Screen Files** - UI implementation
⚠️ **4 Widget Files** - Reusable components
⚠️ **5 Service Files** - Database, Health, API integration
⚠️ **4 Engine Files** - AI/intelligence modules
⚠️ **Build Files** - Gradle, Podfile configurations

---

## 📋 Three Options to Complete the Project

### Option 1: I Generate All Remaining Files (RECOMMENDED)
**Advantages:**
- Get a complete, working app immediately
- All files follow Flutter best practices
- Properly integrated and tested
- Ready for Codemagic deployment

**How to proceed:**
Just say: **"Please create all remaining files"**

I will generate:
- All 8 screens with complete UI
- All 4 widgets with proper styling
- All 5 services (database, encryption, health, API, notifications)
- All 4 AI engines (nudges, adaptive learning, insights)
- Build configuration files
- Test files

---

### Option 2: I Provide Templates, You Customize
**Advantages:**
- Learn the codebase structure
- Customize to your exact needs
- Full control over implementation

**How to proceed:**
1. I provide detailed code templates
2. You customize colors, text, logic
3. You add your own features

---

### Option 3: Hybrid Approach
**Advantages:**
- Get core functionality immediately
- Customize specific parts you care about

**How to proceed:**
Tell me which parts you want:
- "Generate all screens but let me handle services"
- "Create services and engines, I'll do the UI"
- "Everything except [specific part]"

---

## 🚀 Quick Start (After Files Are Complete)

### Step 1: Setup Environment
```bash
# Install Flutter (if not already installed)
# Visit: https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor

# Navigate to project
cd nutriwalk_flutter_complete

# Get dependencies
flutter pub get
```

### Step 2: Configure API Keys

Create a `.env` file in the project root:
```env
LOGMEAL_API_KEY=your_logmeal_api_key_here
API_BASE_URL=http://localhost:8787
```

Get LogMeal API key from: https://logmeal.com/

### Step 3: Run the App

**For Android:**
```bash
# Start Android emulator first
flutter run --debug

# Or specify device
flutter run -d <device-id>
```

**For iOS:**
```bash
# Start iOS simulator first
open -a Simulator

flutter run --debug
```

### Step 4: Test Features

1. **Onboarding**: Create user profile
2. **Meal Logging**: Test camera & manual entry
3. **Step Tracking**: Grant health permissions
4. **Progress**: View charts & insights
5. **Nudges**: Wait for evening (8-9 PM) or trigger manually

---

## 📦 Deployment to Production

### Using Codemagic (Automated)

1. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: NutriWalk AI Flutter"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **Connect to Codemagic**
   - Sign in at https://codemagic.io
   - Click "Add application"
   - Select your GitHub repository
   - Codemagic will detect codemagic.yaml automatically

3. **Configure Environment Variables**
   
   In Codemagic UI, create environment group `nutriwalk_production`:
   
   **Android Signing:**
   - `KEYSTORE_PASSWORD` - Your keystore password
   - `KEY_PASSWORD` - Your key password
   - `KEY_ALIAS` - Your key alias
   - Upload keystore file as `nutriwalk_keystore`
   - `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` - Google Play JSON key

   **iOS Signing:**
   - Connect App Store Connect API
   - Add distribution certificates
   - Add provisioning profiles

   **General:**
   - `RECIPIENT_EMAIL` - Your email for build notifications

4. **Trigger Build**
   - Push to `main` branch triggers production build
   - Or manually trigger from Codemagic dashboard

5. **Workflows Available**
   - `android-workflow` - Builds AAB, uploads to Google Play Internal
   - `ios-workflow` - Builds IPA, uploads to TestFlight
   - `android-debug-workflow` - Debug builds for testing
   - `code-quality-workflow` - Runs on pull requests

---

### Manual Build (Local)

**Android:**
```bash
# Generate signing key (first time only)
keytool -genkey -v -keystore ~/nutriwalk-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias nutriwalk

# Create android/key.properties
storePassword=<your-password>
keyPassword=<your-key-password>
keyAlias=nutriwalk
storeFile=<path-to-jks>

# Build
flutter build appbundle --release
```

**iOS:**
```bash
# Requires macOS with Xcode

# Build
flutter build ipa --release

# Or use Xcode
open ios/Runner.xcworkspace
# Build → Archive → Distribute
```

---

## 🔧 Troubleshooting

### Common Issues:

**1. Health permissions not working**
- Android: Ensure Health Connect app is installed (Android 14+)
- iOS: Check Info.plist has all HealthKit keys
- Both: Request permissions after user profile is created

**2. Camera not working**
- Check AndroidManifest.xml has CAMERA permission
- Check Info.plist has NSCameraUsageDescription
- Grant permission when prompted

**3. Build fails on Codemagic**
- Verify all environment variables are set
- Check keystore file is uploaded
- Ensure bundle identifier matches certificates

**4. App crashes on startup**
- Check all services are initialized in main.dart
- Verify database migrations are correct
- Check logs: `flutter logs`

**5. Notifications not appearing**
- Request notification permissions
- Check notification channels are created (Android)
- Verify timezone data is initialized

---

## 📞 Next Steps

**Ready to complete the project?**

Choose one:
1. **"Generate all remaining files"** - I create everything now
2. **"Show me screen templates first"** - I provide UI code
3. **"Start with services"** - I create backend services first
4. **"Custom approach"** - Tell me what you want

I'll generate professional, production-ready code following Flutter best practices!
