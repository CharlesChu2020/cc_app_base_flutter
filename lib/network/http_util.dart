import 'package:dio/dio.dart';

import 'bean/http_result.dart';
import 'entity/http_err_hint.dart';

/// json转bean的方法
typedef BeanFromJsonFunction<T> = T Function(Map<String, dynamic> data);

/// 结果统一处理回掉
typedef ResultCallBack = HttpResult Function(bool success, Map data, BeanFromJsonFunction fromJsonFunction, [int statusCode, String hint]);

/// 开始请求统一处理回掉
typedef RequestCallBack = void Function(dynamic flag);

class HttpUtil {
  static HttpUtil _instance;
  Dio _dio = Dio();
  String _token;
  String _tokenKey;
  ResultCallBack resultCallBack;
  RequestCallBack requestCallBack;

  factory HttpUtil() {
    _instance ??= HttpUtil._internal();
    return _instance;
  }

  HttpUtil._internal();

  /// 赋值token
  set token(String value) {
    _token = value;
  }

  /// 初始化， 必须调用
  void init(String baseUrl, String tokenKey,
      {int connectTimeout = 5000,
        int receiveTimeout = 15000,
        String contentType = Headers.jsonContentType,
        ResponseType responseType = ResponseType.json}) {
    _tokenKey = tokenKey;
    _dio.options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        contentType: contentType,
        responseType: responseType);
  }

  /// 所有请求结果返回前都会走的回掉
  void httpResultHandler(ResultCallBack callBack) {
    resultCallBack = callBack;
  }

  /// 所有请求前都会走的回掉
  void httpRequestHandler(RequestCallBack callBack) {
    requestCallBack = callBack;
  }

  /// 普通post请求
  Future<HttpResult> post<T>(String path,
      BeanFromJsonFunction<T> fromJsonFunction,
      {bool withToken = true,
        dynamic data,
        Map<String, dynamic> queryParameters,
        dynamic flag}) async {
    try {
      print('path: $path');
      print('queryParameters: $queryParameters');
      print('data: $data');
      requestCallBack?.call(flag);
      final result = await _dio.post<Map<String, dynamic>>(path,
          data: data,
          queryParameters: queryParameters,
          options: _getOptions(withToken));
      return _resultProcessing(result, fromJsonFunction);
    } on DioError catch (err) {
      return errCatch(err);
    }
  }

  /// 普通get请求
  Future<HttpResult> get<T>(String path,
      BeanFromJsonFunction<T> fromJsonFunction,
      {Map<String, dynamic> queryParameters,
        bool withToken = true,
        dynamic flag}) async {
    try {
      print('path: $path');
      print('queryParameters: $queryParameters');
      requestCallBack?.call(flag);
      final result = await _dio.get<Map>(path,
          queryParameters: queryParameters, options: _getOptions(withToken));
      return _resultProcessing(result, fromJsonFunction);
    } on DioError catch (err) {
      return errCatch(err);
    }
  }

  /// post 文件
  Future<HttpResult> postFile<T>(String path,
      BeanFromJsonFunction<T> fromJsonFunction, String fileKey, String filePath,
      {bool withToken = true,
        Map<String, dynamic> data,
        Map<String, dynamic> queryParameters,
        dynamic flag}) async {
    data ??= {};
    final multipartFile = await MultipartFile.fromFile(filePath,
        filename: filePath
            .split("/")
            .last);
    data[fileKey] = multipartFile;
    ///通过FormData
    FormData formData = FormData.fromMap(data);

    try {
      requestCallBack?.call(flag);
      final result = await _dio.post<Map<String, dynamic>>(path,
          data: formData,
          queryParameters: queryParameters,
          options: _getOptions(withToken));
      return _resultProcessing(result, fromJsonFunction);
    } on DioError catch (err) {
      return errCatch(err);
    }
  }

  /// 结果处理
  HttpResult _resultProcessing(Response result,
      BeanFromJsonFunction fromJsonFunction) =>
      resultCallBack?.call(true, result.data, fromJsonFunction);

  /// 配置Options
  Options _getOptions(bool withToken) {
    if (withToken) {
      return Options(headers: {_tokenKey: _token});
    } else {
      return Options();
    }
  }

  /// 异常处理
  HttpResult errCatch(DioError error) {
    String hint;
    switch (error.type) {
      case DioErrorType.connectTimeout:
        hint = HttpErrHint.connectTimeout;
        break;
      case DioErrorType.sendTimeout:
        hint = HttpErrHint.sendTimeout;
        break;
      case DioErrorType.receiveTimeout:
        hint = HttpErrHint.receiveTimeout;
        break;
      case DioErrorType.response:
        hint = HttpErrHint.response;
        break;
      case DioErrorType.cancel:
        hint = HttpErrHint.cancel;
        break;
      case DioErrorType.other:
        hint = HttpErrHint.other;
        break;
    }
    print("http err----------: ${error.message}");
    return resultCallBack?.call(false, error?.response?.data ?? {}, null,
        error?.response?.statusCode ?? 999, hint);
  }
}
