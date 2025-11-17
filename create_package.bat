@echo off
REM Script to convert current project to Flutter package
REM Usage: create_package.bat

set PACKAGE_NAME=phone_diagnostics_sdk
set PACKAGE_DIR=..\%PACKAGE_NAME%

echo 🚀 Creating Flutter Package: %PACKAGE_NAME%
echo ================================================
echo.

REM Step 1: Create package
echo 📦 Step 1: Creating package structure...
cd ..
call flutter create --template=package %PACKAGE_NAME%
cd %PACKAGE_NAME%

REM Step 2: Create directory structure
echo 📁 Step 2: Creating directory structure...
mkdir lib\src\controllers 2>nul
mkdir lib\src\models 2>nul
mkdir lib\src\views 2>nul
mkdir lib\src\services 2>nul
mkdir lib\src\utils 2>nul
mkdir lib\src\widgets 2>nul
mkdir lib\src\admin\controllers 2>nul
mkdir lib\src\admin\services 2>nul
mkdir lib\src\admin\views 2>nul
mkdir assets 2>nul

REM Step 3: Copy source files
echo 📋 Step 3: Copying source files...
xcopy /E /I /Y ..\kdtd_ver2_1\lib\diagnostics\controllers\* lib\src\controllers\
xcopy /E /I /Y ..\kdtd_ver2_1\lib\diagnostics\models\* lib\src\models\
xcopy /E /I /Y ..\kdtd_ver2_1\lib\diagnostics\views\* lib\src\views\
xcopy /E /I /Y ..\kdtd_ver2_1\lib\diagnostics\services\* lib\src\services\
xcopy /E /I /Y ..\kdtd_ver2_1\lib\diagnostics\utils\* lib\src\utils\
xcopy /E /I /Y ..\kdtd_ver2_1\lib\admin\* lib\src\admin\

REM Copy widgets separately
mkdir lib\src\widgets 2>nul
xcopy /E /I /Y ..\kdtd_ver2_1\lib\diagnostics\views\widgets\* lib\src\widgets\

REM Step 4: Copy assets
echo 🎨 Step 4: Copying assets...
copy ..\kdtd_ver2_1\assets\diag_rules.json assets\
copy ..\kdtd_ver2_1\assets\diag_thresholds.json assets\

REM Step 5: Create main export file
echo 📝 Step 5: Creating main export file...
(
echo library phone_diagnostics_sdk;
echo.
echo // Controllers
echo export 'src/controllers/auto_diagnostics_controller.dart';
echo.
echo // Models
echo export 'src/models/diag_step.dart';
echo export 'src/models/device_profile.dart';
echo export 'src/models/diag_environment.dart';
echo export 'src/models/rule_evaluator.dart';
echo export 'src/models/profile_manager.dart';
echo export 'src/models/screen_defect_type.dart';
echo.
echo // Views
echo export 'src/views/auto_diagnostics_view.dart';
echo export 'src/views/diagnostic_result_page.dart';
echo export 'src/views/failed_tests_warning_page.dart';
echo.
echo // Services
echo export 'src/services/phone_info_service.dart';
echo export 'src/services/price_estimation_service.dart';
echo.
echo // Admin
echo export 'src/admin/services/excel_import_service.dart';
echo export 'src/admin/views/admin_import_page.dart';
echo export 'src/admin/controllers/admin_data_controller.dart';
echo.
echo // Widgets
echo export 'src/widgets/device_info_section.dart';
echo export 'src/widgets/phone_3d_widget.dart';
echo export 'src/widgets/purchase_action_buttons.dart';
echo export 'src/widgets/animated_test_item.dart';
echo export 'src/widgets/auto_suite_section.dart';
echo.
echo // Utils
echo export 'src/utils/device_name_mapper.dart';
echo export 'src/utils/phone_image_mapper.dart';
) > lib\%PACKAGE_NAME%.dart

echo.
echo ✅ Package structure created successfully!
echo ================================================
echo 📦 Package location: %PACKAGE_DIR%
echo.
echo Next steps:
echo 1. cd %PACKAGE_DIR%
echo 2. flutter pub get
echo 3. Update import paths in source files
echo 4. Test the package
echo.
echo To use in another project, add to pubspec.yaml:
echo   phone_diagnostics_sdk:
echo     path: %PACKAGE_DIR%
echo.
pause
