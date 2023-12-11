import 'package:SmartLoan/pages/deal/deal_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:SmartLoan/pages/home/home_view.dart';
import 'package:SmartLoan/pages/login/login_view.dart';
import 'package:SmartLoan/pages/sms/sms_view.dart';
import 'package:SmartLoan/pages/splash/splash_view.dart';
import 'package:SmartLoan/routers/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 708),
      child: GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: SplashPage(),
        getPages: [
          GetPage(
            name: AppRoutes.splash,
            page: () => const SplashPage(),
          ),
          GetPage(name: AppRoutes.login, page: () => const LoginPage()),
          GetPage(name: AppRoutes.sms, page: () => const SmsPage(), transition: Transition.rightToLeft),
          GetPage(name: AppRoutes.deal, page: () => const DealPage()),
          GetPage(name: AppRoutes.home, page: () => const HomePage()),
        ],
      ),
    );
  }
}
