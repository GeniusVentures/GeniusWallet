import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class GeniusBreakpoints {
  /// Max width for a small layout.
  static const double small = 760;

  static const double tablet = 1200;

  /// Max width for a medium layout.
  static const double medium = 1644;

  /// Max width for a large layout.
  static const double large = 1920;

  static bool useDesktopLayout(BuildContext context) {
    return MediaQuery.of(context).size.width > small && !isMobileApp();
  }

  static bool useDesktopOverlay(BuildContext context) {
    return MediaQuery.of(context).size.width > tablet && !isMobileApp();
  }

  static bool isNativeApp(BuildContext context) {
    return getPlaform(context) == Platforms.mobile;
  }

  static Platforms getPlaform(BuildContext context) {
    if (kIsWeb) {
      return MediaQuery.of(context).size.width >= small
          ? Platforms.desktop
          : Platforms.mobile;
    } else {
      return isMobileApp() ? Platforms.mobile : Platforms.desktop;
    }
  }

  static bool isMobileApp() => Platform.isAndroid || Platform.isIOS;
}

enum Platforms {
  mobile,
  desktop,
}
