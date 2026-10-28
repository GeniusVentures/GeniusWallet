import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/dev/dev_flags.dart' show kShowDevTools;
import 'package:genius_wallet/gnus_bridge/gnus_bridge_view_linux.dart';
import 'package:genius_wallet/gnus_bridge/gnus_bridge_view_mobile.dart';
import 'package:genius_wallet/gnus_bridge/gnus_bridge_view_windows.dart';
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_origins.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/web/web_utils.dart';

/// Dev-only page that loads a dashboard URL in a web view carrying
/// `window.gnus`. Reachable only from the dev bubble's GNUS BRIDGE section.
class GnusBridgeTestScreen extends StatefulWidget {
  const GnusBridgeTestScreen({super.key});

  @override
  State<GnusBridgeTestScreen> createState() => _GnusBridgeTestScreenState();
}

class _GnusBridgeTestScreenState extends State<GnusBridgeTestScreen> {
  final TextEditingController _url = TextEditingController(
    text: kGnusDashboardDevOrigin,
  );
  String _loaded = kGnusDashboardDevOrigin;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GNUS bridge test page'),
        backgroundColor: context.gw.surfaceElevated,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(GeniusWalletConsts.space3),
            child: Row(
              children: [
                Expanded(child: GWTextField(controller: _url)),
                const SizedBox(width: GeniusWalletConsts.space2),
                GWButton(
                  label: 'Load',
                  onPressed: () => setState(() => _loaded = _url.text.trim()),
                ),
              ],
            ),
          ),
          Expanded(child: _BridgeBody(url: _loaded)),
        ],
      ),
    );
  }
}

class _BridgeBody extends StatelessWidget {
  const _BridgeBody({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    const dev = kDebugMode && kShowDevTools;
    final handler = context.read<GnusRpcHandler>();
    if (dev && Platform.isWindows) {
      return GnusBridgeViewWindows(
        url: url,
        handler: handler,
        readNet: handler.readSgnsNet,
        dev: dev,
      );
    }
    if (dev && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      return GnusBridgeViewMobile(
        url: url,
        handler: handler,
        readNet: handler.readSgnsNet,
        dev: dev,
      );
    }
    if (dev && Platform.isLinux && linuxInAppWeb) {
      return GnusBridgeViewLinux(
        url: url,
        handler: handler,
        readNet: handler.readSgnsNet,
        dev: dev,
      );
    }
    return const Center(child: Text('There is no bridge on this platform.'));
  }
}
