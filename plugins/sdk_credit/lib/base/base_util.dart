
import '../sdk.dart';

abstract class BaseUtil {
  ///
  /// 获取数据
  ///
  Future<String?> exec(AfEvent? afEvent, {bool isSubmit = false});

}