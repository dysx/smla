import 'package:SmartLoan/base/net/encrypt_interceptor.dart';
import 'package:dio/dio.dart';

import '../../util/logger.dart';
import 'api_response.dart';
import 'log_interceptor.dart' as log;
import 'queued_interceptor.dart' as queued;

class DioHelper {
  factory DioHelper() => _instance;

  static DioHelper get instance => _instance;

  static final DioHelper _instance = DioHelper._();

  // 连接超时时间
  static const Duration CONNECT_TIMEOUT = Duration(milliseconds: 3000);

  // 发送超时时间
  static const Duration SEND_TIMEOUT = Duration(milliseconds: 20000);

  // 响应超时时间
  static const Duration RECEIVE_TIMEOUT = Duration(milliseconds: 40000);

  static const Duration kConnectTimeoutLong = Duration(milliseconds: 120000);
  static const Duration kReceiveTimeoutLong = Duration(milliseconds: 120000);

  // dio变量
  final Dio _dio = Dio();

  // 是否打开log
  bool _isEnableLog = false;

  /// 取消请求token map
  /// 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消
  /// 这里使用tag区分不同请求，可以只取消对应部分请求
  final Map<String, CancelToken> _cancelTokens = <String, CancelToken>{};

  /// 初始化
  DioHelper._() {
    Logger.dPrint("DioHelper 初始化");
    _dio.options.connectTimeout = CONNECT_TIMEOUT;
    _dio.options.sendTimeout = SEND_TIMEOUT;
    _dio.options.receiveTimeout = RECEIVE_TIMEOUT;
    _dio.interceptors.add(EncryptInterceptor());
    // _dio.interceptors.add(queued.QueuedInterceptor());
  }

  Dio get dio => _dio;

  /// 打开log
  void enableLog() {
    if (!_isEnableLog) {
      _isEnableLog = true;
      _dio.interceptors.add(log.LogInterceptor());
    }
  }

  /// 设置请求域名
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// ### get 请求
  /// [baseUrl] 域名
  /// [path] 请求地址（不包括域名）
  /// [queryParameters] 查询参数
  /// [headers] 请求头，覆盖dio原有配置
  /// return 统一的请求响应
  Future<ApiResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? cancelTag,
  }) async {
    Response response = await dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(headers: headers),
      cancelToken: _getCancelTokenByTag(cancelTag: cancelTag),
    );
    return _transform2ApiResponse(response);
  }

  /// ### post 请求
  /// [baseUrl] 域名
  /// [path] 请求地址（不包括域名）
  /// [data] 请求参数，类型不定
  /// [queryParameters] 查询参数
  /// [headers] 请求头，覆盖dio原有配置
  /// return 统一的请求响应
  Future<ApiResponse<T>> post<T>({
    // required String baseUrl,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? cancelTag,
  }) async {
    // Dio dio = _buildDio(baseUrl);

    Response response = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
      cancelToken: _getCancelTokenByTag(cancelTag: cancelTag),
    );

    return _transform2ApiResponse(response);
  }

  /// ### upload 请求
  /// [baseUrl] 域名
  /// [path] 请求地址（不包括域名）
  /// [filePath] 文件地址
  /// [filename] 文件名称
  /// [queryFileFieldName] 请求上传file的字段名
  /// [queryParameters] 查询参数
  /// [headers] 请求头，覆盖dio原有配置
  /// return 统一的请求响应
  /// 修改：修改成多文件上传
  Future<ApiResponse<T>> upload<T>({
    required String path,
    required List<String> filePaths,
    required List<String>? fileNames,
    String? queryFileFieldName,
    Map<String, dynamic>? queryParameters,
    List<MapEntry<String, String>>? mapEntrys,
    Map<String, dynamic>? headers,
    String? cancelTag,
  }) async {
    String queryName = queryFileFieldName ?? "multipartFile";

    bool fileNamesIsNull = fileNames == null || fileNames.isEmpty;
    FormData formData = FormData();
    for (int i = 0; i < filePaths.length; i++) {
      late String filename;
      if (fileNamesIsNull) {
        filename = filePaths[i].substring(filePaths[i].lastIndexOf("/") + 1, filePaths[i].length);
      }
      Logger.dPrint("文件名字: $filename");
      formData.files.add(MapEntry(queryName, await MultipartFile.fromFile(filePaths[i], filename: filename)));
    }
    if (mapEntrys != null) {
      formData.fields.addAll(mapEntrys);
    }

    Response response = await dio.post(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: Options(
        headers: headers,
        receiveTimeout: kReceiveTimeoutLong,
        sendTimeout: kConnectTimeoutLong,
      ),
      cancelToken: _getCancelTokenByTag(cancelTag: cancelTag),
    );

    return _transform2ApiResponse(response);
  }

  /// 将dio响应转换成项目封装的响应
  ApiResponse<T> _transform2ApiResponse<T>(Response response) {
    return ApiResponse(
      data: response.data,
      requestPath: response.requestOptions.path,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      extra: response.extra,
    );
  }

  /// ### 根据tag获取CancelToken
  CancelToken? _getCancelTokenByTag({String? cancelTag}) {
    if (cancelTag != null) {
      CancelToken cancelToken = _cancelTokens[cancelTag] == null ? CancelToken() : _cancelTokens[cancelTag]!;
      _cancelTokens[cancelTag] = cancelToken;
      return cancelToken;
    }
    return null;
  }
}
