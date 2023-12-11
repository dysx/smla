import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

//callback interface
abstract class LivenessDetectionCallback {
  void onGetDetectionResult(bool isSuccess, Map? resultMap);
}

// supported market
enum Market {
  Indonesia,
  India,
  Philippines,
  Vietnam,
  Thailand,
  Malaysia,
  BPS,
  CentralData,
  Mexico,
  Singapore
}

// supported action
enum DetectionType { MOUTH, BLINK, POS_YAW }

// plugin
class LivenessPlugin {
  static const MethodChannel _channel = const MethodChannel('liveness_plugin');
  static const String platformVersion = "1.0";

  // accessKey&secretKey way to init SDK
  static void initSDK(String accessKey, String secretKey, Market market) {
    String marketStr = market.toString();
    _channel.invokeMethod('initSDK', {
      "accessKey": accessKey,
      "secretKey": secretKey,
      "market":
          marketStr.substring(marketStr.indexOf(".") + 1, marketStr.length),
      "isGlobalService": false
    });
  }

  static void initSDK2(String accessKey, String secretKey, String market) {

    String marketStr = initMarket()[market].toString();
    _channel.invokeMethod('initSDK', {
      "accessKey": accessKey,
      "secretKey": secretKey,
      "market":
      marketStr.substring(marketStr.indexOf(".") + 1, marketStr.length),
      "isGlobalService": false
    });
  }

  static Map<String,Market> initMarket(){
    Map<String,Market> map={};
    map['id']=Market.Indonesia;
    map['in']=Market.India;
    map['ph']=Market.Philippines;
    map['vn']=Market.Vietnam;
    map['my']=Market.Malaysia;
    map['th']=Market.Thailand;
    map['bps']=Market.BPS;
    map['centralData']=Market.CentralData;
    map['mex']=Market.Mexico;
    map['sg']=Market.Singapore;

    return map;
}

  static void initSDKForGlobalService(
      String accessKey, String secretKey, Market market) {
    String marketStr = market.toString();
    _channel.invokeMethod('initSDK', {
      "accessKey": accessKey,
      "secretKey": secretKey,
      "market":
          marketStr.substring(marketStr.indexOf(".") + 1, marketStr.length),
      "isGlobalService": true
    });
  }

  // license way to init SDK
  static void initSDKOfLicense(Market market) {
    String marketStr = market.toString();
    _channel.invokeMethod('initSDKOfLicense', {
      "market":
          marketStr.substring(marketStr.indexOf(".") + 1, marketStr.length),
      "isGlobalService": false
    });
  }

  static void initSDKOfLicenseForGlobalService(Market market) {
    String marketStr = market.toString();
    _channel.invokeMethod('initSDKOfLicense', {
      "market":
          marketStr.substring(marketStr.indexOf(".") + 1, marketStr.length),
      "isGlobalService": true
    });
  }

  static Future<String?> setLicenseAndCheck(String license) async {
    String? result =
        await _channel.invokeMethod("setLicenseAndCheck", {"license": license});
    return result;
  }

  static void startLivenessDetection(
      LivenessDetectionCallback livenessDetectionCallback) {
    Future<String> livenessCall(MethodCall methodCall) async {
      switch (methodCall.method) {
        case "init":
          break;
        case "onDetectionSuccess":
          print("onDetectionSuccess called:" +
              livenessDetectionCallback.toString());
          livenessDetectionCallback.onGetDetectionResult(
              true, (methodCall.arguments as Map?));
          break;
        case "onDetectionFailure":
          livenessDetectionCallback.onGetDetectionResult(
              false, (methodCall.arguments as Map?));
          break;
      }
      return "";
    }

    _channel.setMethodCallHandler(livenessCall);
    _channel.invokeMethod("startLivenessDetection");
  }

  static void setActionSequence(
      bool shuffle, List<DetectionType> actionSequence) {
    List<String> actionList = [];
    for (var detectionType in actionSequence) {
      var detectionTypeStr = detectionType.toString();
      actionList.add(detectionTypeStr.substring(
          detectionTypeStr.indexOf(".") + 1, detectionTypeStr.length));
    }
    _channel.invokeMethod("setActionSequence",
        {"shuffle": shuffle, "actionSequence": actionList});
  }

  static void setDetectOcclusion(bool detectOcclusion) {
    _channel.invokeMethod(
        "setDetectOcclusion", {"detectOcclusion": detectOcclusion});
  }

  static void setResultPictureSize(int resultPictureSize) {
    _channel.invokeMethod(
        "setResultPictureSize", {"resultPictureSize": resultPictureSize});
  }

  static void bindUser(String userId) {
    _channel.invokeMethod("bindUser", {"userId": userId});
  }

  static get getSDKVersion async {
    return await _channel.invokeMethod("getSDKVersion");
  }

  static get getLatestDetectionResult async {
    return await _channel.invokeMethod("getLatestDetectionResult");
  }
}
