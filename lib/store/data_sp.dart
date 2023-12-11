import 'package:SmartLoan/models/Login_data_model.dart';

import '../util/sp_util.dart';

class DataSp {
  DataSp._();

  static init() async {
    await SpUtil().init();
  }

  static LoginDataModel? getLoginAccount() {
    return SpUtil().getObj(StorageKey.loginAccount, (v) => LoginDataModel.fromJson(v));
  }

  static Future<bool>? putLoginAccount(LoginDataModel loginDataModel) {
    return SpUtil().putObject(StorageKey.loginAccount, loginDataModel);
  }

  static Future<bool>? removeLoginAccount() {
    return SpUtil().remove(StorageKey.loginAccount);
  }

  static Future<bool>? putActiveDevice(bool isSuccess) {
    return SpUtil().putBool(StorageKey.activeDevice, isSuccess);
  }

  static bool getActiveDevice() {
    return SpUtil().getBool(StorageKey.activeDevice) ?? false;
  }
}

class StorageKey {
  static const String loginAccount = 'loginAccount';
  static const String activeDevice = 'activeDevice';
  static const String h5VersionCode = 'h5VersionCode';
}
