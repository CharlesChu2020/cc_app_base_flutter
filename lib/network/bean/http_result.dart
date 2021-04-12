/// Http 结果Bean
class HttpResult<T>{
  bool success;
  T bean;
  String message;
  int httpCode;

  HttpResult(this.success, this.bean,[this.message,this.httpCode]);
}