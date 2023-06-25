import 'dart:developer';

import 'package:flutter/services.dart';

class BackgroundServices {
  static const platform = MethodChannel('samples.flutter.dev/HGlove');

  static Future enableNotificationService() async {
    try {
      await platform.invokeMethod("login");
    } on PlatformException catch (e) {
      log("${e.message}");
    }
  }

  static Future disableNotificationService() async {
    try {
      print("looooooogout");
      await platform.invokeMethod("logOut");
    } on PlatformException catch (e) {
      log("${e.message}");
    }
  }
}
