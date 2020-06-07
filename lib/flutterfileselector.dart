import 'dart:async';

import 'package:flutter/services.dart';

class Flutterfileselector {
  static const MethodChannel _channel =
      const MethodChannel('flutterfileselector');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
