import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/animation/checkmark_animation.dart';
import 'package:genius_wallet/components/animation/x_animation.dart';
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:go_router/go_router.dart';

class SGNUSConnectionWidget extends StatefulWidget {
  const SGNUSConnectionWidget({Key? key}) : super(key: key);

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
    if (_initComplete || _geniusApi == null) return;
    _initTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
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
      stream: (_geniusApi ?? context.read<GeniusApi>())
          .getSGNUSConnectionStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No connection data available'),
          );
        }

        final connection = snapshot.data!;

        String label = 'SGNUS Connection ';
        Widget statusIcon;
        if (_initComplete ||
            (_initPercentage != null && _initPercentage! >= 1.0)) {
          statusIcon = const CheckmarkAnimation();
        } else if (_initPercentage != null) {
          statusIcon = SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              value: _initPercentage,
              strokeWidth: 3.0,
              color: GeniusWalletColors.statusSuccess,
            ),
          );
          label =
              'SGNUS Connection (${(_initPercentage! * 100).toStringAsFixed(1)}%) ';
        } else {
          statusIcon = connection.isConnected
              ? const CheckmarkAnimation()
              : const XAnimation();
        }

        return GestureDetector(
          onTap: () => context.push('/network'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                      child: AutoSizeText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    label,
                    style: GeniusWalletTypography.bodyMd,
                  )),
                  const SizedBox(width: GeniusWalletConsts.space4),
                  statusIcon,
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SGNUSConnectionMobileWidget extends StatefulWidget {
  const SGNUSConnectionMobileWidget({Key? key}) : super(key: key);

  @override
  SGNUSConnectionMobileState createState() => SGNUSConnectionMobileState();
}

class SGNUSConnectionMobileState extends State<SGNUSConnectionMobileWidget> {
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
    if (_initComplete || _geniusApi == null) return;
    _initTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
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
      stream: (_geniusApi ?? context.read<GeniusApi>())
          .getSGNUSConnectionStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No connection data available'),
          );
        }

        final connection = snapshot.data!;

        String label = 'SGNUS Connection ';
        Widget statusIcon;
        if (_initComplete ||
            (_initPercentage != null && _initPercentage! >= 1.0)) {
          statusIcon = const CheckmarkAnimation();
        } else if (_initPercentage != null) {
          statusIcon = SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              value: _initPercentage,
              strokeWidth: 3.0,
              color: GeniusWalletColors.statusSuccess,
            ),
          );
          label =
              'SGNUS Connection (${(_initPercentage! * 100).toStringAsFixed(1)}%) ';
        } else {
          statusIcon = connection.isConnected
              ? const CheckmarkAnimation()
              : const XAnimation();
        }

        return GestureDetector(
          onTap: () => context.push('/network'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      child: AutoSizeText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    label,
                    style: GeniusWalletTypography.bodyMd,
                  )),
                  const SizedBox(width: GeniusWalletConsts.space4),
                  statusIcon,
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SGNUSConnectionStatusWidget extends StatelessWidget {
  final bool? isSmallScreen;

  const SGNUSConnectionStatusWidget({
    Key? key,
    this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alignment =
        isSmallScreen == true ? Alignment.center : Alignment.centerRight;

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final isProcessing = appState.isProcessing;

        final statusText = isProcessing
            ? '${appState.processingPercentage?.toStringAsFixed(2) ?? "0.00"}%'
            : 'idle';

        return Align(
          alignment: alignment,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isProcessing) ...[
                const Loading(text: "processing"),
                const SizedBox(width: GeniusWalletConsts.space4),
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
                    color: isProcessing
                        ? GeniusWalletColors.textPrimary
                        : GeniusWalletColors.textPrimary70,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
