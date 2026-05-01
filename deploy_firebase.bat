@echo off
echo ==========================================
echo TRENDIFY Firebase Hosting Deployment
echo ==========================================
echo.

REM Step 1: Build the Flutter web app
echo [1/3] Building Flutter web app for production...
call flutter build web --release
if errorlevel 1 (
    echo [ERROR] Flutter build failed!
    pause
    exit /b 1
)
echo [✓] Build completed successfully!
echo.

REM Step 2: Check firebase.json exists
if not exist "firebase.json" (
    echo [ERROR] firebase.json not found!
    pause
    exit /b 1
)
echo [✓] firebase.json found
echo.

REM Step 3: Deploy to Firebase Hosting
echo [3/3] Deploying to Firebase Hosting...
echo (This may take a few minutes...)
echo.
C:\Users\mmhus\AppData\Roaming\npm\firebase.cmd deploy --only hosting
if errorlevel 1 (
    echo.
    echo [ERROR] Deployment failed!
    echo.
    echo Common issues:
    echo - Make sure you're logged in: C:\Users\mmhus\AppData\Roaming\npm\firebase.cmd login
    echo - Check your internet connection
    echo - Verify your firebase.json is valid
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Deployment Complete! 
echo ==========================================
echo.
echo Your app is now live at:
echo https://trendify-fashion-store.web.app
echo OR
echo https://trendify-fashion-store.firebaseapp.com
echo.
pause
