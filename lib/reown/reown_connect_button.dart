import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/reown/approve_dapp_connection_drawer.dart';
import 'package:genius_wallet/reown/handle_dapp_requests.dart';
import 'package:genius_wallet/reown/reown_walletkit_instance.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'dart:io';

final List<String> supportedMethods = [
  'eth_sendTransaction', // For sending, approvals, swaps
  'personal_sign', // For signing messages (login, etc.)
  'eth_signTypedData', // For EIP-712 signatures (used in advanced DApps)
];

class ReownConnectButton extends StatefulWidget {
  final String walletAddress;
  final GeniusApi geniusApi;
  final WalletDetailsCubit walletDetailsCubit;
  final TransactionsCubit transactionsCubit;
  const ReownConnectButton(
      {super.key,
      required this.walletAddress,
      required this.geniusApi,
      required this.walletDetailsCubit,
      required this.transactionsCubit});

  @override
  State<ReownConnectButton> createState() => _ReownConnectButtonState();
}

class _ReownConnectButtonState extends State<ReownConnectButton> {
  ReownWalletKit get walletKit => WalletKitInstance().walletKit;
  SessionData? _session;
  bool _isConnecting = false;
  bool _isDisconnecting = false;
  bool _didManualPair = false;
  bool _hasError = false;
  bool _timedOut = false;
  String _statusMessage = '';
  final TextEditingController _uriController = TextEditingController();
  bool _listenersAttached = false;
  void Function()? _sessionRequestDisposer;
  late final dynamic _sessionConnectHandler;
  late final dynamic _sessionProposalHandler;

  bool get _isDesktopOrIot {
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeWalletKit();
  }

  @override
  void dispose() {
    if (_listenersAttached) {
      walletKit.onSessionConnect.unsubscribe(_sessionConnectHandler);
      walletKit.onSessionProposal.unsubscribe(_sessionProposalHandler);
      _sessionRequestDisposer?.call();
      _listenersAttached = false;
    }
    _uriController.dispose();
    super.dispose();
  }

  Future<void> _initializeWalletKit() async {
    await maybeInitWalletKit();

    try {
      final sessions = walletKit.getActiveSessions();
      if (sessions.isNotEmpty) {
        final restored = sessions.values.first;

        setState(() {
          _session = restored;
          _statusMessage = "🔄 Session restored";
        });

        debugPrint("🔄 Session restored: ${restored.peer.metadata.name}");
      }

      _attachWalletKitListeners();
    } catch (e) {
      debugPrint("❌ WalletKit initialization failed: $e");
    }
  }

  void _attachWalletKitListeners() {
    if (_listenersAttached) {
      return;
    }

    // Listen for incoming requests
    _sessionRequestDisposer = handleDappRequests(
          walletKit: walletKit,
          geniusApi: widget.geniusApi,
          walletDetailsCubit: widget.walletDetailsCubit,
          transactionsCubit: widget.transactionsCubit);

    _sessionConnectHandler = (event) {
      if (!mounted || event == null) return;

      setState(() {
        _session = event.session;
        _statusMessage = "✅ Connected to ${event.session.peer.metadata.name}";
        _isConnecting = false;
        _hasError = false;
        _timedOut = false;
      });
      debugPrint("✅ Connected to ${event.session.peer.metadata.name}");
    };
    walletKit.onSessionConnect.subscribe(_sessionConnectHandler);

    _sessionProposalHandler = (event) async {
      if (event == null) return;
      final metadata = event.params.proposer.metadata;
      final dappName = metadata.name;
      final dappDescription = metadata.description;
      final dappUrl = metadata.url;
      final dappIcon = metadata.icons.isNotEmpty ? metadata.icons.first : null;

      if (!mounted) return;

      setState(() {
        _statusMessage = "🔵 Connection requested from $dappName ($dappUrl)";
      });

      debugPrint("🔵 Connection requested from $dappName ($dappUrl $dappIcon)");

      try {
        final bool? approved = await ApproveDappConnectionDrawer.show(
          context: navigatorKey.currentContext!,
          dappName: dappName,
          dappUrl: dappUrl,
          dappDescription: dappDescription,
          iconUrl: dappIcon,
        );

        if (approved == null || !approved) {
          debugPrint("❌ Connection request rejected by user");
          showAppSnackBar(
            context,
            "DApp connection was rejected.",
            backgroundColor: Colors.red,
          );

          await walletKit.rejectSession(
            id: event.id,
            reason: Errors.getSdkError(Errors.USER_REJECTED).toSignError(),
          );
          return;
        }

        await walletKit.approveSession(
          id: event.id,
          namespaces: {
            'eip155': Namespace(
              chains: ['eip155:1'],
              methods: supportedMethods,
              events: ['chainChanged', 'accountsChanged'],
              accounts: ['eip155:1:${widget.walletAddress}'],
            ),
          },
        );
      } catch (e) {
        debugPrint('❌ Session proposal handling failed: $e');
      }
    };
    walletKit.onSessionProposal.subscribe(_sessionProposalHandler);
    _listenersAttached = true;
  }

