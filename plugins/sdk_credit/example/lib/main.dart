import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sdk_credit/sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SdkPlugin _tSdkPlugin;

  @override
  void initState() {
    super.initState();
    _tSdkPlugin = SdkPlugin(
      sdkSuccess: (String path, String md5, String orderNo, bool isSubmit, String json) {
        // 做文件上传 3次上传
        print('SDK 获取信息成功！path = $path, md5 = $md5, orderNo = $orderNo, isSubmit = $isSubmit, json = $json');
        setState(() {
          info.add('SDK执行结束... ${DateTime.now()} SDK 获取信息成功！path = $path, md5 = $md5, orderNo = $orderNo, isSubmit = $isSubmit, json = $json');
        });
      },
      sdkError: (String orderNo, String json, bool isSubmit) {
        // SDK 上传失败
        print('SDK 获取信息失败！orderNo = $orderNo, json = $json, isSubmit = $isSubmit');
        setState(() {
          info.add('SDK执行结束... ${DateTime.now()} SDK 获取信息失败！orderNo = $orderNo, json = $json, isSubmit = $isSubmit');
        });
      },
      afEvent: (String eventName) {
        // AF 打点
        print('${DateTime.now()} AF打点 === $eventName');
      },
    );
  }

  int orderId = 0;
  bool isSubmit = false;
  List<String> info = [];

  ///
  /// 调用SDK
  ///
  onCallSDK() {
    final call = {
      "action": "timeSDK",
      "id": "0.6656999111432877",
      "data": {
        "orderNo": "0a729c8f-f434-4232-96c4-$orderId",
        "userId": "1423538032933470208",
        "isSubmit": isSubmit,
        "appList": false,
        "sms": false,
        "exif": false,
        "device": false,
        "contact": false,
        "location": false
      },
      "callback": "webViewToTime"
    };
    setState(() {
      info.add('SDK开始执行... ${DateTime.now()}');
    });

    _tSdkPlugin.exec(jsonEncode(call));
  }

  updateSubmit() {
    setState(() {
      isSubmit = !isSubmit;
    });
  }

  onCallDiffOrderSDK() {
    orderId++;
    final call = {
      "action": "timeSDK",
      "id": "0.6656999111432877",
      "data": {
        "orderNo": "0a729c8f-f434-4232-96c4-$orderId",
        "userId": "1423538032933470208",
        "isSubmit": isSubmit,
        "appList": false,
        "sms": false,
        "exif": false,
        "device": false,
        "contact": false,
        "location": false
      },
      "callback": "webViewToTime"
    };
    _tSdkPlugin.exec(jsonEncode(call));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 300,
                  child: Column(
                    children: [
                      const Text('信息显示:'),
                      Expanded(
                        child: ListView.builder(
                          itemCount: info.length,
                          // itemExtent: 50,
                          itemBuilder: (BuildContext context, int index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(info[index]),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MaterialButton(
                      child: Text('执行SDK 不同订单号'),
                      onPressed: () => onCallDiffOrderSDK(),
                      color: Colors.blueAccent,
                    ),
                    MaterialButton(
                      child: Text('执行SDK 相同订单号'),
                      onPressed: () => onCallSDK(),
                      color: Colors.blueAccent,
                    ),
                    MaterialButton(
                      child: Text('修改isSubmit = $isSubmit'),
                      onPressed: () => updateSubmit(),
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Center(
//             child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 String? installs = await SdkPlugin().getAppList();
//                 log('installs: $installs');
//               },
//               child: Text('getInstalls'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 String? getCollect = await SdkPlugin().getContact();
//                 log('getCollect: $getCollect');
//               },
//               child: Text('getCollect'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 String? getDetail = await SdkPlugin().getDevice();
//                 log('getDetail: $getDetail');
//               },
//               child: Text('getDetail'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 String? getGraph = await SdkPlugin().getPhoto();
//                 log('getGraph: $getGraph');
//               },
//               child: Text('getGraph'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 String? getLetter = await SdkPlugin().getSms();
//                 log('getLetter: $getLetter');
//               },
//               child: Text('getLetter'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final permissions = [
//                   Permission.phone,
//                   Permission.location,
//                   Permission.sms,
//                   Permission.contacts,
//                   Permission.camera,
//                 ];
//                 await permissions.request();
//               },
//               child: Text('Permission'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 String? installs = await SdkPlugin().getAppList();
//                 log('installs: $installs');
//                 String? getCollect = await SdkPlugin().getContact();
//                 log('getCollect: $getCollect');
//                 String? getDetail = await SdkPlugin().getDevice();
//                 log('getDetail: $getDetail');
//                 String? getGraph = await SdkPlugin().getPhoto();
//                 log('getGraph: $getGraph');
//                 String? getLetter = await SdkPlugin().getSms();
//                 log('getLetter: $getLetter');
//               },
//               child: Text('getAll'),
//             ),
//           ],
//         )),
//       ),
//     );
//   }
// }
