import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../util/encypt_utils.dart';

class EncryptInterceptor extends Interceptor {

  static bool encryptSwitch = true;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {

    if (options.path.contains('/zip6in1')) {
      options.headers['contentType'] = "multipart/form-data";
      options.headers['content-type'] = "multipart/form-data";
    }

    if ( !encryptSwitch && options.path.contains('/login')) {
      options.headers['contentType'] = "application/x-www-form-urlencoded";
      options.headers['content-type'] = "application/x-www-form-urlencoded";
    }

    if (encryptSwitch) {

      List<String> splitStrs = options.path.split('api');
      debugPrint('path输出: ${splitStrs[1]} \n');

      String encryptPath = splitStrs[0] + 'api/' + EncryptUtil().encrypt(splitStrs[1]);
      options.path = encryptPath;

      // encrypt data
      var data = options.data;
      debugPrint('参数输出: \n');

      if (data is Map) {
        debugPrint('${jsonEncode(data)}');
      } else {
        debugPrint('${data}');
      }

      if (data is Map) {
        options.data = EncryptUtil().encrypt(jsonEncode(data));
      }

    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {

    if (encryptSwitch) {
      var data = response.data;
      if (data is! Map) {
        response.data = jsonDecode(EncryptUtil().decrypt(data));
        debugPrint('解密返回: \n');
        debugPrint('${response.data}');
      }
    }

    super.onResponse(response, handler);
  }


}