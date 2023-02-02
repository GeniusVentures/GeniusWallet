import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class GeniusBreakpoints {
  /// Max width for a small layout.
  static const double small = 760;

  /// Max width for a medium layout.
  static const double medium = 1644;

  /// Max width for a large layout.
  static const double large = 1920;

  static bool useDesktopLayout(BuildContext context) {
    return MediaQuery.of(context).size.width > small;
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
