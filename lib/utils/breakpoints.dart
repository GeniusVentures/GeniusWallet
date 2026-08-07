import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

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

  /// Navbar→page-title gap. Shared by the seven pages that mount a
  /// `GWPageHeader` so their titles land on one line; keep it here, not as a
  /// ternary per call site.
  static double pageTitleGap(BuildContext context) => useDesktopLayout(context)
      ? GeniusWalletConsts.space32
      : GeniusWalletConsts.space12;

  /// Page frame left/right gutter, shared by the same seven pages.
  ///
  /// Never 0 — content on the window bezel is a real defect (06-01 walk);
  /// `transactions_page_frame_test.dart` pins that a gutter survives at 360px.
  static double pageGutter(BuildContext context) =>
      useDesktopLayout(context) ? 12 : 6;
}

enum Platforms { mobile, desktop }
