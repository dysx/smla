import 'package:SmartLoan/pages/home/js_channels/liveness_channel.dart';
import 'package:SmartLoan/pages/home/js_channels/timesdk_channel.dart';
import 'package:flutter/cupertino.dart';
import 'package:SmartLoan/pages/home/js_channels/js_channel_collection.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart' as webview_flutter_android;

import 'js_channels/js_channel.dart';

class HomeState {
  late WebViewController webCtrl;
  late webview_flutter_android.AndroidWebViewController androidWebViewController;

  List<JsChannel> jsChannels = [
    GetLoginInfo(),
    ToAuth(),
    GetVersionName(),
    GetPackageName(),
    SetNewToken(),
    ToWhatsapp(),
    ToGooglePlayer(),
    LogEventByAF(),
    LivenessChannel(),
    TimeSdkChannel(),
  ];
}
