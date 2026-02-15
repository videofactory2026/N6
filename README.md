# NutriWalk AI (MVP v1.0) — Full Features + Codemagic Fixed

This repo contains:
- `mobile/` React Native (Expo prebuild) app
- `backend/` Node + Express API

## Codemagic (important)
Codemagic has two workflows:

1) **android-debug-apk** (no keystore needed)
- Builds a debug APK so you can confirm everything compiles.

2) **android-release-aab** (signed, Play Store)
- Requires you to upload a keystore in Codemagic named `nutriwalk_keystore`.

## Environment variables
### Mobile
Create `mobile/.env`:
```
EXPO_PUBLIC_API_BASE_URL=http://10.0.2.2:4000
```

### Backend
Create `backend/.env`:
```
PORT=4000
LOGMEAL_API_KEY=YOUR_LOGMEAL_KEY
```

## Run locally
### Backend
```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

### Mobile
```bash
cd mobile
npm install
npx expo prebuild --clean
npx expo run:android
```

## MVP Features Included
- AI meal recognition (photo upload → backend → LogMeal → editable results)
- Daily weight tracking + 7-day moving average + plateau detection (14 days)
- Step tracking: Expo Pedometer fallback + Health Connect placeholder hook
- Calorie → Movement engine (BMR/TDEE, steps/km, minutes)
- Weekly intelligence (weekly deficit gate)
- Smart evening nudges (8–9 PM, suppression rules)
- Local encrypted storage (AES) + SecureStore
- Settings: AI toggle, profile, delete all data