  Future<void> maybeInitWalletKit() async {
    final arch = Platform.version.toLowerCase();

    // Skip if running on x86 or x86_64 (i.e. emulators without native .so support)
    if ((arch.contains('x86') ||
            arch.contains('x64') ||
            arch.contains('ia32')) &&
        !arch.contains('windows')) {
      debugPrint("❌  Skipping WalletKit init on x86/x86_64 architecture");
      return;
    }

    try {
      await WalletKitInstance().initOnce();
      debugPrint("✅ WalletKit initialized");
    } catch (e) {
      debugPrint("❌ WalletKit initialization failed: $e");
    }
  }

  Future<void> _connect() async {
    if (_isDisconnecting) {
      return;
    }

    setState(() {
      _isConnecting = true;
      _hasError = false;
      _timedOut = false;
      _didManualPair = false;
      _statusMessage = "🔄 Generating QR Code...";
    });

    try {
      final CreateResponse pairingInfo = await walletKit.core.pairing.create();
      final wcUri = pairingInfo.uri.toString();
      debugPrint("🔗 WalletConnect URI: $wcUri");
      String? manualInputError;
      bool showManualInput = _isDesktopOrIot;

      if (!mounted) return;

      await ResponsiveDrawer.show<
          void>(context: context, title: "Wallet Connect", children: [
        StatefulBuilder(
          builder: (context, setInnerState) => AlertDialog(
            backgroundColor: GeniusWalletColors.deepBlueTertiary,
            title: Row(mainAxisSize: MainAxisSize.min, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/crypto/wallet-connect.png',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Wallet Connect",
                style: TextStyle(fontSize: 18),
              ),
            ]),
            content: SizedBox(
              width: 300,
              height: 320,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Expanded(
                      child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    child: showManualInput
                        ? KeyedSubtree(
                            key: ValueKey(
                                "manual-${DateTime.now().millisecondsSinceEpoch}"),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _uriController,
                                        decoration: const InputDecoration(
                                          hintText: "wc:...",
                                          hintStyle:
                                              TextStyle(color: Colors.white38),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.paste,
                                        size: 20,
                                        color: GeniusWalletColors
                                            .lightGreenPrimary,
                                      ),
                                      tooltip: "Paste from clipboard",
                                      onPressed: () async {
                                        final data = await Clipboard.getData(
                                            Clipboard.kTextPlain);
                                        if (data?.text != null &&
                                            data!.text!.trim().isNotEmpty) {
                                          setInnerState(() {
                                            _uriController.text =
                                                data.text!.trim();
                                            manualInputError = null;
                                          });
                                        } else {
                                          setInnerState(() {
                                            manualInputError =
                                                "Clipboard is empty or has no text.";
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                if (manualInputError != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    manualInputError!,
                                    style: const TextStyle(
                                        color: Colors.redAccent),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ))
                        : KeyedSubtree(
                            key: ValueKey(
                                "qr-${DateTime.now().millisecondsSinceEpoch}"),
                            child: QrImageView(
                              backgroundColor: Colors.white,
                              data: wcUri,
                              version: QrVersions.auto,
                            ),
                          ),
                  )),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setInnerState(() => showManualInput = !showManualInput);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.link,
                          size: 18,
                          color: GeniusWalletColors.lightGreenPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          showManualInput
                              ? "Show QR Code"
                              : "Enter URI Manually",
                          style: const TextStyle(
                            color: GeniusWalletColors.gray500,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                GeniusWalletColors.lightGreenPrimary,
                            decorationThickness: 2.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (showManualInput)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final input = _uriController.text.trim();

                      if (!input.startsWith('wc:') || !input.contains('@')) {
                        setInnerState(() {
                          manualInputError =
                              '❌ Invalid WalletConnect URI format.';
                        });
                        debugPrint('❌ Invalid format: $input');
                        return;
                      }

                      try {
                        final paired = await _tryPair(Uri.parse(input));
                        if (!paired) {
                          setInnerState(() {
                            manualInputError =
                                '❌ Failed to start WalletConnect session.';
                          });
                          return;
                        }
                        _didManualPair = true;
                        Navigator.of(context).pop();
                      } catch (e) {
                        setInnerState(() {
                          manualInputError = '❌ URI Connect Failed: $e';
                        });
                        debugPrint('❌ WalletKit pair failed: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: GeniusWalletGradient.greenBlueGreenGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: const Text(
                          "Connect",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => _isConnecting = false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: GeniusWalletColors.lightGreenPrimary,
                      width: 1.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.transparent,
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: GeniusWalletColors.lightGreenPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ]);

      if (_session == null) {
        setState(() {
          _isConnecting = false;
          _statusMessage = "❌ Cancelled or drawer closed";
        });
      }

      Future.delayed(const Duration(seconds: 15), () {
        if (_isConnecting && _session == null && mounted) {
          setState(() {
            _isConnecting = false;
            _hasError = true;
            _timedOut = true;
            _statusMessage = "⏱ Connection timed out. Please try again.";
          });
          debugPrint('⏱ Timeout hit – no session received.');
          if (context.mounted) {
            showAppSnackBar(
              context,
              "Wallet connection failed. Please try again.",
              backgroundColor: Colors.red,
            );
          }
        }
      });

      // Call pairing to start the process
      if (!_didManualPair) {
        await _tryPair(Uri.parse(wcUri));
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Connection failed: $e';
        _isConnecting = false;
        _hasError = true;
      });
      debugPrint('❌ Connection failed: $e');
    }
  }

  Future<bool> _tryPair(Uri uri) async {
    try {
      await walletKit.pair(uri: uri);
      return true;
    } catch (e) {
      debugPrint('❌ WalletKit pair failed: $e');
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _hasError = true;
          _statusMessage = '❌ Connection failed: $e';
        });
      }
      return false;
    }
  }

  Future<void> _disconnect() async {
    if (_session == null || _isDisconnecting) {
      return;
    }

    _isDisconnecting = true;
    try {
      await walletKit.disconnectSession(
        topic: _session!.topic,
        reason: Errors.getSdkError(Errors.USER_DISCONNECTED).toSignError(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _session = null;
        _statusMessage = '🔌 Disconnected.';
        _hasError = false;
      });
    } catch (e) {
      debugPrint('❌ Disconnect failed: $e');
    } finally {
      _isDisconnecting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _session != null;

    final isMobile = MediaQuery.of(context).size.width < 600;

    IconData icon;
    Color iconColor;
    Color textColor;
    Color backgroundColor;
    String text;

    if (isConnected) {
      icon = Icons.link_off;
      iconColor = Colors.redAccent;
      textColor = Colors.redAccent;
      backgroundColor = Colors.redAccent.withAlpha(26);
      text = 'Disconnect';
    } else if (_isConnecting) {
      icon = Icons.sync;
      iconColor = Colors.amber;
      textColor = Colors.amber;
      backgroundColor = Colors.amber.withAlpha(26);
      text = 'Connecting';
    } else if (_timedOut) {
      icon = Icons.timer_off;
      iconColor = Colors.orange;
      textColor = Colors.orange;
      backgroundColor = Colors.orange.withAlpha(26);
      text = 'Timed Out';
    } else if (_hasError) {
      icon = Icons.error_outline;
      iconColor = Colors.redAccent;
      textColor = Colors.redAccent;
      backgroundColor = Colors.redAccent.withAlpha(26);
      text = 'Retry Connect';
    } else {
      icon = Icons.link;
      iconColor = Colors.greenAccent;
      textColor = Colors.white;
      backgroundColor = GeniusWalletColors.deepBlueCardColor;
      text = 'Connect';
    }

    return SizedBox(
        width: isMobile ? 60 : 130,
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          onPressed: () {
            if (_isConnecting || _isDisconnecting) return;
            if (isConnected) {
              _disconnect();
            } else {
              _connect();
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedRotation(
                duration: const Duration(milliseconds: 600),
                turns: _isConnecting ? 1 : 0,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(fontSize: 14, color: textColor),
                ),
              ]
            ],
          ),
        ));
  }
}
