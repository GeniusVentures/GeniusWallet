import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// `context.gw` -- the single new access path 23-02's call-site migration
/// rewrites the legacy `GeniusWalletColors.*` references onto. Kept in its
/// own file rather than appended to `gw_colors.dart`: this extension is API
/// surface for the whole app, while `gw_colors.dart` is the token
/// definition -- they get edited by different people for different reasons.
extension GWContextColors on BuildContext {
  /// The registered [GWColors], or [GWColors.dark] (the app's default
  /// appearance) if none is registered.
  ///
  /// FALLS BACK RATHER THAN THROWING. A widget should render slightly wrong
  /// in an unusual host, not crash: several existing widget tests pump a
  /// bare `MaterialApp` without the app's theme --
  /// `test/components/gw_card_hover_test.dart` supplies
  /// `ThemeData(extensions: [GWColors.dark()])` explicitly, but others do
  /// not, and a hard `!`-assertion here would break them all at once.
  ///
  /// NEVER CACHE THE RESULT. Read this inside `build`. Storing it in a
  /// controller, painter or model is the documented failure where a screen
  /// keeps rendering the previous brightness after a live appearance
  /// switch -- see `gw_colors.dart`'s header comment for why `const`
  /// widgets specifically need this to be a `Theme.of(context)` read, not a
  /// value captured once.
  GWColors get gw => Theme.of(this).extension<GWColors>() ?? GWColors.dark();
}
