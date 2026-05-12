import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class GeniusBreakpoints {
  /// Max width for a small layout.
  static const double small = 768;

  static const double tablet = 1024;

  /// Max width for a medium layout.
  static const double medium = 1536;

  /// Max width for a large layout.
  static const double large = 1792;

  static bool useDesktopLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).width > small && !isMobileApp();
  }

  static bool useDesktopOverlay(BuildContext context) {
    return MediaQuery.sizeOf(context).width > tablet && !isMobileApp();
  }

  static bool isMobileApp() =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}

enum Platforms {
  mobile,
  desktop,
}
