import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Shared two-mode pump helper for Phase 9's `test/banxa/` suite.
///
/// Copied from `test/squid_router/route_details_card_test.dart`'s `_host`,
/// promoted to a shared file because every later test file in this phase
/// needs the same wrapper (09-01-PLAN.md Task 1).
Widget gwHost(Widget child, {GWColors? gw}) => MaterialApp(
  theme: ThemeData(extensions: [gw ?? GWColors.dark()]),
  home: Scaffold(body: child),
);

/// The two appearance values a test can loop over in one line — the phase's
/// only automated defence against the const-widget-does-not-re-skin defect
/// class (09-UI-SPEC Interaction rule 3).
final List<GWColors> gwBothModes = [GWColors.dark(), GWColors.light()];
