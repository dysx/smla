import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liveness_plugin/liveness_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements LivenessDetectionCallback {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 初始化SDK
  void _initLiveness() {
    LivenessPlugin.initSDK2(
      "54e03a28ec301bb8",
      "36181f76c174e848",
      "mex",
    );
  }

  /// 调用人脸识别
  void _startLivenessDetection() async {
    var cameraPermissionState = await Permission.camera.request();
    if (cameraPermissionState.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: '没权限');
    } else {
      LivenessPlugin.startLivenessDetection(this);
    }
  }

  ///
  /// sdk 执行成功回调
  /// isSuccess 识别结果
  /// map 里面包含livenessId, base64Image
  ///
  @override
  void onGetDetectionResult(bool isSuccess, Map? resultMap) {
    print('活体检测返回结果= $isSuccess, map = $resultMap');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () => _initLiveness(),
                child: const Text('初始化SDK'),
              ),
              MaterialButton(
                onPressed: () => _startLivenessDetection(),
                child: const Text('调用SDK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
