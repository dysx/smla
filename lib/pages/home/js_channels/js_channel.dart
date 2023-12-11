import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

abstract class JsChannel {
  late List<String> actions;
  WebViewController? webCtrl;
  Map? message;

  register(WebViewController webViewController) async {
    webCtrl = webViewController;
  }

  onReceive(Map newMsg);

  h5CallBack(Map data, {bool isOk = true}) {
    Map callbackMap = {
      'id': '',
      'result': isOk ? 'ok' : 'fail',
      'action': message?['callback'],
      'msg': '',
      'data': data
    };

    webCtrl?.runJavaScript("${message?['callback']}(${json.encode(callbackMap)})");

    debugPrint('jsChannelCallBack <== \n ${message?['callback']} | ${callbackMap} \n');

  }

}