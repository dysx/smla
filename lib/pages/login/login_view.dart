import 'package:SmartLoan/widget/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:SmartLoan/base/base_stateful_widget.dart';
import 'package:SmartLoan/routers/app_routes.dart';
import 'package:SmartLoan/util/extension.dart';
import 'package:SmartLoan/widget/custom_input.dart';
import 'package:SmartLoan/widget/text_input_formatter.dart';

import '../../widget/auth_common.dart';
import 'login_logic.dart';
import 'login_state.dart';

class LoginPage extends BaseStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> getState() => _LoginPageState();
}

class _LoginPageState extends BaseState<LoginPage> {
  late LoginLogic logic;
  late LoginState state;

  @override
  void initState() {
    setIsHaveKeyboard(false);
    logic = Get.put(LoginLogic());
    state = logic.state;
    super.initState();
  }

  @override
  Widget buildContent(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (LoadingView.singleton.isVisible) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AuthBg(
          isAgree: state.isAgree,
          onAgree: (value) {
            state.isAgree = value;
          },
          onPress: logic.apply,
          child: Row(
            children: [
              '+52'.text(),
              SizedBox(width: 10.w),
              Expanded(
                child: CustomInput(
                  controller: state.phoneCtrl,
                  focusNode: state.phoneFN,
                  hintText: 'Please Enter',
                  keyboardType: TextInputType.number,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    // 限制10位
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              )
            ],
          ).decorationBox(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              margin: EdgeInsets.symmetric(vertical: 10.h)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<LoginLogic>();
    super.dispose();
  }
}
