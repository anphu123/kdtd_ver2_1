@echo off
echo ========================================
echo Phone Diagnostics SDK - Complete Setup
echo ========================================
echo.

REM Step 1: Create directories
echo [1/6] Creating package directories...
mkdir ..\phone_diagnostics_sdk\lib\src\controllers 2>nul
mkdir ..\phone_diagnostics_sdk\lib\src\models 2>nul
mkdir ..\phone_diagnostics_sdk\lib\src\views 2>nul
mkdir ..\phone_diagnostics_sdk\lib\src\services 2>nul
mkdir ..\phone_diagnostics_sdk\lib\src\utils 2>nul
mkdir ..\phone_diagnostics_sdk\lib\src\widgets 2>nul
mkdir ..\phone_diagnostics_sdk\assets 2>nul

REM Step 2: Copy source files
echo [2/6] Copying source files...
xcopy /E /I /Y /Q lib\diagnostics\controllers\* ..\phone_diagnostics_sdk\lib\src\controllers\
xcopy /E /I /Y /Q lib\diagnostics\models\* ..\phone_diagnostics_sdk\lib\src\models\
xcopy /E /I /Y /Q lib\diagnostics\views\*.dart ..\phone_diagnostics_sdk\lib\src\views\
xcopy /E /I /Y /Q lib\diagnostics\services\* ..\phone_diagnostics_sdk\lib\src\services\
xcopy /E /I /Y /Q lib\diagnostics\utils\* ..\phone_diagnostics_sdk\lib\src\utils\
xcopy /E /I /Y /Q lib\diagnostics\views\widgets\* ..\phone_diagnostics_sdk\lib\src\widgets\

REM Step 3: Copy assets
echo [3/6] Copying assets...
copy /Y assets\diag_rules.json ..\phone_diagnostics_sdk\assets\ >nul
copy /Y assets\diag_thresholds.json ..\phone_diagnostics_sdk\assets\ >nul

REM Step 4: Create export file
echo [4/6] Creating export file...
(
echo library phone_diagnostics_sdk;
echo.
echo export 'src/controllers/auto_diagnostics_controller.dart';
echo export 'src/models/diag_step.dart';
echo export 'src/models/device_profile.dart';
echo export 'src/models/diag_environment.dart';
echo export 'src/models/rule_evaluator.dart';
echo export 'src/models/profile_manager.dart';
echo export 'src/views/auto_diagnostics_view.dart';
echo export 'src/views/diagnostic_result_page.dart';
echo export 'src/views/failed_tests_warning_page.dart';
echo export 'src/services/phone_info_service.dart';
echo export 'src/widgets/widgets.dart';
) > ..\phone_diagnostics_sdk\lib\phone_diagnostics_sdk.dart

REM Step 5: Get dependencies
echo [5/6] Getting dependencies...
cd ..\phone_diagnostics_sdk
call flutter pub get >nul 2>&1

cd ..\diagnostics_demo
call flutter pub get >nul 2>&1

cd ..\kdtd_ver2_1

REM Step 6: Done
echo [6/6] Setup complete!
echo.
echo ========================================
echo SUCCESS!
echo ========================================
echo.
echo Package: D:\phone_diagnostics_sdk
echo Demo App: D:\diagnostics_demo
echo.
echo To run demo app:
echo   cd ..\diagnostics_demo
echo   flutter run
echo.
echo To open in VS Code:
echo   code ..\diagnostics_demo
echo.
pause
