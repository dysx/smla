import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../base/base_stateful_widget.dart';
import 'deal_logic.dart';
import 'deal_state.dart';

class DealPage extends BaseStatefulWidget {
  const DealPage({Key? key}) : super(key: key);

  @override
  State<DealPage> getState() => _DealPageState();
}

class _DealPageState extends BaseState<DealPage> {
  late DealLogic logic;
  late DealState state;

  @override
  void initState() {
    setIsHaveKeyboard(false);
    logic = Get.put(DealLogic());
    state = logic.state;
    super.initState();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: WebViewWidget(controller: state.webCtrl)
          ),
          // 返回按键
          // Positioned(
          //   // bar的高度
          //   top: MediaQuery.of(context).viewPadding.top,
          //   left: 0,
          //   child: const BackButton(
          //     color: Colors.black,
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<DealLogic>();
    super.dispose();
  }
}
