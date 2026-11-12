@echo off
title Rescue One - Launcher
cd /d "%~dp0"
echo ========================================================
echo   Rescue One  (Graduation Project)
echo   City University Malaysia - Faculty of IT
echo ========================================================
echo.
echo Choose launch mode:
echo [1] Open the web app in the browser (pre-built, instant)
echo [2] Run live development mode in Chrome  (flutter run -d chrome)
echo [3] Run on a connected Android phone / emulator  (flutter run)
echo [4] Run the automated tests  (flutter test)
echo [5] Rebuild the web app after code changes  (flutter build web)
echo [6] Build an installable Android APK  (flutter build apk)
echo.
set /p choice="Enter choice (1-6) [default 1]: "
if "%choice%"=="" set choice=1

if "%choice%"=="1" (
    python serve_web.py
)
if "%choice%"=="2" (
    cd smart_emergency_360
    flutter run -d chrome
)
if "%choice%"=="3" (
    cd smart_emergency_360
    flutter run
)
if "%choice%"=="4" (
    cd smart_emergency_360
    flutter test
)
if "%choice%"=="5" (
    cd smart_emergency_360
    rem Builds straight into the site's app\ folder (relative base href, see web\index.html).
    flutter build web --release -o "%~dp0app"
)
if "%choice%"=="6" (
    cd smart_emergency_360
    flutter build apk --release
    echo.
    echo APK: smart_emergency_360\build\app\outputs\flutter-apk\app-release.apk
)
pause
