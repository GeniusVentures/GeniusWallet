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
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:go_router/go_router.dart';

class SGNUSConnectionWidget extends StatefulWidget {
  const SGNUSConnectionWidget({Key? key}) : super(key: key);

  @override
  SGNUSConnectionState createState() => SGNUSConnectionState();
}

class SGNUSConnectionState extends State<SGNUSConnectionWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SGNUSConnection>(
      stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No connection data available'),
          );
        }

        final connection = snapshot.data!;
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
                    'SGNUS Connection ',
                    style: GeniusWalletTypography.bodyMd,
                  )),
                  const SizedBox(width: 8),
                  if (connection.isConnected) const CheckmarkAnimation(),
                  if (!connection.isConnected) const XAnimation(),
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SGNUSConnection>(
      stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No connection data available'),
          );
        }

        final connection = snapshot.data!;
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
                    'SGNUS Connection ',
                    style: GeniusWalletTypography.bodyMd,
                  )),
                  const SizedBox(width: 8),
                  if (connection.isConnected) const CheckmarkAnimation(),
                  if (!connection.isConnected) const XAnimation(),
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
