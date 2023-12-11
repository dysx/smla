import 'package:SmartLoan/base/net/encrypt_interceptor.dart';
import 'package:SmartLoan/models/Login_data_model.dart';
import 'package:SmartLoan/models/New_version_model.dart';
import 'package:SmartLoan/models/verify_code_model.dart';
import 'package:SmartLoan/request/apis.dart';
import 'package:SmartLoan/util/plat_form_utils.dart';
import 'package:dio/dio.dart';

import 'base_service.dart';

class RequestService extends BaseService {
  RequestService._();

  static final RequestService _instance = RequestService._();

  static RequestService get instance => _instance;

  factory RequestService() => _instance;

  /// 检查手机号
  Future<bool> existsByMobile({required String mobile}) async {
    if (EncryptInterceptor.encryptSwitch) {
      return await doPost(
        path: Apis.existsByMobile,
        data: {'mobile': mobile},
        jsonParse: (data) => data['existed'],
      );
    } else {
      return await doGet(
        path: Apis.existsByMobile,
        queryParameters: {'mobile': mobile},
        jsonParse: (data) => data['existed'],
      );
    }
  }

  /// 获取验证码
  /// [type]Int  1-登录 2-注册 3-重置密码 5验证银行卡号码
  /// [notifyType]Int    短信1，语音2
  Future<VerifyCodeModel> getVerifyCode({
    required String mobile,
    required int type,
    int? notifyType,
  }) async {
    return await doPost(
      path: Apis.getVerifyCode,
      data: {
        "mobile": mobile,
        "type": type,
        "notifyType": notifyType ?? 1,
        "androidId": PlatFormUtils().androidId,
        "versionCode": PlatFormUtils().buildNumber,
      },
      jsonParse: (data) => VerifyCodeModel.fromJson(data),
    );
  }

  /// 注册
  /// [mobile] | string手机号码
  /// [verifyCode] | String 验证码
  /// [verified] Boolean 是否手动输入验证码，是：true，自动登录为否：falseBoolean 是否手动输入验证码，是：true，自动登录为否：false
  Future<LoginDataModel> register({
    required String mobile,
    required String verifyCode,
    required bool verified,
  }) async {
    return await doPost(
      path: Apis.register,
      data: {
        "mobile": mobile,
        "verifyCode": verifyCode,
        "verified": verified,
        "installReferce": PlatFormUtils().installRefer,
        "adrVersion": PlatFormUtils().adrVersion,
        "androidId": PlatFormUtils().androidId,
        "appVersion": PlatFormUtils().appVersion,
        "channelId": PlatFormUtils().channelId,
        "packageName": PlatFormUtils().packageName,
      },
      jsonParse: (data) => LoginDataModel.fromJson(data),
    );
  }

  /// 登录
  /// [mobile] | string手机号码
  /// [verifyCode] | String 验证码
  /// [verified] Boolean 是否手动输入验证码，是：true，自动登录为否：falseBoolean 是否手动输入验证码，是：true，自动登录为否：false
  Future<LoginDataModel> loginCode({
    required String mobile,
    required String verifyCode,
    required bool verified,
  }) async {

    Map<String,dynamic> params = {
      "mobile": mobile,
      "verifyCode": verifyCode,
      "verified": verified,
      "installReferce": PlatFormUtils().installRefer,
      "appName": PlatFormUtils().appName,
      "adrVersion": PlatFormUtils().adrVersion,
      "appVersion": PlatFormUtils().appVersion,
      "channelId": PlatFormUtils().channelId,
      "packageName": PlatFormUtils().packageName,
      "androidId": PlatFormUtils().androidId,
    };

    return await doPost(
      path: Apis.loginCode,
      data: EncryptInterceptor.encryptSwitch ? params : FormData.fromMap(params),
      jsonParse: (data) => LoginDataModel.fromJson(data),
    );
  }

  /// 上传设备信息（第一次打开app信息）（激活接口）
  Future<bool> addActive() async {
    return await doPost(
      path: Apis.addActive,
      data: {
        "installReferce": PlatFormUtils().installRefer,
        "afId": PlatFormUtils().afId,
        "adrVersion": PlatFormUtils().adrVersion,
        "appVersion": PlatFormUtils().appVersion,
        "androidId": PlatFormUtils().androidId,
        "packageName": PlatFormUtils().packageName,
        "appName": PlatFormUtils().appName,
        "channelId": PlatFormUtils().channelId,
      },
      // Boolean 是否上传成功
      jsonParse: (data) => data,
    );
  }

  /// 检测app版本信息
  Future<NewVersionModel> getNewVersion({required String packageName}) async {
    if (EncryptInterceptor.encryptSwitch) {
      return await doPost(
        path: Apis.getNewVersion,
        data: {"packageName": PlatFormUtils().packageName},
        jsonParse: (data) => NewVersionModel.fromJson(data),
      );
    } else {
      return await doGet(
        path: Apis.getNewVersion,
        queryParameters: {"packageName": PlatFormUtils().packageName},
        jsonParse: (data) => NewVersionModel.fromJson(data),
      );
    }
  }

  /// Log 日志信息上传
  // Future<bool> uploadLog({
  // }) async {
  // }

  /// 六合一sdk 上传zip
  /// [md5] String 文件MD5
  /// [orderNo] string
  /// [file] | zip文件
  Future<bool> uploadFile({
    // required String md5,
    // required String orderNo,
    required List<MapEntry<String, String>> mapEntrys,
    required String file,
  }) async {
    return await doUpload(
      path: Apis.uploadFile,
      queryFileFieldName: 'file',
      filePaths: [file],
      mapEntrys: mapEntrys,
      // mapEntrys: [
      //   MapEntry("md5", md5),
      //   MapEntry("orderNo", orderNo),
      // ],
    );
  }
}
