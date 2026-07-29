import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/animation/checkmark_animation.dart';
import 'package:genius_wallet/components/animation/x_animation.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:go_router/go_router.dart';

class SGNUSConnectionWidget extends StatefulWidget {
  const SGNUSConnectionWidget({super.key});

  @override
  SGNUSConnectionState createState() => SGNUSConnectionState();
}

class SGNUSConnectionState extends State<SGNUSConnectionWidget> {
  Timer? _initTimer;
  double? _initPercentage;
  bool _initComplete = false;
  GeniusApi? _geniusApi;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _geniusApi ??= context.read<GeniusApi>();
    _startInitPolling();
  }

  void _startInitPolling() {
    _initTimer?.cancel();
    if (_initComplete || _geniusApi == null) {
      return;
    }
    _initTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) {
        return;
      }
      try {
        final status = _geniusApi!.getInitializationStatus();
        setState(() {
          _initPercentage = status.percentage;
          if (status.percentage >= 1.0) {
            _initComplete = true;
            _initTimer?.cancel();
          }
        });
      } catch (_) {
        // Ignore polling errors and try again next tick.
      }
    });
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SGNUSConnection>(
      stream: _geniusApi!.getSGNUSConnectionStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Text('No connection data available'));
        }

        final connection = snapshot.data!;

        Widget icon;
        String label;

        if (_initComplete ||
            (_initPercentage != null && _initPercentage! >= 1.0)) {
          icon = const CheckmarkAnimation();
          label = 'SGNUS Connection';
        } else if (_initPercentage != null) {
          icon = SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              value: _initPercentage,
              strokeWidth: 3.0,
              color: context.gw.brandPrimary,
            ),
          );
          label =
              'SGNUS Connection (${(_initPercentage! * 100).toStringAsFixed(1)}%)';
        } else {
          icon = connection.isConnected
              ? const CheckmarkAnimation()
              : const XAnimation();
          label = 'SGNUS Connection';
        }

        return TextButton.icon(
          iconAlignment: IconAlignment.end,
          onPressed: () => context.push('/network'),
          label: Text(label),
          icon: icon,
        );
      },
    );
  }
}

class SGNUSConnectionStatusWidget extends StatelessWidget {
  const SGNUSConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
        final isProcessing = appState.isProcessing;

        final statusText = isProcessing
            ? '${appState.processingPercentage?.toStringAsFixed(2) ?? "0.00"}%'
            : 'idle';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isProcessing) ...[
              const Loading(text: "processing"),
              const SizedBox(width: 8),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 60),
              child: AutoSizeText(
                statusText,
                maxLines: 1,
                minFontSize: 10,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isProcessing ? gw.textPrimary : gw.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
