# TRENDIFY - iOS Build & IPA Generation Guide

## ⚠️ Important: iOS Requires Mac

**You CANNOT build iOS apps on Windows.** iOS builds require:
- Mac computer (MacBook, iMac, Mac Mini)
- macOS with Xcode installed
- Apple Developer Account (for App Store distribution)

---

## 📁 iOS Project Files Configured

The following iOS configuration files have been set up:

### 1. Bundle Identifier Updated
**File:** `ios/Runner.xcodeproj/project.pbxproj`
```
Bundle ID: com.trendify.fashion
```

### 2. App Name Updated
**File:** `ios/Runner/Info.plist`
```
Display Name: TRENDIFY
Bundle Name: TRENDIFY
```

### 3. Export Options Created
**Files:**
- `ios/ExportOptions.plist` (Ad-Hoc Distribution)
- `ios/ExportOptionsAppStore.plist` (App Store)

---

## 🍎 Build Instructions (Mac Required)

### Step 1: Transfer Project to Mac

Copy the entire project folder to your Mac:
```
From Windows: C:\Users\mmhus\Downloads\TRENIFY\
To Mac: ~/Documents/TRENIFY/
```

### Step 2: Install Dependencies

Open Terminal on Mac:
```bash
cd ~/Documents/TRENIFY
flutter pub get
cd ios
pod install --repo-update
```

### Step 3: Configure Firebase for iOS

1. Download `GoogleService-Info.plist` from Firebase Console:
   - https://console.firebase.google.com/project/trendify-fashion-store/settings/general
   - Click "iOS" → Download `GoogleService-Info.plist`

2. Replace the file:
   ```bash
   cp ~/Downloads/GoogleService-Info.plist ~/Documents/TRENIFY/ios/Runner/
   ```

### Step 4: Open in Xcode

```bash
open ios/Runner.xcworkspace
```

**DO NOT open Runner.xcodeproj - always use .xcworkspace**

---

## 🏗️ Build Methods

### Method 1: Build IPA via Command Line (Fastest)

```bash
# Build iOS release
cd ~/Documents/TRENIFY
flutter build ios --release

# Create IPA using xcodebuild
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -sdk iphoneos \
  -configuration Release \
  archive -archivePath build/Runner.xcarchive

# Export IPA
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build/Outputs \
  -exportOptionsPlist ExportOptions.plist
```

**IPA Location:** `ios/build/Outputs/Runner.ipa`

---

### Method 2: Build via Xcode GUI (Easiest)

1. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure Signing:**
   - Select "Runner" in left sidebar
   - Select "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your Apple Developer Team
   - Update Bundle Identifier to: `com.trendify.fashion`

3. **Archive the App:**
   - Select Product → Destination → Any iOS Device
   - Select Product → Archive
   - Wait for build to complete

4. **Export IPA:**
   - Organizer window opens automatically
   - Select your archive → Click "Distribute App"
   - Choose method:
     - **Ad Hoc:** For testing on specific devices
     - **App Store Connect:** For App Store submission
   - Follow prompts to export IPA

---

### Method 3: CI/CD Automated Build (GitHub Actions)

**File:** `.github/workflows/ios-build.yml`

```yaml
name: iOS Build

on:
  push:
    branches: [ main ]

jobs:
  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
      
      - name: Create IPA
        run: |
          cd ios
          mkdir -p Payload
          cp -r build/ios/iphoneos/Runner.app Payload/
          zip -r Runner.ipa Payload
      
      - name: Upload IPA
        uses: actions/upload-artifact@v3
        with:
          name: ios-app
          path: ios/Runner.ipa
```

---

## 📱 Install IPA on iPhone

### Method 1: Apple Configurator 2 (Mac)

1. Download Apple Configurator 2 from Mac App Store
2. Connect iPhone via USB
3. Drag IPA file into Configurator
4. App installs automatically

### Method 2: Diawi (Online)

1. Go to https://www.diawi.com
2. Upload your IPA file
3. Share the link with testers
4. Install on device (requires device registration)

