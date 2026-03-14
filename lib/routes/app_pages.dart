import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:payroll/features/ctc_page/views/ctc_page.dart';
import 'package:payroll/features/document_page/views/controller/document_page_binding.dart';
import 'package:payroll/features/forgot_password_page/views/controller/forgot_password_page_binding.dart';
import 'package:payroll/features/leave_page/controller/leave_page_binding.dart';
import 'package:payroll/features/leave_page/views/leave_page.dart';
import 'package:payroll/features/login/controller/login_page_binding.dart';
import 'package:payroll/features/login/views/login_page.dart';
import 'package:payroll/features/mainpage/controller/main_page_binding.dart';
import 'package:payroll/features/mainpage/views/main_page.dart';
import 'package:payroll/features/manager/controller/manager_page_binding.dart';
import 'package:payroll/features/manager/views/manager_page.dart';
import 'package:payroll/features/payslip_page/controller/payslip_page_binding.dart';
import 'package:payroll/features/payslip_page/views/payslip_page.dart';
import 'package:payroll/features/profile_page/views/controller/profile_page_binding.dart';
import 'package:payroll/features/profile_page/views/profile_page.dart';
import 'package:payroll/features/splash/controller/splash_page_binding.dart';
import 'package:payroll/features/splash/views/splash_page.dart';

import '../features/ctc_page/controller/ctc_page_binding.dart';
import '../features/document_page/views/document_page.dart';
import '../features/forgot_password_page/views/forgot_password_page.dart';
import '../features/homepage/controller/home_page_binding.dart';
import '../features/homepage/views/home_page.dart';
import '../features/tax_page/controller/tax_page_binding.dart';
import '../features/tax_page/views/tax_page.dart';
import '../features/time/controller/individual_employee_time_controller.dart';
import '../features/time/controller/manager_time_controller.dart';
import '../features/time/controller/route_history_controller.dart';
import '../features/time/controller/shift_filter_controller.dart';
import '../features/time/controller/time_page_binding.dart';
import '../features/time/views/individual_employee_time_page.dart';
import '../features/time/views/manager_route_view_page.dart';
import '../features/time/views/manager_time_page.dart';
import '../features/time/views/overtime_page.dart';
import '../features/time/views/regularize_page.dart';
import '../features/time/views/route_history_page.dart';
import '../features/time/views/shift_filter_page.dart';
import '../features/time/views/time_page.dart';
import 'app_route.dart';

export '../../../../service/api_service.dart';
export '../../../config/appstates.dart';
export '../../../service/app_expection.dart';
export '../config/constants.dart';
export '../features/homepage/views/home_page.dart';
export '../service/network_service.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splashPage,
      page: () => const SplashPage(),
      binding: SplashPageBinding(),
    ),
    GetPage(
      name: AppRoutes.loginPage,
      page: () =>  LoginPage(),
      binding: LoginPageBinding(),
    ),
    GetPage(
      name: AppRoutes.ctcPage,
      page: () =>  CTCPage(),
      binding: CTCPageBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPasswordPage,
      page: () =>  ForgotPasswordPage(),
      binding: ForgotPasswordPageBinding(),
    ),
    GetPage(
      name: AppRoutes.mainPage,
      page: () => const MainPage(),
      binding: MainPageBinding(),
    ),
    GetPage(
      name: AppRoutes.homePage,
      page: () =>  HomePage(),
      binding: HomePageBinding(),
    ),
    GetPage(
      name: AppRoutes.paySlipPage,
      page: () =>  PayslipPage(),
      binding: PayslipPageBinding(),
    ),
    GetPage(
      name: AppRoutes.taxPage,
      page: () => const TaxPage(),
      binding: TaxPageBinding(),
    ),
    GetPage(
      name: AppRoutes.leavePage,
      page: () =>  LeavePage(
        fromHome: false,
      ),
      binding: LeavePageBinding(),
    ),
    GetPage(
      name: AppRoutes.timePage,
      page: () =>  TimePage(),
      binding: TimePageBinding(),
    ),
    GetPage(
      name: AppRoutes.profilePage,
      page: () => const ProfilePage(),
      binding: ProfilePageBinding(),
    ),
    GetPage(
      name: AppRoutes.documentPage,
      page: () =>  DocumentPage(),
      binding: DocumentPageBinding(),
    ),
    GetPage(
      name: AppRoutes.managerPage,
      page: () =>  ManagerPage(),
      binding: ManagerPageBinding(),
    ),
    GetPage(
      name: AppRoutes.regularizePage,
      page: () => RegularizePage(),
    ),
    GetPage(
      name: AppRoutes.overtimePage,
      page: () => OvertimePage(),
    ),
    GetPage(
      name: AppRoutes.routeHistoryPage,
      page: () => RouteHistoryPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RouteHistoryController>(() => RouteHistoryController());
      }),
    ),
    GetPage(
      name: AppRoutes.managerTimePage,
      page: () => ManagerTimePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ManagerTimeController>(() => ManagerTimeController());
      }),
    ),
    GetPage(
      name: AppRoutes.managerRouteViewPage,
      page: () => const ManagerRouteViewPage(),
    ),
    GetPage(
      name: AppRoutes.individualEmployeeTimePage,
      page: () => IndividualEmployeeTimePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => IndividualEmployeeTimeController());
      }),
    ),
    GetPage(
      name: AppRoutes.shiftWiseFilterPage,
      page: () => ShiftFilterPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ShiftFilterController());
      }),
    ),

  ];
}
