import 'package:SmartLoan/util/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:liveness_plugin/liveness_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../res/app_str_toast.dart';
import 'js_channel.dart';

// liveness
class LivenessChannel extends JsChannel implements LivenessDetectionCallback {

  @override
  List<String> get actions => ['getAccuauthSDK'];

  @override
  onReceive(Map newMsg) async {
    var permissionStatus = await Permission.camera.request();
    if (permissionStatus.isPermanentlyDenied) {
      AppStrToast.permissionAsk.showToast();
      return;
    }else if(permissionStatus.isDenied){
      return;
    }

    LivenessPlugin.initSDK2(
      "54e03a28ec301bb8",
      "36181f76c174e848",
      "mex",
    );
    LivenessPlugin.startLivenessDetection(this);
  }

  @override
  void onGetDetectionResult(bool isSuccess, Map? resultMap) {

    if (isSuccess) {
      h5CallBack({
        'livenessId': resultMap?['livenessId'],
        'file': resultMap?['base64Image']
      }, isOk: isSuccess);
    } else {
      if (resultMap?['message'] != null) {
        h5CallBack({
          'errorMsg': resultMap?['message']
        }, isOk: isSuccess);
      }
    }

  }

}