import 'package:get/get.dart';
import '../../diagnostics/views/auto_diagnostics_view.dart';

import '../../views/onboarding_view.dart';
import '../../diagnostics/bindings/auto_diagnostics_binding.dart';

import 'app_routes.dart';

/// App Pages - Route configuration with proper structure
class AppPages {
  AppPages._();

  /// Initial route
  static const String initial = AppRoutes.diagnosticsHome;

  /// All application routes
  static final List<GetPage> routes = [
    // Onboarding
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      transition: Transition.fadeIn,
    ),

    // Diagnostics - Home Dashboard (using new view)
    GetPage(
      name: AppRoutes.diagnosticsHome,
      page: () => const AutoDiagnosticsView(),
      binding: AutoDiagnosticsBinding(),
      transition: Transition.fadeIn,
    ),

    // Diagnostics - Auto (Redesigned)
    // GetPage(
    //   name: AppRoutes.diagnosticsAuto,
    //   page: () => const AutoDiagnosticsView(),
    //   binding: AutoDiagnosticsBinding(),
    //   transition: Transition.fadeIn,
    // ),

    // Diagnostics - Auto New (Modern UI)
    // GetPage(
    //   name: AppRoutes.diagnosticsAutoOld,
    //   page: () => const AutoDiagnosticsNewView(),
    //   binding: AutoDiagnosticsBinding(),
    //   transition: Transition.fadeIn,
    // ),

    // Add more routes here
  ];
}

