import 'package:sdk_credit/base/base_util.dart';
import 'package:sdk_credit/sdk.dart';

import '../sdk_platform_interface.dart';
import 'logger.dart';

class ContactUtil extends BaseUtil {
  static final ContactUtil _singleton = ContactUtil._internal();

  factory ContactUtil() {
    return _singleton;
  }

  ContactUtil._internal();

  @override
  Future<String?> exec(AfEvent? afEvent, {bool isSubmit = false}) async {

    try {
      // AF回调开始
      afEvent?.call('sdk_contact_get');
      final rlt = await _assembleData();
      Log().LogD('contact data = $rlt');
      if (rlt?.isNotEmpty ?? false) {
        // AF回调成功
        afEvent?.call('sdk_contact_success');
        return rlt;
      } else {
        afEvent?.call('sdk_fail_contact');
      }
    } catch (e) {
      // AF回调失败
      afEvent?.call('sdk_fail_contact');
      Log().LogE(e.toString());
    }
    return null;
  }


  ///
  /// 组装数据，根据插件自己组装
  ///
  Future<String?> _assembleData() async {
    return await SdkPlatform.instance.getContact();
  }
}
