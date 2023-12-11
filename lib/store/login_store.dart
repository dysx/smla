import 'package:SmartLoan/models/Login_data_model.dart';
import 'package:SmartLoan/store/data_sp.dart';

class LoginStore {
  factory LoginStore() => _instance;
  static final LoginStore _instance = LoginStore._init();

  LoginStore._init() {
    model = getLoginDataEntity();
  }

  // 用户信息
  LoginDataModel? model;

  // 是否登录
  bool get isLogin => model != null;

  // token
  String get token => model?.token ?? '';

  /// 保存 用户信息
  Future<bool?> saveLoginDataEntity({required LoginDataModel loginDataModel}) async {
    model = loginDataModel;
    return DataSp.putLoginAccount(loginDataModel);
  }

  /// 获取 用户信息
  LoginDataModel? getLoginDataEntity() {
    return DataSp.getLoginAccount();
  }

  /// 移除用户信息 -- 退出登录
  Future<bool?> removeLoginDataEntity() async {
    model = null;
    return await DataSp.removeLoginAccount();
  }
}
