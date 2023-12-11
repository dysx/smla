import 'dart:async';

import 'package:SmartLoan/pages/dialog/permission_dialog.dart';
import 'package:SmartLoan/routers/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:SmartLoan/base/base_view_model.dart';
import 'package:SmartLoan/base/net/http_error_helper.dart';
import 'package:SmartLoan/models/Login_data_model.dart';
import 'package:SmartLoan/models/verify_code_model.dart';
import 'package:SmartLoan/request/request_service.dart';
import 'package:SmartLoan/res/app_str_toast.dart';
import 'package:SmartLoan/store/login_store.dart';
import 'package:SmartLoan/util/extension.dart';
import 'package:SmartLoan/widget/loading_view.dart';

import '../../util/plat_form_utils.dart';
import 'login_state.dart';

class LoginLogic extends BaseViewModel {
  final LoginState state = LoginState();
  bool isButtonDisabled = false;

  @override
  void onInit() {
    // 初始化监听
    PlatFormUtils().log('loginPhone_open');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showPermissionDialog();
    });

    state.phoneFN.addListener(() {
      if (state.phoneFN.hasFocus) {
        PlatFormUtils().log('loginPhone_phoneInput');
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
    state.phoneCtrl.dispose();
    super.onClose();
  }
}

/// 接口请求扩展
extension RequestApi on LoginLogic {}

/// 其他处理方法扩展
extension OtherFunction on LoginLogic {
  // 权限弹窗
  void showPermissionDialog() {
    PermissionsDialog(
      onAgree: () {
        state.phoneFN.requestFocus();
      },
    ).show(Get.context!);
  }

  void apply() async {
    if (!isButtonDisabled) {
      // 关闭键盘
      FocusScope.of(Get.context!).requestFocus(FocusNode());
      isButtonDisabled = true;
      // 执行你的逻辑和接口调用
      PlatFormUtils().log('loginPhone_next');

      if (phoneCheck()) {
        await LoadingView.singleton.wrap(asyncFunction: () async {
          try {
            bool existed = await RequestService.instance.existsByMobile(mobile: state.phoneCtrl.text);

            VerifyCodeModel verifyCodeModel =
                await RequestService.instance.getVerifyCode(mobile: state.phoneCtrl.text, type: existed ? 1 : 2);
            PlatFormUtils().log('loginPhone_sendOtp');

            if (verifyCodeModel.enableAutoLogin ?? false) {
              LoginDataModel loginDataModel = await RequestService.instance.loginCode(
                mobile: state.phoneCtrl.text,
                verifyCode: verifyCodeModel.code ?? '',
                verified: !(verifyCodeModel.enableAutoLogin ?? false),
              );
              LoginStore().saveLoginDataEntity(loginDataModel: loginDataModel);

              Get.offAllNamed(AppRoutes.home);
            } else {
              Get.toNamed(
                AppRoutes.sms,
                arguments: {
                  'phone': state.phoneCtrl.text,
                  'existed': existed,
                },
              );
            }
          } on Exception catch (e) {
            PlatFormUtils().log('loginPhone_SMSFailed');
            HttpErrorHelper.instance.showErrorDialog(error: e);
          }
        });
      }

      // 设置延迟时间后恢复按钮点击状态
      Timer(const Duration(milliseconds: 300), () {
        isButtonDisabled = false;
      });
    }
  }

  bool phoneCheck() {
    if (!state.isAgree) {
      AppStrToast.checkAgreement.showToast();
      return false;
    }

    if (state.phoneCtrl.text.isEmpty) {
      AppStrToast.phoneEmpty.showToast();
      return false;
    }

    if (state.phoneCtrl.text.length != 10) {
      AppStrToast.phoneIncorrect.showToast();
      return false;
    }
    return true;
  }
}
