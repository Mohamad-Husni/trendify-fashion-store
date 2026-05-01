@echo off
echo ==========================================
echo TRENDIFY Firebase Setup
echo ==========================================
echo.
echo Step 1: Logging into Firebase...
echo (A browser window will open - please login with your Google account)
echo.
C:\Users\mmhus\AppData\Roaming\npm\firebase.cmd login
echo.
echo Step 2: Configuring FlutterFire...
echo (Select your trendify-fashion-store project when prompted)
echo.
flutterfire configure
echo.
echo ==========================================
echo Setup Complete!
echo ==========================================
pause
