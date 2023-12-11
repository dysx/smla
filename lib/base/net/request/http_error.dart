import 'package:SmartLoan/res/app_str_toast.dart';

import 'constants.dart';

/// 统一网络异常报错
class HttpError implements Exception {
  // 状态码
  final int statusCode;

  // 状态信息
  final String? statusMessage;

  // 业务响应码
  final int? responseCode;

  // 业务响应信息
  final String? responseMessage;

  final dynamic data;

  HttpError(
    this.statusCode, {
    this.statusMessage,
    this.responseCode,
    this.responseMessage,
    this.data,
  });

  @override
  String toString() {
    return "HttpError : statusCode:$statusCode statusMessage:$statusMessage responseCode:$responseCode responseMessage:$responseMessage";
  }
}

/// 网络错误
class NetworkError extends HttpError {
  NetworkError() : super(-2, statusMessage: AppStrToast.timeOutError);
}
