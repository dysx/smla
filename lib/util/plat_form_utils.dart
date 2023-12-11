import 'package:android_id/android_id.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:install_referrer/install_referrer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:SmartLoan/util/logger.dart';

class PlatFormUtils {
  factory PlatFormUtils() => _instance;
  static final PlatFormUtils _instance = PlatFormUtils._init();

  PlatFormUtils._init();

  Future<void> platFormInit() async {
    try {
      _packageInfo ??= await PackageInfo.fromPlatform();
      _androidDeviceInfo ??= await DeviceInfoPlugin().androidInfo;
      _androidId = await const AndroidId().getId() ?? '';

      _installRefer = await _getInstallReferrer();
      _afId = await _getAfId();
    } on Exception catch (e) {
      Logger.dPrint('platFormInit ${e.toString()}');
    }
  }

  late AppsflyerSdk _appsflyerSdk;

  log(String eventName) async {
    debugPrint('af log => \n $eventName');
    _appsflyerSdk.logEvent(eventName, {});
  }

  Future<String> _getAfId() async {
    if (_afId.isNotEmpty) return _afId;

    _appsflyerSdk = AppsflyerSdk({"afDevKey": "yFbZbrMQ7eoqbZ4BdAPN", "isDebug": false});
    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    return (await _appsflyerSdk.getAppsFlyerUID())!;
  }

  Future<String> _getInstallReferrer() async {
    String temp = '';
    try {
      InstallationAppReferrer installRefer = await InstallReferrer.referrer;
      temp = installRefer.toString();
    } on Exception catch (e) {
      Logger.dPrint(e.toString());
    }
    return temp;
  }

  /// ----- 安卓设备信息 -----
  /// adrVersion
  int get adrVersion => _androidDeviceInfo?.version.sdkInt ?? 1;

  String get androidId => _androidId ?? '';

  String get installRefer => _installRefer ?? '';

  String get afId => _afId ?? '';

  /// ----- 包信息 -----
  /// appVersion
  String get appVersion => _packageInfo?.version ?? '';

  String get packageName => _packageInfo?.packageName ?? '';

  String get buildNumber => _packageInfo?.buildNumber ?? '';

  String get appName => _packageInfo?.appName ?? '';

  String get channelId => 'SmartLoan';

  AndroidDeviceInfo? _androidDeviceInfo;
  PackageInfo? _packageInfo;
  String? _androidId;

  String _installRefer = "";
  String _afId = '';

  /// [adrVersion] | int 手机android版本号Build.VERSION.SDK_INT
  /// [appVersion] | String app的版本名 BuildConfig.VERSION_NAME
  /// [androidId] String 设备id  Settings.System.getString(context.getContentResolver(),   Settings.System.ANDROID_ID);
  /// [packageName] | String 包名（如：com.mmt.smartloan）
  /// [appName] | String
  /// [channelId] | String 渠道id (如SmartLoan)
  /// [installReferce] | 需接入sdk，可百度了解 implementation   'com.android.installreferrer:installreferrer:1.1'
  /// [afId] | String
}
