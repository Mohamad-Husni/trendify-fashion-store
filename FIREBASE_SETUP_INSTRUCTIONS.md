# Firebase Setup Instructions for TRENDIFY

## Option 1: Automatic Setup (Recommended)

1. **Double-click `setup_firebase.bat`** in your TRENIFY folder
2. A browser will open - **login with your Google account**
3. When prompted, **select your `trendify-fashion-store` project**
4. The `firebase_options.dart` file will be auto-generated

## Option 2: Manual Setup

### Step 1: Login to Firebase
Open **PowerShell or Command Prompt** and run:
```cmd
C:\Users\mmhus\AppData\Roaming\npm\firebase.cmd login
```
A browser will open - login with your Google account.

### Step 2: Run FlutterFire Configure
```cmd
cd C:\Users\mmhus\Downloads\TRENIFY
dart pub global run flutterfire_cli:flutterfire configure
```
When asked:
- Select your Firebase project: `trendify-fashion-store`
- Select platforms: Press Space to select all, then Enter

This will generate `lib/firebase_options.dart` with your real API keys.

## After Setup - Important Firebase Console Steps

1. **Go to** https://console.firebase.google.com/project/trendify-fashion-store

2. **Enable Authentication:**
   - Build → Authentication → Get Started
   - Enable "Email/Password" provider
   - Save

3. **Enable Firestore Database:**
   - Build → Firestore Database → Create Database
   - Start in test mode (for development)
   - Choose a location close to you

4. **Set Firestore Security Rules (Test Mode):**
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```

## Testing Login/Registration

Once setup is complete, run the app:
```cmd
flutter run -d chrome
```

Try these test flows:
1. **Register** a new account with email/password
2. **Login** with the same credentials
3. **Place an order** from the checkout screen
4. **View order history** in the Profile screen

## Troubleshooting

**If firebase command not found:**
```cmd
npm install -g firebase-tools
```

**If flutterfire not found:**
```cmd
dart pub global activate flutterfire_cli
```

**If "flutterfire configure" asks for project selection but shows 0 projects:**
Make sure you ran `firebase login` first and successfully logged in.

## Your Firebase Configuration

After running `flutterfire configure`, your `lib/firebase_options.dart` will be automatically updated with real values like:
```dart
apiKey: "your-actual-api-key",
appId: "your-actual-app-id",
projectId: "trendify-fashion-store",
```

You're all set! 🚀
