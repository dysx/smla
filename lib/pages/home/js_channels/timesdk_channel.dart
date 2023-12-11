import 'dart:convert';
import 'package:SmartLoan/base/net/encrypt_interceptor.dart';
import 'package:SmartLoan/util/encypt_utils.dart';
import 'package:sdk_credit/sdk.dart';
import '../../../request/request_service.dart';
import '../../../util/plat_form_utils.dart';
import 'js_channel.dart';

// timeSDK
class TimeSdkChannel extends JsChannel {

  late SdkPlugin _tSdkPlugin;

  @override
  List<String> get actions => ['timeSDK'];

  @override
  onReceive(Map newMsg) {
    _tSdkPlugin = SdkPlugin(
      // sdk 获取数据成功回调
      sdkSuccess: (String path, String md5, String orderNo, bool isSubmit, String json) async {
        // 做文件上传
        // 1、如果isSubmit == true, 上传成功则回调H5事件成功
        // 2、如果isSubmit == true, 上传失败则进行3次重试，如果还是失败则回调H5失败
        print('SDK 获取信息成功！path = $path, md5 = $md5, orderNo = $orderNo, isSubmit = $isSubmit, json = $json');

        uploadSdkFile(path, md5, orderNo, path, isSubmit ? 3 : 1);
      },
      // sdk 获取数据失败回调
      sdkError: (String orderNo, String json, bool isSubmit) {
        print('SDK 获取信息失败！orderNo = $orderNo, json = $json, isSubmit = $isSubmit');
        // 1、只有isSubmit == true, 才进行回调H5失败
        if (isSubmit) {
          h5CallBack({}, isOk: false);
        }
      },
      // AF 事件埋点回调
      afEvent: (String eventName) {
        // 进行AF埋点
        print('事件名 = $eventName');
        PlatFormUtils().log(eventName);
      },
    );
    
    _tSdkPlugin.exec(jsonEncode(newMsg));
  }

  uploadSdkFile(String path, String md5, String orderNo, String filePath, int retry) async {
    Map<String, dynamic> params = {
      "md5": md5,
      "orderNo": orderNo,
      "encrypt": EncryptInterceptor.encryptSwitch,
    };

    List<MapEntry<String, String>> mapEntrys;
    if (EncryptInterceptor.encryptSwitch) {
      mapEntrys = [
        MapEntry("params", EncryptUtil().encrypt(json.encode(params))),
      ];
    } else {
      mapEntrys = [
        MapEntry("md5", md5),
        MapEntry("orderNo", orderNo),
      ];
    }

    try {
      bool uploadRes = await RequestService.instance.uploadFile(
        mapEntrys: mapEntrys,
        file: filePath
      );
    } on Exception catch (e) {
      // HttpErrorHelper.instance.showErrorDialog(error: e);
      retry--;
      if (retry > 0) {
        uploadSdkFile(path, md5, orderNo, filePath, retry);
      }
    }

  }

}