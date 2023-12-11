import 'dart:async';

import 'package:SmartLoan/base/base_view_model.dart';
import 'package:SmartLoan/base/net/http_error_helper.dart';
import 'package:SmartLoan/models/Login_data_model.dart';
import 'package:SmartLoan/models/verify_code_model.dart';
import 'package:SmartLoan/pages/sms/sms_state.dart';
import 'package:SmartLoan/request/request_service.dart';
import 'package:SmartLoan/res/app_str_toast.dart';
import 'package:SmartLoan/routers/app_routes.dart';
import 'package:SmartLoan/store/data_sp.dart';
import 'package:SmartLoan/store/login_store.dart';
import 'package:SmartLoan/util/common_utils.dart';
import 'package:SmartLoan/util/extension.dart';
import 'package:SmartLoan/widget/loading_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../util/plat_form_utils.dart';

class SmsLogic extends BaseViewModel {
  static const String kIdGetCodeBtn = "get_code_btn";

  final SmsState state = SmsState();

  @override
  void onInit() {
    state.phone = Get.arguments['phone'] ?? "";
    state.existed = Get.arguments['existed'] ?? false;

    PlatFormUtils().log('logincode_open');

    // 初始化监听
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onGetCode(isInit: true, isVoiceCode: false);
    });

    state.smsFNode.addListener(() {
      if (state.smsFNode.hasFocus) {
        PlatFormUtils().log('logincode_codeInput');
      }
    });

    super.onInit();
  }

  @override
  void onReady() {
    // 数据处理，接口请求
    super.onReady();
  }

  @override
  void onClose() {
    // 销毁资源
    super.onClose();
  }
}

/// 接口请求扩展
extension RequestApi on SmsLogic {
  // 登录
  void login() async {
    PlatFormUtils().log('logincode_confirm');

    // 关闭键盘
    FocusScope.of(Get.context!).requestFocus(FocusNode());

    if (!codeCheck()) return;
    try {
      await LoadingView.singleton.wrap(asyncFunction: () async {
        late LoginDataModel loginDataModel;
        if (state.existed) {
          PlatFormUtils().log('logincode_login');
          loginDataModel = await RequestService.instance.loginCode(
            mobile: state.phone,
            verifyCode: state.smsCtrl.text,
            verified: true,
          );
          PlatFormUtils().log('logincode_LoginSuccess');
        } else {
          PlatFormUtils().log('logincode_reg');
          loginDataModel = await RequestService.instance.register(
            mobile: state.phone,
            verifyCode: state.smsCtrl.text,
            verified: true,
          );
          PlatFormUtils().log('logincode_RegSuccess');
        }
        await LoginStore().saveLoginDataEntity(loginDataModel: loginDataModel);

        Get.offAllNamed(AppRoutes.home);
      });
    } on Exception catch (e) {
      HttpErrorHelper.instance.showErrorDialog(error: e);
      if (state.existed) {
        PlatFormUtils().log('logincode_Loginfailed');
      } else {
        PlatFormUtils().log('logincode_Regfailed');
      }
    }
  }
}

/// 其他处理方法扩展
extension OtherFunction on SmsLogic {
  void onGetCode({required bool isInit, required bool isVoiceCode}) async {
    if (isVoiceCode) {
      PlatFormUtils().log('logincode_voiceVerification');
    } else {
      PlatFormUtils().log('logincode_verificationResend');
    }

    if (state.countDown == kDefaultCountDown) {
      //检查网络是否连接
      ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        CommonUtils.showToast(AppStrToast.timeOutError);
        return;
      }

      if (!isInit) {
        await LoadingView.singleton.wrap(
          asyncFunction: () async {
            try {
              if (isVoiceCode) {
                PlatFormUtils().log('logincode_voiceSendOtp');
              } else {
                // PlatFormUtils().log('logincode_verificationResend');
              }
              VerifyCodeModel verifyCodeModel = await RequestService.instance
                  .getVerifyCode(mobile: state.phone, type: state.existed ? 1 : 2, notifyType: isVoiceCode ? 2 : 1);
              if (isVoiceCode) {
                PlatFormUtils().log('logincode_voiceSuccess');
              } else {
                // PlatFormUtils().log('logincode_verificationResend');
              }
            } on Exception catch (e) {
              HttpErrorHelper.instance.showErrorDialog(error: e);
              if (isVoiceCode) {
                PlatFormUtils().log('logincode_voiceFailed');
              } else {
                PlatFormUtils().log('logincode_SMSFailed');
              }
            }
          },
        );
      }

      state.sendVoiceCode = isVoiceCode;
      // 开始倒计时
      _startCountDown();
    }
  }

  // 开始倒计时
  void _startCountDown() {
    // 手动执行一次倒计时逻辑
    state.countDown--;
    update([SmsLogic.kIdGetCodeBtn]);

    state.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countDown == 0) {
        state.countDown = kDefaultCountDown;
        state.timer?.cancel();
        state.timer = null;
        state.isShowVoice1 = false;
        state.isShowVoice2 = true;
        state.isShowVoice3 = false;
      } else {
        if (state.sendVoiceCode) {
          // 语音
          state.isShowVoice1 = false;
          state.isShowVoice2 = false;
          state.isShowVoice3 = true;
        } else {
          // 短信
          state.isShowVoice1 = true;
          state.isShowVoice2 = false;
          state.isShowVoice3 = false;
        }

        state.countDown--;
      }
      update([SmsLogic.kIdGetCodeBtn]);
    });
  }

  bool codeCheck() {
    if (!state.isAgree) {
      AppStrToast.checkAgreement.showToast();
      return false;
    }

    if (state.smsCtrl.text.isEmpty) {
      AppStrToast.codeEmpty.showToast();
      return false;
    }

    if (state.smsCtrl.text.length != 6) {
      AppStrToast.codeIncorrect.showToast();
      return false;
    }
    return true;
  }
}
