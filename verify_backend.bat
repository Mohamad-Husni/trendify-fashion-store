@echo off
echo ============================================
echo TRENDIFY Firebase Backend Verification
echo ============================================
echo.

REM Check if build exists
if not exist "build\web\index.html" (
    echo [WARNING] Build files not found!
    echo Running flutter build web --release...
    call flutter build web --release
    if errorlevel 1 (
        echo [ERROR] Build failed!
        pause
        exit /b 1
    )
)

echo [1/4] Checking Firebase CLI login status...
C:\Users\mmhus\AppData\Roaming\npm\firebase.cmd login:list 2>nul >nul
if errorlevel 1 (
    echo [WARNING] Not logged in to Firebase
    echo Please run: C:\Users\mmhus\AppData\Roaming\npm\firebase.cmd login
    pause
    exit /b 1
)
echo [OK] Firebase CLI authenticated

echo.
echo [2/4] Checking firebase.json configuration...
if not exist "firebase.json" (
    echo [ERROR] firebase.json not found!
    pause
    exit /b 1
)
echo [OK] firebase.json found

echo.
echo [3/4] Firebase Project Check...
echo Project: trendify-fashion-store
echo.
echo IMPORTANT: You must manually verify in Firebase Console:
echo 1. Authentication is ENABLED (Email/Password)
echo 2. Firestore Database is CREATED
echo 3. Security Rules are PUBLISHED
echo.
echo URLs to check:
echo - Auth: https://console.firebase.google.com/project/trendify-fashion-store/authentication
echo - DB: https://console.firebase.google.com/project/trendify-fashion-store/firestore

echo.
echo [4/4] Ready to deploy!
echo.
set /p deploy="Deploy to Firebase now? (Y/N): "
if /i "%deploy%"=="Y" (
    echo.
    echo Deploying to Firebase Hosting...
    C:\Users\mmhus\AppData\Roaming\npm\firebase.cmd deploy --only hosting
    if errorlevel 1 (
        echo.
        echo [ERROR] Deployment failed!
        echo Check internet connection and Firebase status
        pause
        exit /b 1
    )
    echo.
    echo [SUCCESS] Deployment complete!
    echo Your app is live at: https://trendify-fashion-store.web.app
)

echo.
echo ============================================
echo Verification Complete!
echo ============================================
echo.
echo Next Steps:
echo 1. Visit https://trendify-fashion-store.web.app
echo 2. Test registration and login
echo 3. Check Firebase Console for data
echo.
pause
