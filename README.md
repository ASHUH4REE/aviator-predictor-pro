# Aviator Predictor Pro

A premium dark-themed Flutter mobile application with futuristic gaming UI, Firebase backend, simulated prediction engine, wallet/VIP system, and an admin panel.

> This is a complete **starter source bundle**. It's runnable after you complete the Firebase setup steps below.

---

## Tech Stack

- **Flutter** (latest stable, Dart 3+)
- **Firebase**: Auth, Firestore, Storage, Cloud Messaging
- **State management**: Provider
- **Local storage**: SharedPreferences + Hive
- **Charts**: fl_chart
- **Animations**: flutter_animate, Lottie
- **Auth**: Email/password, Phone OTP, Google Sign-In, Forgot password

---

## Folder Architecture

```
lib/
├── core/             # theme, constants, router, app config
├── models/           # data models (User, Prediction, Transaction)
├── services/         # firebase wrappers + prediction engine
├── providers/        # Provider state classes
├── screens/          # all UI screens grouped by feature
│   ├── auth/
│   ├── home/
│   ├── predictor/
│   ├── history/
│   ├── wallet/
│   ├── profile/
│   └── admin/
├── widgets/          # reusable UI components
├── utils/            # validators, formatters
└── main.dart
```

---

## 1. Prerequisites

- Flutter SDK ≥ 3.22 (`flutter --version`)
- Android Studio / Xcode
- A Firebase project (https://console.firebase.google.com)
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

---

## 2. Firebase Setup

1. Create a Firebase project in the console.
2. Enable the following in the Firebase console:
   - **Authentication** → Email/Password, Phone, Google
   - **Firestore Database** (start in production mode, then apply rules below)
   - **Storage**
   - **Cloud Messaging**
3. From the project root run:

   ```bash
   flutterfire configure
   ```

   This generates `lib/firebase_options.dart` and registers your iOS/Android apps.

4. **Android extra steps**
   - Place `google-services.json` in `android/app/`.
   - Set `minSdkVersion 23` in `android/app/build.gradle`.
   - Add the Google services plugin in `android/build.gradle` and `android/app/build.gradle` (FlutterFire CLI does this).
   - For Phone Auth, add SHA-1 / SHA-256 fingerprints in Firebase project settings.

5. **iOS extra steps**
   - Place `GoogleService-Info.plist` in `ios/Runner/`.
   - In `ios/Runner/Info.plist` add the reversed client ID for Google Sign-In.
   - Set iOS deployment target to 13.0 in `ios/Podfile`.

6. **Firestore security rules** (paste into Firestore → Rules):

   ```js
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       function isAdmin() {
         return request.auth != null &&
                get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
       }

       match /users/{uid} {
         allow read: if request.auth != null && (request.auth.uid == uid || isAdmin());
         allow create: if request.auth != null && request.auth.uid == uid;
         allow update: if request.auth != null && (request.auth.uid == uid || isAdmin());
         allow delete: if isAdmin();
       }

       match /predictions/{id} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update, delete: if isAdmin();
       }

       match /transactions/{id} {
         allow read: if request.auth != null && (resource.data.uid == request.auth.uid || isAdmin());
         allow create: if request.auth != null;
         allow update, delete: if isAdmin();
       }

       match /settings/{doc} {
         allow read: if request.auth != null;
         allow write: if isAdmin();
       }

       match /notifications/{id} {
         allow read: if request.auth != null;
         allow write: if isAdmin();
       }
     }
   }
   ```

7. **Storage rules** (Storage → Rules):

   ```js
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /avatars/{uid}/{file} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == uid;
       }
     }
   }
   ```

8. **Promote your first admin** — create a user account in the app, then in Firestore set `users/{uid}.isAdmin = true`.

---

## 3. Run the app

```bash
flutter pub get
flutter run
```

---

## 4. Build commands

**Android APK (release):**

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (Play Store):**

```bash
flutter build appbundle --release
```

**iOS:**

```bash
flutter build ios --release
```

---

## 5. Notes & Disclaimers

- The "predictor engine" is a **simulated** randomness/statistics engine for entertainment and educational purposes. It does not predict real outcomes of any third-party game. Do not use it for gambling decisions.
- VIP/wallet flows are local + Firestore-only; integrate a real payment SDK (Stripe, Razorpay, etc.) before production billing.
- Replace the placeholder Telegram URL in `lib/core/constants.dart`.
- Add your own logo image to `assets/images/logo.png`.
