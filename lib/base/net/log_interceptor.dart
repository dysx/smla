import 'dart:convert';

import 'package:dio/dio.dart';

import '../../util/logger.dart';

class LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.dPrint("================= Request  ${options.uri} start ======================");
    Logger.dPrint("headers : ${options.headers}");
    Logger.dPrint("method : ${options.method}");
    Logger.dPrint("contentType : ${options.contentType}");
    Logger.dPrint("responseType : ${options.responseType}");
    try {
      if (options.data != null) {
        if (options.data.runtimeType == FormData) {
          Logger.dPrint("data : ${options.data}");
        } else {
          Logger.dPrint("data : ${jsonEncode(options.data)}");
        }
      } else {
        Logger.dPrint("data : ${options.data}");
      }
    } catch (e) {
      Logger.dPrint("onRequest----解析报错：$e");
    }

    Logger.dPrint("================= Request  ${options.uri} end   ======================");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.dPrint("================= Response ${response.requestOptions.uri} start ======================");
    Logger.dPrint("statusCode : ${response.statusCode}");
    if (response.data != null) {
      if (response.data.runtimeType == FormData) {
        Logger.dPrint("result : ${response.data}");
      } else {
        try {
          if (response.data.runtimeType != ResponseBody) {
            Logger.dPrint("result : ${jsonEncode(response.data)}");
          }
        } catch (e) {
          Logger.dPrint("onResponse----result响应解析报错 : $e");
        }
      }
    } else {
      Logger.dPrint("result : ${response.data}");
    }

    Logger.dPrint("================= Response ${response.requestOptions.uri} end   ======================");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    Logger.dPrint("================= DioError ${err.requestOptions.uri} start ======================");
    Logger.dPrint("$err");
    if (err.response != null) {
      Logger.dPrint("statusCode : ${err.response!.statusCode}");
      Logger.dPrint("result : ${err.response!.data}");
    }
    Logger.dPrint("================= DioError ${err.requestOptions.uri} end   ======================");

    return super.onError(err, handler);
  }
}
