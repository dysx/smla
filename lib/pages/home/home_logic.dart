import 'dart:convert';
import 'dart:io';

import 'package:SmartLoan/base/net/request/http_error.dart';
import 'package:SmartLoan/models/New_version_model.dart';
import 'package:SmartLoan/pages/dialog/update_dialog.dart';
import 'package:SmartLoan/res/app_str_toast.dart';
import 'package:SmartLoan/store/data_sp.dart';
import 'package:SmartLoan/util/app_launch.dart';
import 'package:SmartLoan/util/extension.dart';
import 'package:SmartLoan/util/plat_form_utils.dart';
import 'package:SmartLoan/util/sp_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:get/get.dart';
import 'package:SmartLoan/base/base_view_model.dart';
import 'package:SmartLoan/pages/dialog/permission_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart' as webview_flutter_android;
import 'package:permission_handler/permission_handler.dart';

import '../../base/net/http_error_helper.dart';
import '../../base/net/request/http_error.dart';
import '../../request/request_service.dart';
import '../../util/image_utils.dart';
import 'home_state.dart';

class HomeLogic extends BaseViewModel {
  final HomeState state = HomeState();

  @override
  void onInit() {
    // 初始化监听
    initWebView();
    jsChannelRegister();
    super.onInit();
  }

  @override
  void onReady() {
    // 数据处理，接口请求
    checkUpdate();
    super.onReady();
  }

  @override
  void onClose() {
    // 销毁资源
    super.onClose();
  }
}

/// 接口请求扩展
extension RequestApi on HomeLogic {}

/// 其他处理方法扩展
extension OtherFunction on HomeLogic {
  // initWebView
  initWebView() {
    state.webCtrl = WebViewController.fromPlatformCreationParams(
      const PlatformWebViewControllerCreationParams()
    );

    if (Platform.isAndroid) {
      state.androidWebViewController = (state.webCtrl.platform as webview_flutter_android.AndroidWebViewController);
      state.androidWebViewController.setOnShowFileSelector(_fileSelector);
    }

    state.webCtrl
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
          onProgress: (int process) async {
            debugPrint('${await state.webCtrl.currentUrl()} process: $process');
          },
          onPageFinished: (String value) {}))
      ..enableZoom(false)
      ..addJavaScriptChannel('FKSDKJsFramework', onMessageReceived: (JavaScriptMessage msg) {
        onMessageReceive(msg);
      })
      ..loadRequest(Uri.parse('http://testmexico-smartloan-3003.gccloud.xyz'));
  }

  Future<List<String>> _fileSelector(webview_flutter_android.FileSelectorParams params) async {
    PermissionStatus status = await Permission.camera.request();

    if (status == PermissionStatus.permanentlyDenied) {
      AppStrToast.permissionAsk.showToast();

    } else if (status == PermissionStatus.granted) {

      final XFile? photo = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: 2048,
          maxHeight: 2048
      );

      if (photo == null) {
        return [];
      }

      String? compressPath = await ImageUtils.compressImage(photo.path, 1.0 * 1024 * 1024, 99);
      debugPrint('compressPath: ${await File(compressPath!).length()}');

      if (compressPath == null) {
        debugPrint('compressPath 为null');
        return [];
      }

      return [File(compressPath).uri.toString()];

    } else {
      AppStrToast.permissionAsk.showToast();

    }

    return [];
  }

  jsChannelRegister() async {
    for (var element in state.jsChannels) {
      element.register(state.webCtrl);
    }
  }

  onMessageReceive(JavaScriptMessage jsMsg) {
    debugPrint('onMessageReceive ===> \n ${jsMsg.message} \n');
    Map msgMap = jsonDecode(jsMsg.message);

    for (var element in state.jsChannels) {
      if (element.actions.contains(msgMap['action'])) {
        if (element.webCtrl == null) {
          element.register(state.webCtrl);
        }
        element.message = msgMap;
        element.onReceive(msgMap);
      }
    }
  }

  Future<bool> webViewOnBack() async {

    // 含有以下字段加载首页
    List<String> defaultUrls = [
      "id_card_authentication",
      "emergency_contacts",
      "personal_infomation",
      "review_tips",
      "add_bankcard",
      "confirm_borrow",
      "additionalInfomation",
      "records",
      "me",
    ];

    String currentUrl = await state.webCtrl.currentUrl() ?? "";
    String? matchUrl;
    String? matchNeedHomeUrl;

    debugPrint('matchUrl: $matchUrl');
    // debugPrint('currentUrl path: ${Uri.parse(currentUrl).path}');

    Uri currentUri = Uri.parse(currentUrl);
    debugPrint('currentUrl path: ${currentUri.path}');
    debugPrint('currentUrl fragment: ${currentUri.fragment}');

    if (currentUri.path == "/" && currentUri.fragment == '/') {
      // 主页
      SystemNavigator.pop();
      return false;
    } else {

      // 检测needHomeUrl
      for (var element in defaultUrls) {
        if (currentUrl.contains(element)) {
          matchNeedHomeUrl = element;
        }
      }

      debugPrint('matchNeedHomeUrl: ${matchNeedHomeUrl}');
      if (matchNeedHomeUrl != null) {
        state.webCtrl.loadRequest(Uri.parse('http://testmexico-smartloan-3003.gccloud.xyz'));
        return false;

      } else {
        // 走正常回退
        if (await state.webCtrl.canGoBack()) {
          debugPrint('controller can go back');
          state.webCtrl.goBack();
          return false;
        } else {
          return true;
        }
      }
    }
  }

  checkUpdate() async {
    try {
      NewVersionModel newVersionModel =
          await RequestService.instance.getNewVersion(packageName: PlatFormUtils().packageName);

      int localVersionCode = SpUtil().getInt(StorageKey.h5VersionCode) ?? -1;
      if (localVersionCode < newVersionModel.h5VersionCode!) {
        state.webCtrl.clearCache();
        SpUtil().putInt(StorageKey.h5VersionCode, localVersionCode);
      }

      if (int.parse(newVersionModel.versionCode.toString()) > int.parse(PlatFormUtils().buildNumber)) {

        showAnimatedDialog(
          context: Get.context!,
          builder: (BuildContext context) {
            return VersionDialog(
              forceUpdate: newVersionModel.forcedUpdate ?? false,
              onTap: () {
                PlatFormUtils().log('updateConfirm_yes');
                AppLaunch.googleLaunch(newVersionModel.link ?? '');
              },
            );
          },
          barrierDismissible: false,
          animationType: DialogTransitionType.slideFromBottom,
          // duration: Duration(seconds: 1)
        );
      }
    } on Exception catch (e) {
      if (e is! NetworkError) {
        HttpErrorHelper.instance.showErrorDialog(error: e);
      }
    }
  }
}
