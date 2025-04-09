import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/action_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

class ReownConnectButton extends StatefulWidget {
  final String walletAddress;
  const ReownConnectButton({super.key, required this.walletAddress});

  @override
  State<ReownConnectButton> createState() => _ReownConnectButtonState();
}

class _ReownConnectButtonState extends State<ReownConnectButton> {
  late final ReownWalletKit walletKit;
  SessionData? _session;
  bool _isConnecting = false;
  bool _hasError = false;
  String _statusMessage = '';
  final TextEditingController _uriController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeWalletKit();
  }

  Future<void> _initializeWalletKit() async {
    walletKit = ReownWalletKit(
      core: ReownCore(projectId: '999123e54f32a21dbd087339746231b1'),
      metadata: const PairingMetadata(
        name: 'Gnus.ai Wallet',
        description: 'Gnus.ai wallet',
        url: 'https://gnus.ai/',
        icons: ['https://example.com/logo.png'],
      ),
    );

    await walletKit.init();

    final sessions = walletKit.getActiveSessions();
    if (sessions.isNotEmpty) {
      final restored = sessions.values.first;
      setState(() {
        _session = restored;
        _statusMessage = "🔄 Session restored";
      });
    }

    walletKit.onSessionConnect.subscribe((event) {
      setState(() {
        _session = event.session;
        _statusMessage = "✅ Connected to ${event.session.peer.metadata.name}";
        _isConnecting = false;
        _hasError = false;
      });
    });

    walletKit.onSessionProposal.subscribe((event) async {
      final dappName = event.params.proposer.metadata.name;
      final dappUrl = event.params.proposer.metadata.url;

      setState(() {
        _statusMessage = "🔵 Connection requested from $dappName ($dappUrl)";
      });

      await Future.delayed(const Duration(seconds: 1));
      await walletKit.approveSession(
        id: event.id,
        namespaces: {
          'eip155': Namespace(
            chains: ['eip155:1'],
            methods: [
              'eth_sendTransaction',
              'eth_signTransaction',
              'eth_sign',
              'personal_sign',
              'eth_signTypedData',
            ],
            events: ['chainChanged', 'accountsChanged'],
            accounts: ['eip155:1:${widget.walletAddress}'],
          ),
        },
      );
    });
  }

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _hasError = false;
      _statusMessage = "🔄 Generating QR Code...";
    });

    try {
      final CreateResponse pairingInfo = await walletKit.core.pairing.create();
      final wcUri = pairingInfo.uri.toString();

      if (!mounted) return;

      await showDialog(
        barrierColor: Colors.black.withOpacity(0.90),
        context: context,
        builder: (_) {
          bool showManualInput = false;

          return StatefulBuilder(
            builder: (context, setInnerState) => AlertDialog(
              backgroundColor: GeniusWalletColors.deepBlueTertiary,
              title: const Center(child: Text("Connect to Wallet")),
              content: SizedBox(
                width: 300,
                height: 320,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: showManualInput
                            ? Column(
                                key: const ValueKey("manual"),
                                children: [
                                  const Text("Paste WalletConnect URI"),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _uriController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: "wc:...",
                                      hintStyle:
                                          TextStyle(color: Colors.white38),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              )
                            : QrImageView(
                                backgroundColor: Colors.white,
                                key: const ValueKey("qr"),
                                data: wcUri,
                                version: QrVersions.auto,
                                size: 250,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setInnerState(() => showManualInput = !showManualInput);
                      },
                      child: Text(
                        showManualInput
                            ? "← Show QR Code"
                            : "Enter URI Manually",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                if (showManualInput)
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await walletKit.pair(uri: Uri.parse(_uriController.text));
                    },
                    child: const Text("Connect"),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => _isConnecting = false);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _statusMessage = "🔄 Waiting for session proposal...";
      });
      print('🔄 Waiting for session proposal...');
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Connection failed: $e';
        _isConnecting = false;
        _hasError = true;
      });
      print('❌ Connection failed: $e');
    }
  }

  Future<void> _disconnect() async {
    if (_session != null) {
      await walletKit.disconnectSession(
        topic: _session!.topic,
        reason: Errors.getSdkError(Errors.USER_DISCONNECTED).toSignError(),
      );
      setState(() {
        _session = null;
        _statusMessage = '🔌 Disconnected.';
        _hasError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _session != null;

    IconData icon;
    Color iconColor;
    Color textColor;
    Color backgroundColor;
    String text;

    if (isConnected) {
      icon = Icons.link_off;
      iconColor = Colors.redAccent;
      textColor = Colors.redAccent;
      backgroundColor = Colors.redAccent.withOpacity(0.1);
      text = 'Disconnect';
    } else if (_isConnecting) {
      icon = Icons.sync;
      iconColor = Colors.amber;
      textColor = Colors.amber;
      backgroundColor = Colors.amber.withOpacity(0.1);
      text = 'Connecting...';
    } else if (_hasError) {
      icon = Icons.error_outline;
      iconColor = Colors.redAccent;
      textColor = Colors.redAccent;
      backgroundColor = Colors.redAccent.withOpacity(0.1);
      text = 'Retry Connect';
    } else {
      icon = Icons.link;
      iconColor = Colors.greenAccent;
      textColor = Colors.greenAccent;
      backgroundColor = GeniusWalletColors.deepBlueCardColor;
      text = 'Connect';
    }

    return ActionButton(
      text: text,
      icon: icon,
      iconColor: iconColor,
      textColor: textColor,
      backgroundColor: backgroundColor,
      onPressed: () {
        if (_isConnecting) return;
        if (isConnected) {
          _disconnect();
        } else {
          _connect();
        }
      },
    );
  }
}
