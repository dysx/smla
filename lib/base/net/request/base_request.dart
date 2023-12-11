import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:retry/retry.dart';

import '../api_response.dart';
import '../dio_helper.dart';
import 'constants.dart';
import 'http_error.dart';

/// 数据解析回调
typedef JsonParse<T> = T Function(dynamic data);

enum RequestType {
  get,
  post,
  upload,
}

abstract class BaseRequest {
  String getBaseUrl(); // 默认的base url

  void _setBaseUrl() => DioHelper.instance.setBaseUrl(getBaseUrl());

  /// 请求前操作
  Future _preRequest() async {
    //检查网络是否连接
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw NetworkError();
    }
    _setBaseUrl();
    DioHelper.instance.enableLog();
  }

  /// ### post 请求
  /// [baseUrl] 域名 （第一优先级的base url）
  /// [path] 请求地址（不包括域名）
  /// [data] 请求参数，类型不定
  /// [queryParameters] 查询参数
  /// [headers] 请求头
  /// [jsonParse] json解析，不为空返回解析后的结果
  Future<T> doPost<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    JsonParse<T>? jsonParse,
    Map<String, dynamic>? headers,
    String cancelTag = cancelTagDefault,
  }) async {
    return _requestWithRetry(
      path: path,
      data: data,
      queryParameters: queryParameters,
      jsonParse: jsonParse,
      headers: headers,
      cancelTag: cancelTag,
      requestType: RequestType.post,
    );
  }

  /// ### get 请求
  /// [baseUrl] 域名
  /// [path] 请求地址（不包括域名）
  /// [queryParameters] 查询参数
  /// [jsonParse] json解析，不为空返回解析后的结果
  Future<T> doGet<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    JsonParse<T>? jsonParse,
    Map<String, dynamic>? headers,
    String cancelTag = cancelTagDefault,
  }) async {
    return _requestWithRetry(
      path: path,
      queryParameters: queryParameters,
      jsonParse: jsonParse,
      headers: headers,
      cancelTag: cancelTag,
      requestType: RequestType.get,
    );
  }

  /// ### upload 请求
  /// [baseUrl] 域名
  /// [path] 请求地址（不包括域名）
  /// [filePath] 文件地址
  /// [filename] 文件名称
  /// [queryParameters] 查询参数
  /// [jsonParse] json解析，不为空返回解析后的结果
  Future<T> doUpload<T>({
    required String path,
    required List<String> filePaths,
    List<MapEntry<String, String>>? mapEntrys,
    String? queryFileFieldName,
    List<String>? fileNames,
    Map<String, dynamic>? queryParameters,
    JsonParse<T>? jsonParse,
    Map<String, dynamic>? headers,
    String cancelTag = cancelTagDefault,
  }) async {
    return _requestWithRetry(
      path: path,
      filePaths: filePaths,
      mapEntrys: mapEntrys,
      queryFileFieldName: queryFileFieldName,
      fileNames: fileNames,
      queryParameters: queryParameters,
      jsonParse: jsonParse,
      headers: headers,
      cancelTag: cancelTag,
      requestType: RequestType.upload,
    );
  }

  /// 请求
  Future<T> _requestWithRetry<T>({
    required String path,
    dynamic data,
    List<String>? filePaths,
    String? savePath,
    String? queryFileFieldName,
    List<MapEntry<String, String>>? mapEntrys,
    List<String>? fileNames,
    Map<String, dynamic>? queryParameters,
    JsonParse<T>? jsonParse,
    Map<String, dynamic>? headers,
    String cancelTag = cancelTagDefault,
    RequestType requestType = RequestType.post,
    ProgressCallback? onReceiveProgress,
  }) async {
    /// 请求
    return _request(
      path: path,
      data: data,
      filePaths: filePaths,
      savePath: savePath,
      queryFileFieldName: queryFileFieldName,
      mapEntrys: mapEntrys,
      fileNames: fileNames,
      queryParameters: queryParameters,
      jsonParse: jsonParse,
      headers: headers,
      cancelTag: cancelTag,
      requestType: requestType,
      onReceiveProgress: onReceiveProgress,
    );

    // 最多请求5次
    // 时间间隔，0，500ms，750ms，1s，1.5s
    const r = RetryOptions(
        delayFactor: Duration(milliseconds: 500), maxAttempts: 5, randomizationFactor: 0.5);
    return r.retry(
      () async {
        /// 请求
        return _request(
          path: path,
          data: data,
          filePaths: filePaths,
          savePath: savePath,
          queryFileFieldName: queryFileFieldName,
          mapEntrys: mapEntrys,
          fileNames: fileNames,
          queryParameters: queryParameters,
          jsonParse: jsonParse,
          headers: headers,
          cancelTag: cancelTag,
          requestType: requestType,
          onReceiveProgress: onReceiveProgress,
        );
      },
      // 重新请求条件
      retryIf: (Exception e) => e is NetworkError,
    );
  }

  /// 请求
  Future<T> _request<T>({
    required String path,
    dynamic data,
    List<String>? filePaths,
    String? savePath,
    String? queryFileFieldName,
    List<MapEntry<String, String>>? mapEntrys,
    List<String>? fileNames,
    Map<String, dynamic>? queryParameters,
    JsonParse<T>? jsonParse,
    Map<String, dynamic>? headers,
    String cancelTag = cancelTagDefault,
    RequestType requestType = RequestType.post,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // 判断网络状态
      await _preRequest();

      path = "${getBaseUrl()}$path";

      // 请求
      ApiResponse response;
      headers = await _generateHeaders(headers);

      switch (requestType) {
        case RequestType.get:
          response = await DioHelper.instance.get(
            path: path,
            queryParameters: queryParameters,
            headers: headers,
            cancelTag: cancelTag,
          );
          break;
        case RequestType.post:
          response = await DioHelper.instance.post(
            path: path,
            data: data,
            queryParameters: queryParameters,
            headers: headers,
            cancelTag: cancelTag,
          );
          break;
        case RequestType.upload:
          response = await DioHelper.instance.upload(
            path: path,
            filePaths: filePaths ?? [],
            mapEntrys: mapEntrys,
            queryFileFieldName: queryFileFieldName,
            fileNames: fileNames,
            headers: headers,
            queryParameters: queryParameters,
            cancelTag: cancelTag,
          );
          break;
        // case RequestType.download:
        //   response = await DioHelper.instance.downloadFile(
        //       baseUrl: baseUrl,
        //       urlPath: path,
        //       savePath: savePath ?? '',
        //       headers: headers,
        //       cancelTag: cancelTag,
        //       onReceiveProgress: onReceiveProgress);
        //   break;
      }

      return _handleResponse(response, jsonParse: jsonParse);
    } on HttpError {
      throw NetworkError();
    } on DioException catch (e) {
      int code = statusCodeUnknown;
      String message = statusMessageUnknown;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.unknown) {
        throw NetworkError();
      } else {
        code = e.response?.statusCode ?? statusCodeUnknown;
        message = e.response?.statusMessage ?? statusMessageUnknown;
      }
      throw HttpError(
        code,
        statusMessage: message,
        responseCode: code,
        responseMessage: message,
        data: e,
      );
    } catch (e) {
      throw HttpError(statusCodeUnknown, statusMessage: e.toString(), data: e.toString());
    }
  }

  /// 处理响应
  Future<T> _handleResponse<T>(
    ApiResponse response, {
    JsonParse<T>? jsonParse,
  }) async {
    int? statusCode = response.statusCode;

    int? responseCode = response.data["code"];
    var responseData = response.data["data"];
    var responseMessage = response.data["msg"];

    if (statusCode == statusCodeSuccess && responseCode == responseCodeSuccess) {
      // 请求正常 并且 业务正常
      if (jsonParse != null && responseData != null) {
        // 1.需要json解析则解析之后返回
        return jsonParse(responseData);
      } else {
        // 2.不需要解析则整个对象返回
        return responseData;
      }
    }
    // 失败：
    // 可以封装业务通用异常，如需要权限或者需要登录，
    throw HttpError(
      statusCode ?? statusCodeUnknown,
      statusMessage: response.statusMessage,
      responseCode: responseCode,
      responseMessage: responseMessage,
      data: response.data,
    );
  }

  /// ### 生成公共请求头
  Future<Map<String, dynamic>> _generateHeaders(Map<String, dynamic>? headers) async {
    Map<String, dynamic> result = headers ?? {};
    // 拼接公共请求头
    result.addAll(await getRequestCommonHeaders());
    return result;
  }

  /// ### 公共请求头
  Future<Map<String, dynamic>> getRequestCommonHeaders() async => {};

  /// ### 请求公参
  Future<Map<String, dynamic>> getRequestCommonParam() async => {};
}
