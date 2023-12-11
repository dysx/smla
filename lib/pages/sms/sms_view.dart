import 'package:SmartLoan/res/text_styles.dart';
import 'package:SmartLoan/widget/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:SmartLoan/base/base_stateful_widget.dart';
import 'package:SmartLoan/pages/sms/sms_logic.dart';
import 'package:SmartLoan/pages/sms/sms_state.dart';
import 'package:SmartLoan/util/extension.dart';
import 'package:SmartLoan/widget/custom_input.dart';

import '../../widget/auth_common.dart';

class SmsPage extends BaseStatefulWidget {
  const SmsPage({Key? key}) : super(key: key);

  @override
  State<SmsPage> getState() => _SmsPageState();
}

class _SmsPageState extends BaseState<SmsPage> {
  late SmsLogic logic;
  late SmsState state;

  @override
  void initState() {
    setIsHaveKeyboard(false);
    logic = Get.put(SmsLogic());
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
        // appBar: AppBar(
        //   title: Text("Verificación", style: TextStyles.white_16sp_w700),
        //   centerTitle: true,
        //   elevation: 0,
        //   backgroundColor: Colors.transparent,
        //   leading: IconButton(
        //     icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        //     onPressed: () => Get.back(),
        //   ),
        // )
        body: Stack(
          children: [
            AuthBg(
              isAgree: state.isAgree,
              onAgree: (value) {
                state.isAgree = value;
              },
              onPress: logic.login,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: CustomInput(
                        autofocus: true,
                        focusNode: state.smsFNode,
                        controller: logic.state.smsCtrl,
                        hintText: 'Verification Code',
                        keyboardType: TextInputType.number,
                        inputFormatter: [
                          FilteringTextInputFormatter.digitsOnly,
                          // 限制6位
                          LengthLimitingTextInputFormatter(6),
                        ],
                      )),
                      SizedBox(width: 10.w),
                      GetBuilder<SmsLogic>(
                        id: SmsLogic.kIdGetCodeBtn,
                        builder: (_) {
                          String text = state.isGetCodeEnable ? "Conseguir" : "${state.countDown}s";
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => logic.onGetCode(isInit: false, isVoiceCode: false),
                            child: Text(text, style: TextStyles.orange_ED7622_16sp),
                          );
                        },
                      )
                    ],
                  ).decorationBox(
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                      margin: EdgeInsets.symmetric(vertical: 10.h)),
                  20.verticalSpace,
                  _voiceTextShow(),
                ],
              ),
            ),
            // 返回按键
            Positioned(
              // bar的高度
              top: MediaQuery.of(context).viewPadding.top,
              left: 0,
              child: const BackButton(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _voiceTextShow() {
    return GetBuilder<SmsLogic>(
        id: SmsLogic.kIdGetCodeBtn,
        builder: (_) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Offstage(
                offstage: !(state.isShowVoice1),
                child: Text("¿No conseguió el código? Llámame dentro de ${state.countDown}s",
                    style: TextStyles.grey_C4C4C4_12sp),
              ),
              Offstage(
                offstage: !(state.isShowVoice2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("¿No conseguió el código?", style: TextStyles.grey_C4C4C4_12sp),
                    GestureDetector(
                      onTap: () => logic.onGetCode(isInit: false, isVoiceCode: true),
                      child: Text(
                        "Llámame",
                        style: TextStyles.orange_ED7622_12sp,
                      ),
                    )
                  ],
                ),
              ),
              Offstage(
                offstage: !(state.isShowVoice3),
                child: Text(
                  "Le llamaremos dentro de 60s para notificarle el código de",
                  style: TextStyles.grey_C4C4C4_12sp,
                ),
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    Get.delete<SmsLogic>();
    super.dispose();
  }
}
