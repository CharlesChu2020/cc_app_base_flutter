import 'package:dio/dio.dart';

import 'bean/http_result.dart';
import 'entity/http_err_hint.dart';

typedef BeanFromJsonCallBack<T> = T Function(dynamic data);

class HttpUtil {
  static HttpUtil _instance;
  Dio _dio = Dio();
  String _token;

  factory HttpUtil() {
    _instance ??= HttpUtil();
    return _instance;
  }

  /// 赋值token
  set token(String value) {
    _token = value;
  }

  /// 初始化， 必须调用
  void init(String baseUrl,
      {int connectTimeout = 5000,
      int receiveTimeout = 15000,
      String contentType = Headers.jsonContentType,
      ResponseType responseType = ResponseType.json}) {
    _dio.options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        contentType: contentType,
        responseType: responseType);
  }

  /// 普通post请求
  Future<HttpResult> post<T>(
    String path,
    BeanFromJsonCallBack<T> beanFromJsonCallBack, {
    dynamic data,
    Map<String, dynamic> queryParameters,
  }) async {
    try {
      final result =
          await _dio.post(path, data: data, queryParameters: queryParameters);
      return HttpResult<T>(
          true, beanFromJsonCallBack(result.data), result.statusMessage,result.statusCode);
    } on DioError catch (err) {
      return errCatch(err);
    }
  }

  /// 普通get请求
  Future<HttpResult> get<T>(
      String path, BeanFromJsonCallBack<T> beanFromJsonCallBack,
      {Map<String, dynamic> queryParameters}) async {
    try {
      final result =
          await _dio.get<Map>(path, queryParameters: queryParameters);
      return HttpResult<T>(
          true, beanFromJsonCallBack(result.data), result.statusMessage,result.statusCode);
    } on DioError catch (err) {
      return errCatch(err);
    }
  }

  /// 异常处理
  /// TODO: 将和后端返回异常进行整合
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
    return HttpResult(false, null, hint,error.response.statusCode);
  }
}
