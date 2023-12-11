import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:SmartLoan/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 仅允许竖屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    runApp(const App());
  });
}