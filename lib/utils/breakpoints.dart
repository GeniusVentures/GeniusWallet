import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class GeniusBreakpoints {
  static const double small = 640;

  static const double medium = 768;

  static const double large = 1024;

  static const double xl = 1280;

  static const double xxl = 1536;

  static bool useDesktopLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).width > medium && !isMobileApp();
  }

  static bool useDesktopOverlay(BuildContext context) {
    return MediaQuery.sizeOf(context).width > large && !isMobileApp();
  }

  static bool isMobileApp() =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}

enum Platforms { mobile, desktop }
