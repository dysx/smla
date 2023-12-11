import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/base_stateful_widget.dart';
import 'splash_logic.dart';
import 'splash_state.dart';

class SplashPage extends BaseStatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> getState() => _SplashPageState();
}

class _SplashPageState extends BaseState<SplashPage> {
  late SplashLogic logic;
  late SplashState state;

  @override
  void initState() {
    setIsHaveKeyboard(false);
    logic = Get.put(SplashLogic());
    state = logic.state;
    super.initState();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SplashLogic>();
    super.dispose();
  }
}
