import 'package:SmartLoan/res/app_str_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:SmartLoan/util/common_utils.dart';

import 'request/constants.dart';
import 'request/http_error.dart';

class HttpErrorHelper {
  HttpErrorHelper._();

  static final HttpErrorHelper _instance = HttpErrorHelper._();

  static final HttpErrorHelper instance = _instance;

  factory HttpErrorHelper() => _instance;

  /// 展示错误弹窗
  void showErrorDialog({
    required Object error,
    GestureCancelCallback? onConfirm,
    GestureCancelCallback? onCancel,
  }) {
    CommonUtils.showToast(getTipByError(error: error));
  }

  /// 根据错误获取提示
  String getTipByError({required Object error}) {
    if (error is NetworkError) {
      return AppStrToast.timeOutError;
    } else if (error is HttpError) {
      String errorText = "请求错误：${error.responseCode}\n${error.responseMessage}";

      if (error is NetworkError) {
        errorText = AppStrToast.timeOutError;
      }

      // errorText = _getHttpErrorTip(error.responseCode, error.responseMessage ?? '');
      errorText = error.responseMessage ?? 'network Error';
      return errorText;
    }

    return "未知错误：\n$error";
  }

  String _getHttpErrorTip(int? code, String message) => "错误码：$code \n错误信息：$message";
}
