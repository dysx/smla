import '../base/base_util.dart';
import '../sdk.dart';
import '../sdk_platform_interface.dart';
import 'logger.dart';

class DeviceUtil extends BaseUtil {
  static final DeviceUtil _singleton = DeviceUtil._internal();

  factory DeviceUtil() {
    return _singleton;
  }

  DeviceUtil._internal();

  @override
  Future<String?> exec(AfEvent? afEvent, {bool isSubmit = false}) async {
    try {
      // AF回调开始
      afEvent?.call('sdk_device_get');
      final rlt = await _getData();
      Log().LogD('device data = $rlt');
      if (rlt?.isNotEmpty ?? false) {
        // AF回调成功
        afEvent?.call('sdk_device_success');
        return rlt;
      } else {
        afEvent?.call('sdk_fail_device');
      }
    } catch (e) {
      // AF回调失败
      afEvent?.call('sdk_fail_device');
      Log().LogE(e.toString());
    }
    return null;
  }

  Future<String?> _getData() async {
    return await SdkPlatform.instance.getDevice();
  }
}
