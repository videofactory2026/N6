# NutriWalk AI - Complete Setup Guide

## 🎯 Step-by-Step Setup for Production Deployment

### Phase 1: Local Development Setup

1. **Install Flutter**
   ```bash
   # Download Flutter SDK from https://flutter.dev
   # Add to PATH
   flutter doctor -v
   ```

2. **Clone & Setup Project**
   ```bash
   git init
   git remote add origin <your-github-repo>
   git add .
   git commit -m "Initial commit: NutriWalk AI v1.0"
   git push -u origin main
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Configure LogMeal API**
   - Sign up at https://logmeal.com
   - Get API token
   - Create `lib/config/api_config.dart`:
   ```dart
   class ApiConfig {
     static const String logMealApiToken = 'YOUR_TOKEN_HERE';
     static const String logMealApiUrl = 'https://api.logmeal.es/v2';
   }
   ```
   - Update `lib/services/food_recognition_service.dart` line 11

5. **Test Local Build**
   ```bash
   flutter run
   ```

### Phase 2: Android Production Setup

1. **Generate Signing Key**
   ```bash
   cd android/app
   keytool -genkey -v -keystore ../../nutriwalk-release-key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias nutriwalk
   ```

2. **Create key.properties**
   ```bash
   cd android
   cat > key.properties << EOF
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=nutriwalk
   storeFile=../nutriwalk-release-key.jks
   EOF
   ```

3. **Test Release Build**
   ```bash
   flutter build appbundle --release
   ```

### Phase 3: Codemagic CI/CD Setup

1. **Connect GitHub to Codemagic**
   - Go to https://codemagic.io
   - Connect your GitHub account
   - Select nutriwalk_ai repository

2. **Configure Environment Variables**
   
   In Codemagic → Settings → Environment variables:
   ```
   KEYSTORE_PASSWORD: <your-keystore-password>
   KEY_PASSWORD: <your-key-password>
   KEY_ALIAS: nutriwalk
   RECIPIENT_EMAIL: <your-email>
   ```

3. **Upload Keystore**
   - In Codemagic → Code signing
   - Upload `nutriwalk-release-key.jks`
   - Set variable name: `KEYSTORE_PATH`

4. **Configure Google Play**
   - Create app in Google Play Console
   - Generate service account JSON
   - Upload to Codemagic as `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`

5. **Trigger Build**
   - Push code to main branch
   - Codemagic will automatically build
   - AAB will be uploaded to Play Store Internal Testing

### Phase 4: Play Store Deployment

1. **First Release Setup**
   - Complete Play Store listing
   - Add screenshots (generate using app)
   - Set content rating
   - Add privacy policy

2. **Internal Testing**
   - Codemagic uploads to Internal track
   - Add test users
   - Distribute and test

3. **Production Release**
   - After testing, promote to Production
   - Or update codemagic.yaml to deploy to production directly

### Phase 5: iOS Setup (Optional)

1. **Apple Developer Account**
   - Enroll in Apple Developer Program ($99/year)

2. **Configure iOS Signing**
   - In Codemagic → iOS code signing
   - Connect Apple Developer account
   - Select certificate and provisioning profile

3. **Update codemagic.yaml**
   - Uncomment iOS workflow section
   - Configure bundle identifier: com.nutriwalk.ai

4. **Deploy to TestFlight**
   - Build will upload automatically
   - Add testers in App Store Connect

## 🔐 Security Checklist

- [ ] Never commit `.jks` files to git
- [ ] Never commit `key.properties` to git
- [ ] Never commit API keys to git
- [ ] Add all sensitive files to `.gitignore`
- [ ] Use Codemagic environment variables for secrets
- [ ] Enable 2FA on all accounts

## 📊 Post-Deployment Monitoring

1. **Firebase Analytics** (Optional)
   - Add Firebase to project
   - Monitor user engagement
   - Track feature usage

2. **Crash Reporting**
   - Firebase Crashlytics
   - Monitor app stability

3. **Performance Monitoring**
   - Track app launch time
   - Monitor API response times
   - Check battery usage

## 🐛 Common Issues & Solutions

**Issue**: Health Connect not working
- Solution: Ensure device has Health Connect app installed (Android 14+)

**Issue**: Food recognition timeout
- Solution: Check LogMeal API quota and internet connection

**Issue**: Build fails with signing error
- Solution: Verify key.properties paths and passwords

**Issue**: Codemagic build fails
- Solution: Check environment variables are set correctly

## 📞 Support

For any setup issues:
1. Check logs in Codemagic dashboard
2. Run `flutter doctor -v` for environment issues
3. Verify all API keys are configured
4. Check GitHub repository permissions

## ✅ Deployment Checklist

Before production release:
- [ ] All API keys configured
- [ ] Keystore generated and uploaded
- [ ] Codemagic environment variables set
- [ ] Internal testing completed
- [ ] Privacy policy created
- [ ] Play Store listing complete
- [ ] Screenshots added
- [ ] Version bumped in pubspec.yaml
- [ ] Release notes prepared
- [ ] Support email configured

---

**Ready to Deploy!** 🚀

Follow these steps in order and you'll have NutriWalk AI live on the Play Store in under 2 hours.
