import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../base/base_view_model.dart';
import 'deal_state.dart';

class DealLogic extends BaseViewModel {
  final DealState state = DealState();

  @override
  void onInit() {
    // 初始化监听
    initPage();
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

/// 其他处理方法扩展
extension OtherFunction on DealLogic {
  initPage() {
    state.webCtrl = WebViewController.fromPlatformCreationParams(const PlatformWebViewControllerCreationParams());

    state.webCtrl
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
            onProgress: (int process) async {
              debugPrint('${await state.webCtrl.currentUrl()} process: $process');
            },
            onPageFinished: (String value) {}),
      )
      ..enableZoom(false)
      ..loadRequest(Uri.parse(Get.arguments['url'] ?? 'http://testmexico-smartloan-3003.gccloud.xyz'));
  }
}
