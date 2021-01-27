import 'package:flutter/services.dart';

/// 公共持久类
class  Comm{
  /// todo:  包名
  static const String PACKNAME = "flutterfileselector";
  /// todo:  原生交互通道
  static const MethodChannel CHANNEL = const MethodChannel('flutterfileselector');
  static const String GET_FILE = "GET_FILE";
  static const String TYPE = "TYPE";
}
