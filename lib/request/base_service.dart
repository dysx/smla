import 'package:retry/retry.dart';
import 'package:SmartLoan/store/login_store.dart';
import 'package:SmartLoan/util/plat_form_utils.dart';

import '../base/net/request/base_request.dart';

abstract class BaseService extends BaseRequest {
  RetryOptions retryOptions =
      const RetryOptions(delayFactor: Duration(milliseconds: 500), maxAttempts: 5, randomizationFactor: 0.5);

  @override
  String getBaseUrl() => "http://testmexico-smartloan-3003.gccloud.xyz/api/";

  @override
  Future<Map<String, dynamic>> getRequestCommonHeaders() async {
    Map<String, String> headers = {
      "Content-Type": "application/json; charset=utf-8",
      "packageName": PlatFormUtils().packageName,
      "appName": PlatFormUtils().appName,
      "afId": PlatFormUtils().afId,
      "lang": 'es',
    };

    String token = LoginStore().token;

    if (token.isNotEmpty) {
      headers.addAll({"Authorization": "Bearer$token"});
    }
    return headers;
  }
}
