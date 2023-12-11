import 'dart:convert';

/// 统一网络层返回格式
class ApiResponse<T> {
  // 响应体
  T? data;

  // 请求路径
  String? requestPath;

  // 状态码
  int? statusCode;

  String? statusMessage;

  // 额外信息
  dynamic extra;

  ApiResponse({
    this.data,
    this.requestPath,
    this.statusCode,
    this.statusMessage,
    this.extra,
  });

  @override
  String toString() {
    if (data is Map) {
      return json.encode(data);
    } else {
      return data.toString();
    }
  }
}
