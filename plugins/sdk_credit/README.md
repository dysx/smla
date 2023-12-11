# 六合一 SDK 插件说明

### 使用参考
具体使用可以参考 example -> lib - main.dart 文件

#### 1、引用
pubspec.yaml 文件引用:

```yaml
sdk_credit:
    path: 文件路径/sdk_credit
```

dart 文件引用:
```dart
import 'package:sdk_credit/sdk.dart';
```

#### 2、初始化


在 initState 方法中初始化:
```dart
// 风控数据SDK对象
late SdkPlugin _tSdkPlugin;

@override
  void initState() {
    super.initState();
    _tSdkPlugin = SdkPlugin(
      // sdk 获取数据成功回调
      sdkSuccess: (String path, String md5, String orderNo, bool isSubmit, String json) {
        // 做文件上传 
        // 1、如果isSubmit == true, 上传成功则回调H5事件成功
        // 2、如果isSubmit == true, 上传失败则进行3次重试，如果还是失败则回调H5失败
        print('SDK 获取信息成功！path = $path, md5 = $md5, orderNo = $orderNo, isSubmit = $isSubmit, json = $json');
        
      },
      // sdk 获取数据失败回调
      sdkError: (String orderNo, String json, bool isSubmit) {
        print('SDK 获取信息失败！orderNo = $orderNo, json = $json, isSubmit = $isSubmit');
        // 1、只有isSubmit == true, 才进行回调H5失败
      },
      // AF 事件埋点回调
      afEvent: (String eventName) {
        // 进行AF埋点
        print('事件名 = $eventName');
      },
    );
  }
```
SDK成功和失败方法需要注意isSubmit的参数，上面用例代码有注释说明。

#### 3、执行SDK方法
```dart
  // 调用风控数据SDK进行数据收集的方法
  _tSdkPlugin.exec("json字符串");
```
参数格式(仅用参考，具体是使用H5事件回调的真实数据)：
```json
{
    "action": "timeSDK",
    "id": "0.6656999111432877",
    "data": {
        "orderNo": "0a729c8f-f434-4232-96c4-$orderId",
        "userId": "1423538032933470208",
        "isSubmit": true,
        "appList": false,
        "sms": false,
        "exif": false,
        "device": false,
        "contact": false,
        "location": false
    },
    "callback": "webViewToTime"
}
```
