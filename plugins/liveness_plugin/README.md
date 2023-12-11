# liveness_plugin 活体检测插件说明

### 使用参考
具体使用可以参考 example -> lib - main.dart 文件

#### 1、引用
pubspec.yaml 文件引用:

```yaml
liveness_plugin:
    path: 文件路径/liveness_plugin
```

dart 文件引用:
```dart
import 'package:liveness_plugin/liveness_plugin.dart';
```

#### 2、初始化
```dart
LivenessPlugin.initSDK2(
      "accessKey 对应的KEY",
      "secretKey 对应的KEY",
      "market 对应的数据",
    );
```

#### 3、执行SDK方法
```dart
LivenessPlugin.startLivenessDetection(this);
```

#### 4、SDK执行回调实现
```dart
class 对应类 implements LivenessDetectionCallback 
```

```dart
  ///
  /// sdk 执行成功回调
  /// isSuccess 识别结果
  /// map 里面包含livenessId, base64Image
  ///
  @override
  void onGetDetectionResult(bool isSuccess, Map? resultMap) {
    print('活体检测返回结果= $isSuccess, map = $resultMap');
  }
```

