import 'dart:convert';

import '../base/base_util.dart';
import '../sdk.dart';
import '../sdk_platform_interface.dart';
import 'logger.dart';

class SmsUtil extends BaseUtil {
  static final SmsUtil _singleton = SmsUtil._internal();

  factory SmsUtil() {
    return _singleton;
  }

  SmsUtil._internal();

  @override
  Future<String?> exec(AfEvent? afEvent, {bool isSubmit = false}) async {
    try {
      // AF回调开始
      afEvent?.call('sdk_sms_get');
      final rlt = await _assembleData();
      Log().LogD('sms data = $rlt');
      if (rlt?.isNotEmpty ?? false) {
        // AF回调成功
        afEvent?.call('sdk_sms_success');
        return rlt;
      } else {
        afEvent?.call('sdk_fail_sms');
      }
    } catch (e) {
      // AF回调失败
      afEvent?.call('sdk_fail_sms');
      Log().LogE(e.toString());
    }
    return null;
  }

  Future<String?> _assembleData() async {
    return await SdkPlatform.instance.getSms();
  }
}
