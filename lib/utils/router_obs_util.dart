


import 'package:flutter/widgets.dart';

/// 路由监听工具
/// 需要在APP 的 navigatorObservers 下添加该对象
class RouterObsUtil extends NavigatorObserver{

  static  RouterObsUtil _instance = RouterObsUtil._();


  factory RouterObsUtil(){
    return _instance;
  }
  static RouterObsUtil get(){
     return _instance;
  }

  RouterObsUtil._();

  @optionalTypeArgs
  Future<T> push<T extends Object>(Route<T> route) {
    return navigator.push(route);
  }

  @optionalTypeArgs
  Future<T> pushAndRemoveUntil<T extends Object>(Route<T> newRoute, RoutePredicate predicate) {
    return navigator.pushAndRemoveUntil(newRoute, predicate);
  }

  @optionalTypeArgs
  Future<T> pushNamed<T extends Object>(
      String routeName, {
        Object arguments,
      }) {
    return navigator.pushNamed(routeName, arguments:arguments);
  }

  @optionalTypeArgs
  Future<T> pushNamedAndRemoveUntil<T extends Object>(
      String newRouteName,
      RoutePredicate predicate, {
        Object arguments,
      }) {
    return navigator.pushNamedAndRemoveUntil(newRouteName, predicate, arguments:arguments);
  }

  @optionalTypeArgs
  Future<T> pushReplacement<T extends Object, TO extends Object>(Route<T> newRoute, { TO result }) {
    return navigator.pushReplacement(newRoute, result:result);
  }


  @optionalTypeArgs
  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
      String routeName, {
        TO result,
        Object arguments,
      }) {
    return navigator.pushReplacementNamed(routeName, arguments: arguments, result:result);
  }


  BuildContext get overlayContext => navigator.overlay.context;

  BuildContext get context => navigator.context;


  void popUntil(RoutePredicate predicate) {
    return navigator.popUntil(predicate);
  }


  void removeRoute(Route<dynamic> route) {
    return navigator.removeRoute(route);
  }


  bool canPop() {
    return navigator.canPop();
  }

  @optionalTypeArgs
  Future<bool> maybePop<T extends Object>([ T result ]) async {
    return navigator.maybePop(result);
  }


  @optionalTypeArgs
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
      String routeName, {
        TO result,
        Object arguments,
      }) {
    return navigator.popAndPushNamed(routeName,arguments: arguments ,result:result);
  }

}