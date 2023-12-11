import 'package:SmartLoan/models/Login_data_model.dart';
import 'package:SmartLoan/store/login_store.dart';
import 'package:SmartLoan/util/app_launch.dart';
import 'package:SmartLoan/util/plat_form_utils.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

import '../../../routers/app_routes.dart';
import 'js_channel.dart';

// getLoginInfo
class GetLoginInfo extends JsChannel {
  @override
  List<String> get actions => ['getLoginInfo'];

  @override
  onReceive(Map newMsg) {
    if (LoginStore().isLogin) {
      h5CallBack({
        'token': LoginStore().token
      });
    } else {
      Get.offAndToNamed(AppRoutes.login);
    }
  }
}

// toLogin logout
class ToAuth extends JsChannel {
  @override
  List<String> get actions => ['toLogin', 'logout'];

  @override
  onReceive(Map newMsg) async {
    if (LoginStore().isLogin) {
      LoginStore().removeLoginDataEntity();
    }
    await webCtrl?.clearCache();
    Get.offAndToNamed(AppRoutes.login);
  }
}

// getVersionName
class GetVersionName extends JsChannel {
  @override
  List<String> get actions => ['getVersionName'];

  @override
  onReceive(Map newMsg) {
    h5CallBack({'versionName': PlatFormUtils().appVersion});
  }
}

// getPackageName
class GetPackageName extends JsChannel {
  @override
  List<String> get actions => ['getPackageName'];

  @override
  onReceive(Map newMsg) {
    h5CallBack({
      'packageName': PlatFormUtils().packageName,
      'androidId': PlatFormUtils().androidId,
      'imei': '000000000000000',
      'afid': PlatFormUtils().afId,
      'appVersion': PlatFormUtils().appVersion,
      'appName': PlatFormUtils().appName,
    });
  }
}

// setNewToken
class SetNewToken extends JsChannel {
  @override
  List<String> get actions => ['setNewToken'];

  @override
  onReceive(Map newMsg) {
    LoginStore().saveLoginDataEntity(loginDataModel: LoginDataModel(
      mobile: LoginStore().model?.mobile,
      userId: LoginStore().model?.userId,
      token: newMsg['token']
    ));
  }
}

// ToWhatsapp
class ToWhatsapp extends JsChannel {
  @override
  List<String> get actions => ['toWhatsapp'];

  @override
  onReceive(Map newMsg) {
    final Uri toWhatLaunch = Uri.https('api.whatsapp.com', '/send', {'phone': newMsg['phone']});
    AppLaunch.launch(toWhatLaunch.toString());
  }
}

// toGooglePlayer
class ToGooglePlayer extends JsChannel {
  @override
  List<String> get actions => ['toGooglePlayer'];

  @override
  onReceive(Map newMsg) {
    String iru = newMsg['packageId'];
    AppLaunch.googleLaunch(iru);
  }
}

// logEventByAF
class LogEventByAF extends JsChannel {
  @override
  List<String> get actions => ['logEventByAF'];

  @override
  onReceive(Map newMsg) {
    // AppsFlyer().logEvent(newMsg?['data']['event']);
  }
}

