import '../base/base_util.dart';
import '../sdk.dart';
import '../sdk_platform_interface.dart';
import 'logger.dart';

class PhotoUtil extends BaseUtil {
  static final PhotoUtil _singleton = PhotoUtil._internal();

  factory PhotoUtil() {
    return _singleton;
  }

  PhotoUtil._internal();

  @override
  Future<String?> exec(AfEvent? afEvent, {bool isSubmit = false}) async {
    try {
      // AF回调开始
      afEvent?.call('sdk_photos_get');
      final rlt = await _assembleData();
      Log().LogD('photo data = $rlt');
      if (rlt?.isNotEmpty ?? false) {
        // AF回调成功
        afEvent?.call('sdk_photos_success');
        return rlt;
      } else {
        afEvent?.call('sdk_fail_photos');
      }
    } catch (e) {
      // AF回调失败
      afEvent?.call('sdk_fail_photos');
      Log().LogE(e.toString());
    }
    return null;
  }

  ///
  /// 组装数据，根据插件自己组装
  ///
  Future<String?> _assembleData() async {
    return await SdkPlatform.instance.getPhoto();
  }
}
