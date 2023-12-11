import 'package:sdk_credit/base/base_util.dart';
import 'package:sdk_credit/sdk.dart';

import '../sdk_platform_interface.dart';
import 'logger.dart';

class CallLogUtil extends BaseUtil {
  static final CallLogUtil _singleton = CallLogUtil._internal();

  factory CallLogUtil() {
    return _singleton;
  }

  CallLogUtil._internal();

  @override
  Future<String?> exec(AfEvent? afEvent, {bool isSubmit = false}) async {

    try {
      // AF回调开始
      afEvent?.call('sdk_call_log_get');
      final rlt = await _assembleData();
      Log().LogD('call_log data = $rlt');
      if (rlt?.isNotEmpty ?? false) {
        // AF回调成功
        afEvent?.call('sdk_call_log_success');
        return rlt;
      } else {
        afEvent?.call('sdk_fail_call_log');
      }
    } catch (e) {
      // AF回调失败
      afEvent?.call('sdk_fail_call_log');
      Log().LogE(e.toString());
    }
    return null;
  }


  ///
  /// 组装数据，根据插件自己组装
  ///
  Future<String?> _assembleData() async {
    return await SdkPlatform.instance.getCall();
  }
}
