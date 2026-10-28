import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/dev/dev_flags.dart' show kShowDevTools;
import 'package:genius_wallet/gnus_bridge/gnus_bridge_view_linux.dart';
import 'package:genius_wallet/gnus_bridge/gnus_bridge_view_mobile.dart';
import 'package:genius_wallet/gnus_bridge/gnus_bridge_view_windows.dart';
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_origins.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:go_router/go_router.dart';

/// Which web view hosts the dashboard on this device.
enum GnusBridgeHostKind { linux, windows, webview, browser }

/// The one choice of bridge view per platform. Linux without WebKitGTK has no
/// in-app page, so it gets the system browser.
GnusBridgeHostKind gnusBridgeHostKind(String os, {required bool linuxWebKit}) =>
    switch (os) {
      'linux' =>
        linuxWebKit ? GnusBridgeHostKind.linux : GnusBridgeHostKind.browser,
      'windows' => GnusBridgeHostKind.windows,
      'android' || 'ios' || 'macos' => GnusBridgeHostKind.webview,
      _ => GnusBridgeHostKind.browser,
    };

typedef GnusDashboardHostBuilder =
    Widget Function(BuildContext context, Uri start);

Widget defaultGnusDashboardHost(BuildContext context, Uri start) {
  const dev = kDebugMode && kShowDevTools;
  final handler = context.read<GnusRpcHandler>();
  final url = '$start';
  return switch (gnusBridgeHostKind(
    Platform.operatingSystem,
    linuxWebKit: linuxInAppWeb,
  )) {
    GnusBridgeHostKind.linux => GnusBridgeViewLinux(
      url: url,
      handler: handler,
      readNet: handler.readSgnsNet,
      dev: dev,
    ),
    GnusBridgeHostKind.windows => GnusBridgeViewWindows(
      url: url,
      handler: handler,
      readNet: handler.readSgnsNet,
      dev: dev,
    ),
    GnusBridgeHostKind.webview => GnusBridgeViewMobile(
      url: url,
      handler: handler,
      readNet: handler.readSgnsNet,
      dev: dev,
    ),
    GnusBridgeHostKind.browser => const SizedBox.shrink(),
  };
}

/// Opens the dashboard screen. The route reads no URL, so the page cannot be
/// chosen from outside.
void openGnusDashboard(BuildContext context) {
  unawaited(context.push('/gnus-dashboard'));
}

/// Full-screen host for the dashboard web view, pinned to the start the
/// network and build mode give it.
class GnusDashboardScreen extends StatefulWidget {
  const GnusDashboardScreen({
    super.key,
    required this.readNet,
    this.dev = kDebugMode && kShowDevTools,
    this.hostBuilder = defaultGnusDashboardHost,
  });

  final Future<SgnsNet> Function() readNet;
  final bool dev;
  final GnusDashboardHostBuilder hostBuilder;

  @override
  State<GnusDashboardScreen> createState() => _GnusDashboardScreenState();
}

class _GnusDashboardScreenState extends State<GnusDashboardScreen> {
  Uri? _start;

  @override
  void initState() {
    super.initState();
    unawaited(_resolve());
  }

  Future<void> _resolve() async {
    final SgnsNet net;
    try {
      net = await widget.readNet();
    } catch (e) {
      debugPrint('Dashboard network unavailable: ${e.runtimeType}');
      return;
    }
    if (mounted) {
      setState(() => _start = gnusDashboardStart(net, dev: widget.dev));
    }
  }

  void _close() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final start = _start;
    return Scaffold(
      backgroundColor: gw.surfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            _DashboardHeader(host: start?.host, onClose: _close),
            Expanded(
              child: start == null
                  ? const Center(child: Loading())
                  : widget.hostBuilder(context, start),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.host, required this.onClose});

  final String? host;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
        vertical: GeniusWalletConsts.space2,
      ),
      child: Row(
        children: [
          GWButton.icon(
            icon: Icon(Icons.close, color: gw.textPrimary),
            tooltip: 'Close',
            semanticLabel: 'Close jobs and earnings',
            onPressed: onClose,
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Jobs and earnings',
                    style: GeniusWalletTypography.titleLg.copyWith(
                      color: gw.textPrimary,
                    ),
                  ),
                ),
                if (host != null)
                  Text(
                    host!,
                    overflow: TextOverflow.ellipsis,
                    style: GeniusWalletTypography.labelMd.copyWith(
                      color: gw.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
