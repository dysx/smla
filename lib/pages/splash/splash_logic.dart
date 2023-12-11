import 'package:SmartLoan/base/net/encrypt_interceptor.dart';
import 'package:SmartLoan/util/encypt_utils.dart';
import 'package:get/get.dart';
import 'package:SmartLoan/request/request_service.dart';
import 'package:SmartLoan/routers/app_routes.dart';
import 'package:SmartLoan/store/data_sp.dart';
import 'package:SmartLoan/store/login_store.dart';
import 'package:SmartLoan/util/plat_form_utils.dart';
import 'package:SmartLoan/util/sp_util.dart';

import '../../base/base_view_model.dart';
import '../../base/net/http_error_helper.dart';
import 'splash_state.dart';

class SplashLogic extends BaseViewModel {
  final SplashState state = SplashState();

  @override
  void onInit() {
    // 初始化监听
    _direction();
    super.onInit();
  }

  @override
  void onReady() {
    // 数据处理，接口请求
    super.onReady();
  }

  @override
  void onClose() {
    // 销毁资源
    super.onClose();
  }
}

/// 接口请求扩展
extension RequestApi on SplashLogic {
  /// 上传设备信息（第一次打开app信息）（激活接口）
  Future<void> addActive() async {
    if (true) {
      try {
        bool isSuccess = await RequestService.instance.addActive();
        DataSp.putActiveDevice(isSuccess);
      } catch (e) {
        // HttpErrorHelper.instance.showErrorDialog(error: e);
      }
    }
  }
}

/// 其他处理方法扩展
extension OtherFunction on SplashLogic {
  // 跳转
  void _direction() async {
    await _delayAtLeast(future: _initSync());
    checkIsLogin();
  }

  // 初始化
  Future<void> _initSync() async {
    await DataSp.init();
    await PlatFormUtils().platFormInit();
    await EncryptUtil().init(PlatFormUtils().packageName);

    await addActive();

    PlatFormUtils().log('splash_open');
    // await DataSp.removeLoginAccount();
  }

  // 是否已登录
  void checkIsLogin() async {
    if (LoginStore().isLogin) {
      Get.offAndToNamed(AppRoutes.home);
    } else {
      Get.offAndToNamed(AppRoutes.login);
    }
  }

  // 延迟至少多少时间
  Future<void> _delayAtLeast({int millisecond = 2000, required Future future}) async {
    final startMillisecond = DateTime.now().millisecondsSinceEpoch;

    await future;

    final endMillisecond = DateTime.now().millisecondsSinceEpoch;

    final diff = endMillisecond - startMillisecond;
    if (diff >= millisecond) {
      return;
    } else {
      await Future.delayed(Duration(milliseconds: millisecond - diff));
    }
  }
}
