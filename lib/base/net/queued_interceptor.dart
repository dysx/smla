import 'package:dio/dio.dart';

import 'dio_helper.dart';

// typedef CheckIsNeedRefresh = bool Function(String oldToken);
// typedef NewTokenSend = String Function();
// typedef OnRefreshToken = Future<String> Function();

const String _kKeyAuthorization = "Authorization";

class QueuedInterceptor extends QueuedInterceptorsWrapper {
  // // 判断是否需要刷新
  // final CheckIsNeedRefresh checkIsNeedRefresh;
  //
  // // 新token
  // final NewTokenSend newToken;
  //
  // // 获取新token
  // final OnRefreshToken onRefreshToken;

  QueuedInterceptor();

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    super.onError(err, handler);

    // token过期情况
    if (err.response?.statusCode == 401) {
      var options = err.response!.requestOptions;

      // if (options.headers[_kKeyAuthorization] == LoginManager.instance.userModel!.token ||
      //     options.headers[_kKeyAuthorization] == null) {
      //   await LoginManager().loginWithUuid();
      //   options.headers[_kKeyAuthorization] = LoginManager.instance.userModel!.token;
      // } else {
      //   options.headers[_kKeyAuthorization] = LoginManager.instance.userModel!.token;
      // }

      // 重新请求
      DioHelper.instance.dio.fetch(options).then(
            (value) => handler.resolve(value),
            onError: (e) => handler.reject(e),
          );

      return;
    }

    handler.next(err);
  }
}
