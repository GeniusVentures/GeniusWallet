import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class NetworkStatusPage extends StatefulWidget {
  final GeniusApi geniusApi;
  const NetworkStatusPage({super.key, required this.geniusApi});

  @override
  State<NetworkStatusPage> createState() => _NetworkStatusPageState();
}

class _NetworkStatusPageState extends State<NetworkStatusPage> {
  late Stream<ConnectivityResult> connectivityStream;
  ConnectivityResult? lastKnownConnectivity = ConnectivityResult.none;
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  Timer? _initStatusTimer;
  String? _initStatusMessage;
  double? _initPercentage;

  @override
  void initState() {
    super.initState();

    Connectivity().checkConnectivity().then((list) {
      if (!mounted) return;
      setState(() {
        lastKnownConnectivity = list.isNotEmpty
            ? list.first
            : ConnectivityResult.none;
      });
    });

    connectivityStream = Connectivity().onConnectivityChanged.map(
      (list) => list.isNotEmpty ? list.first : ConnectivityResult.none,
    );

    _connectivitySub = connectivityStream.listen((result) {
      if (!mounted) return;
      setState(() {
        lastKnownConnectivity = result;
      });
    });

    _startInitStatusPolling();
  }

  void _startInitStatusPolling() {
    _initStatusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      try {
        final status = widget.geniusApi.getInitializationStatus();
        setState(() {
          _initPercentage = status.percentage;
          _initStatusMessage = status.message;
        });
        if (status.percentage >= 1.0) {
          _initStatusTimer?.cancel();
        }
      } catch (_) {
        // Ignore polling errors and try again next tick.
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _initStatusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connectivity')),
      body: Align(
        alignment: AlignmentGeometry.topCenter,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: GeniusBreakpoints.medium,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                StreamBuilder<ConnectivityResult>(
                  stream: connectivityStream,
                  initialData: lastKnownConnectivity,
                  builder: (context, snapshot) {
                    ConnectivityResult? statusValue =
                        snapshot.data ?? lastKnownConnectivity;
                    String status = "Checking...";
                    if (statusValue != null) {
                      if (statusValue == ConnectivityResult.none) {
                        status = "Offline";
                      } else {
                        status =
                            "Online (${statusValue.toString().split('.').last})";
                      }
                    }
                    return ListTile(
                      leading: Icon(
                        status.startsWith("Online")
                            ? Icons.check_circle
                            : Icons.error,
                        color: status.startsWith("Online")
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: const Text("Network Connectivity"),
                      subtitle: Text(status),
                    );
                  },
                ),
                const Divider(),
                StreamBuilder<SGNUSConnection>(
                  stream: widget.geniusApi.getSGNUSConnectionStream(),
                  builder: (context, snapshot) {
                    final connection = snapshot.data;
                    return ListTile(
                      leading: Icon(
                        (connection != null && connection.isConnected)
                            ? Icons.check_circle
                            : Icons.error_outline,
                        color: (connection != null && connection.isConnected)
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: const Text('SGNUS Connection'),
                      subtitle: Text(
                        connection == null
                            ? 'No data'
                            : connection.isConnected
                            ? "Connected\nAddress: ${connection.sgnusAddress}\nWallet: ${connection.walletAddress}"
                            : "Disconnected",
                      ),
                    );
                  },
                ),
                const Divider(),
                if (_initStatusMessage != null)
                  ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        value: _initPercentage ?? 0.0,
                        strokeWidth: 2.0,
                        color: (_initPercentage ?? 0.0) >= 1.0
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),
                    title: const Text('SDK Initialization'),
                    subtitle: Text(
                      _initStatusMessage ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: _initPercentage != null
                        ? Text(
                            '${(_initPercentage! * 100).toStringAsFixed(1)}%',
                          )
                        : null,
                  ),
                const Divider(),
                BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
                  builder: (context, state) {
                    if (state.selectedWallet == null) {
                      return const Text("No wallet selected.");
                    }
                    return ListTile(
                      leading: const Icon(Icons.account_balance_wallet),
                      title: const Text("Current Wallet"),
                      subtitle: Text(
                        "Name: ${state.selectedWallet!.walletName}\n"
                        "Address: ${state.selectedWallet!.address}",
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
