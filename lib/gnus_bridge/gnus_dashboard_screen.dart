import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/gw_notice.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dev/dev_flags.dart' show kShowDevTools;
import 'package:genius_wallet/dev/dev_gnus_bridge.dart' show kDevGnusHosted;
import 'package:genius_wallet/gnus_bridge/gnus_bridge_view_linux.dart';
import 'package:genius_wallet/gnus_bridge/gnus_bridge_view_mobile.dart';
import 'package:genius_wallet/gnus_bridge/gnus_bridge_view_windows.dart';
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_origins.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/web/web_overlay_gate.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// Builds the web view for [start]. The view reports its first finished page,
/// a main-frame load failure, and an install that left no safe bridge.
typedef GnusDashboardHostBuilder =
    Widget Function(
      BuildContext context,
      Uri start, {
      required VoidCallback onLoaded,
      required VoidCallback onFailed,
      required VoidCallback onNoBridge,
    });

Widget defaultGnusDashboardHost(
  BuildContext context,
  Uri start, {
  required VoidCallback onLoaded,
  required VoidCallback onFailed,
  required VoidCallback onNoBridge,
}) {
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
      onPageFinished: onLoaded,
      onLoadFailed: onFailed,
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

typedef GnusBrowserLauncher = Future<bool> Function(Uri url, {LaunchMode mode});

Future<void> _openInBrowser(
  BuildContext context,
  Future<Uri> Function() start,
  GnusBrowserLauncher launcher,
) async {
  var opened = false;
  try {
    opened = await launcher(
      await start(),
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    debugPrint('Dashboard browser open failed: ${e.runtimeType}');
  }
  if (!opened && context.mounted) {
    showToast(context, "Couldn't open your browser.", type: ToastType.error);
  }
}

/// Opens the dashboard: the in-app screen, or the system browser where there is
/// no in-app web view. The route reads no URL, so the page cannot be chosen from
/// outside. The seams are for tests.
Future<void> openGnusDashboard(
  BuildContext context, {
  bool? inApp,
  GnusBrowserLauncher launcher = launchUrl,
  Future<SgnsNet> Function()? readNet,
}) async {
  if (inApp ?? inAppWeb) {
    unawaited(context.push('/gnus-dashboard'));
    return;
  }
  const dev = kDebugMode && kShowDevTools;
  final net = readNet ?? context.read<GnusRpcHandler>().readSgnsNet;
  await _openInBrowser(
    context,
    () async => gnusDashboardStart(
      await net(),
      dev: dev,
      hosted: dev && kDevGnusHosted.value,
    ),
    launcher,
  );
}

/// Full-screen host for the dashboard web view, pinned to the start the
/// network and build mode give it.
class GnusDashboardScreen extends StatefulWidget {
  const GnusDashboardScreen({
    super.key,
    required this.readNet,
    this.dev = kDebugMode && kShowDevTools,
    this.hostBuilder = defaultGnusDashboardHost,
    this.launcher = launchUrl,
    this.hostKind,
  });

  final Future<SgnsNet> Function() readNet;
  final bool dev;
  final GnusDashboardHostBuilder hostBuilder;
  final GnusBrowserLauncher launcher;

  /// Which kind of view the host builder makes; the device's own by default.
  final GnusBridgeHostKind? hostKind;

  @override
  State<GnusDashboardScreen> createState() => _GnusDashboardScreenState();
}

class _GnusDashboardScreenState extends State<GnusDashboardScreen> {
  Uri? _start;
  bool _loaded = false;
  bool _failed = false;
  bool _noBridge = false;
  int _hostKey = 0;

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
      _onFailed();
      return;
    }
    if (mounted) {
      setState(
        () => _start = gnusDashboardStart(
          net,
          dev: widget.dev,
          hosted: widget.dev && kDevGnusHosted.value,
        ),
      );
    }
  }

  void _onLoaded() {
    if (mounted && !_loaded) {
      setState(() => _loaded = true);
    }
  }

  void _onFailed() {
    if (mounted) {
      setState(() => _failed = true);
    }
  }

  void _onNoBridge() {
    if (mounted) {
      setState(() => _noBridge = true);
    }
  }

  // A fresh host is a fresh page and a fresh bridge session.
  void _restart() {
    setState(() {
      _hostKey++;
      _loaded = false;
      _failed = false;
    });
    if (_start == null) {
      unawaited(_resolve());
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
    final Widget body;
    if (_noBridge && start != null) {
      body = GWNotice(
        liveRegion: true,
        title: 'Open jobs and earnings in your browser',
        message: "This device's web view can't connect to the wallet safely.",
        actions: [
          GWButton(
            variant: GWButtonVariant.gradient,
            expand: true,
            label: 'Open in browser',
            onPressed: () => unawaited(
              _openInBrowser(context, () async => start, widget.launcher),
            ),
          ),
          GWButton(
            variant: GWButtonVariant.secondary,
            expand: true,
            label: 'Close',
            onPressed: _close,
          ),
        ],
      );
    } else if (_failed) {
      body = GWNotice(
        liveRegion: true,
        title: "Jobs and earnings didn't load",
        message: 'Check your connection, then try again.',
        actions: [
          GWButton(
            variant: GWButtonVariant.gradient,
            expand: true,
            label: 'Try again',
            onPressed: _restart,
          ),
          GWButton(
            variant: GWButtonVariant.secondary,
            expand: true,
            label: 'Close',
            onPressed: _close,
          ),
        ],
      );
    } else if (start == null) {
      body = const Center(child: Loading());
    } else {
      final host = Semantics(
        container: true,
        label: 'Jobs and earnings page, ${start.host}',
        child: widget.hostBuilder(
          context,
          start,
          onLoaded: _onLoaded,
          onFailed: _onFailed,
          onNoBridge: _onNoBridge,
        ),
      );
      // The Linux page paints above Flutter, so it steps aside for any popup.
      final kind =
          widget.hostKind ??
          gnusBridgeHostKind(
            Platform.operatingSystem,
            linuxWebKit: linuxInAppWeb,
          );
      body = KeyedSubtree(
        key: ValueKey(_hostKey),
        child: kind == GnusBridgeHostKind.linux
            ? WebOverlayGate(child: host)
            : host,
      );
    }
    return Scaffold(
      backgroundColor: gw.surfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            _DashboardHeader(
              host: start?.host,
              onClose: _close,
              onReload: _restart,
            ),
            if (!_loaded && !_failed && !_noBridge) const _LoadingBar(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar();

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Loading jobs and earnings',
      child: ExcludeSemantics(
        child: LinearProgressIndicator(
          minHeight: 3,
          color: gw.brandPrimaryOnSurface,
          backgroundColor: gw.borderSubtle,
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.host,
    required this.onClose,
    required this.onReload,
  });

  final String? host;
  final VoidCallback onClose;
  final VoidCallback onReload;

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
          GWButton.icon(
            icon: Icon(Icons.refresh, color: gw.textPrimary),
            tooltip: 'Reload',
            semanticLabel: 'Reload jobs and earnings',
            onPressed: onReload,
          ),
        ],
      ),
    );
  }
}
