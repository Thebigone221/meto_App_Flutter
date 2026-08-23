@echo off
set SDK=%LOCALAPPDATA%\Android\Sdk
set ADB=%SDK%\platform-tools\adb.exe
set EMULATOR=%SDK%\emulator\emulator.exe

echo Demarrage de l'emulateur...
start "" "%EMULATOR%" -avd pixel_api36

echo Attente de l'emulateur...
:wait
"%ADB%" shell getprop sys.boot_completed 2>nul | findstr "1" >nul
if errorlevel 1 (
    timeout /t 3 /nobreak >nul
    goto wait
)
echo Emulateur pret!

echo Installation de l'app...
"%ADB%" install -r "%~dp0build\app\outputs\flutter-apk\app-debug.apk"

echo Lancement de l'app...
"%ADB%" shell am start -n com.example.meteo_app/.MainActivity

echo Termine!
