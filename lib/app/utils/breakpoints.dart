import 'package:flutter/material.dart';

class GeniusBreakpoints {
  /// [480] and above considered [mobile]
  static const mobile = 480;

  // /// [800] and above considered [tablet]
  // static const tablet = 800;

  /// [1000] and above considered [desktop]
  static const desktop = 1000;

  static bool useDesktopLayout(BuildContext context) {
    return MediaQuery.of(context).size.width > desktop;
  }
}
