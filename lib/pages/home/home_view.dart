import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:SmartLoan/base/base_stateful_widget.dart';
import 'package:SmartLoan/pages/home/home_logic.dart';
import 'package:SmartLoan/pages/home/home_state.dart';
import 'package:SmartLoan/pages/home/widgets/page_with_refresh.dart';
import 'package:SmartLoan/util/extension.dart';
import 'package:SmartLoan/widget/custom_input.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widget/auth_common.dart';

class HomePage extends BaseStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> getState() => _HomePageState();
}

class _HomePageState extends BaseState<HomePage> {
  late HomeLogic logic;
  late HomeState state;

  @override
  void initState() {
    setIsHaveKeyboard(false);
    logic = Get.put(HomeLogic());
    state = logic.state;
    super.initState();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: Container(
          // color: Colors.amber,
          child: PageWithRefresh(
            onRefresh: () {
              state.webCtrl.loadRequest(Uri.parse('http://testmexico-smartloan-3003.gccloud.xyz'));
            },
            child: WebViewWidget(
              controller: state.webCtrl,
            ),
          ),
        ),
        onWillPop: () => logic.webViewOnBack(),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<HomeLogic>();
    super.dispose();
  }
}