### Method 3: Firebase App Distribution

```bash
# Install Firebase CLI on Mac
npm install -g firebase-tools

# Login
firebase login

# Distribute IPA
firebase appdistribution:distribute ios/build/Outputs/Runner.ipa \
  --app YOUR_APP_ID \
  --testers "tester1@email.com, tester2@email.com" \
  --release-notes "New build with all features"
```

---

## 🚀 App Store Publishing

### Prerequisites
- Apple Developer Account ($99/year)
- Mac with Xcode
- App Store Connect record

### Step-by-Step

1. **Create App Record:**
   - https://appstoreconnect.apple.com
   - My Apps → Click "+" → New App
   - Name: TRENDIFY
   - Bundle ID: com.trendify.fashion
   - SKU: trendify-001
   - Primary Language: English

2. **Prepare App Information:**
   - Screenshots (required sizes)
   - Description, keywords, support URL
   - Privacy policy URL
   - App icon (1024x1024)

3. **Build & Upload:**
   ```bash
   flutter build ipa --release
   ```
   Or use Xcode Organizer → Distribute App → App Store Connect

4. **Submit for Review:**
   - Go to App Store Connect
   - Select your app
   - Fill all required information
   - Click "Submit for Review"

---

## ⚙️ iOS Configuration Reference

### Info.plist Settings

**File:** `ios/Runner/Info.plist`

Key settings configured:
```xml
<key>CFBundleDisplayName</key>
<string>TRENDIFY</string>

<key>CFBundleName</key>
<string>TRENDIFY</string>

<key>CFBundleIdentifier</key>
<string>com.trendify.fashion</string>
```

### App Icons

**Location:** `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Required sizes:
- 20x20@2x, 20x20@3x
- 29x29@2x, 29x29@3x
- 40x40@2x, 40x40@3x
- 60x60@2x, 60x60@3x
- 1024x1024 (App Store)

### Launch Screen

**File:** `ios/Runner/Base.lproj/LaunchScreen.storyboard`

Customize the launch screen in Xcode Interface Builder.

---

## 🔐 Required Capabilities

The app may need these capabilities (enable in Xcode):

- **Push Notifications** (for order updates)
- **Network** (for internet access)
- **Keychain Sharing** (for secure storage)

Enable in Xcode:
```
Runner → Signing & Capabilities → + Capability
```

---

## 🐛 Troubleshooting

### "No signing certificate found"
→ Open Xcode → Runner → Signing & Capabilities → Check "Automatically manage signing"

### "Invalid bundle identifier"
→ Ensure Bundle ID is `com.trendify.fashion` in all places

### "Firebase not configured"
→ Download and add GoogleService-Info.plist to ios/Runner/

### "Flutter not found"
→ Run `flutter doctor` and fix any issues

### "CocoaPods error"
→ Run:
```bash
cd ios
sudo gem install cocoapods
pod repo update
pod install
```

---

## 📦 Build Output Locations

| Platform | Location |
|----------|----------|
| Android APK | `build/app/outputs/flutter-apk/app-release.apk` |
| iOS App | `build/ios/iphoneos/Runner.app` |
| iOS IPA (cmd) | `ios/build/Outputs/Runner.ipa` |
| iOS Archive | `ios/build/Runner.xcarchive` |
| Web | `build/web/` |

---

## ⚡ Quick Commands Reference

```bash
# Flutter commands
flutter build ios --release          # Build iOS release
flutter build ipa --release          # Build IPA directly
flutter clean                        # Clean build files
flutter doctor                       # Check setup

# Xcode commands
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release
pod install                          # Install iOS dependencies
pod update                           # Update iOS dependencies

# Archive & Export
xcodebuild archive -scheme Runner -archivePath build/Runner.xcarchive
xcodebuild -exportArchive -archivePath build/Runner.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build/Outputs
```

---

**Your iOS project is fully configured! Transfer to Mac and follow build steps above. 🍎**
