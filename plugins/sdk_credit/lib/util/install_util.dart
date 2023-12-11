import '../base/base_util.dart';
import '../sdk.dart';
import '../sdk_platform_interface.dart';
import 'logger.dart';

class InstallUtil extends BaseUtil {
  static final InstallUtil _singleton = InstallUtil._internal();

  factory InstallUtil() {
    return _singleton;
  }

  InstallUtil._internal();

  @override
  Future<String?> exec(AfEvent? afEvent, {bool isSubmit = false}) async {
    try {
      // AF回调开始
      afEvent?.call('sdk_apps_get');
      // 获取数据
      final rlt = await _assembleData();
      Log().LogD('appList data = $rlt');
      if (rlt?.isNotEmpty ?? false) {
        // AF回调成功
        afEvent?.call('sdk_apps_success');
        return rlt;
      } else {
        afEvent?.call('sdk_fail_apps');
      }
    } catch (e) {
      // AF回调失败
      afEvent?.call('sdk_fail_apps');
      Log().LogE(e.toString());
    }

    return null;
  }


  Future<String?> _assembleData() async {
    return await SdkPlatform.instance.getAppList();
  }
}
