import 'dart:async';
import 'dart:io';

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
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

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
  const ReownConnectButton({
    super.key,
    required this.walletAddress,
    required this.geniusApi,
    required this.walletDetailsCubit,
    required this.transactionsCubit,
  });

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
  bool _isInitialized = false;
  Completer<void>? _initCompleter;
  final TextEditingController _uriController = TextEditingController();
  bool _listenersAttached = false;
  void Function()? _sessionRequestDisposer;
  late final void Function(SessionConnect?) _sessionConnectHandler;
  late final void Function(SessionProposalEvent?) _sessionProposalHandler;

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

    _sessionRequestDisposer = handleDappRequests(
      walletKit: walletKit,
      geniusApi: widget.geniusApi,
      walletDetailsCubit: widget.walletDetailsCubit,
      transactionsCubit: widget.transactionsCubit,
    );

    _sessionConnectHandler = (event) {
      if (!mounted || event == null) return;

      setState(() {
        _session = event.session;
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

      setState(() {});

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
    if (_isInitialized) return;
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return;
    }
    _initCompleter = Completer<void>();
    try {
      await WalletKitInstance().initOnce();
      _isInitialized = true;
      debugPrint("✅ WalletKit initialized");
    } catch (e) {
      debugPrint("❌ WalletKit initialization failed: $e");
    } finally {
      _initCompleter!.complete();
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
    });

    await maybeInitWalletKit();

    if (!_isInitialized) {
      setState(() {
        _isConnecting = false;
        _hasError = true;
      });
      debugPrint('❌ Connection failed: WalletKit not initialized');
      if (mounted && context.mounted) {
        showAppSnackBar(
          context,
          "WalletKit failed to initialize. Please restart the app.",
          backgroundColor: Colors.red,
        );
      }
      return;
    }

    try {
      final CreateResponse pairingInfo = await walletKit.core.pairing.create();
      final wcUri = pairingInfo.uri.toString();
      debugPrint("🔗 WalletConnect URI: $wcUri");
      String? manualInputError;
      bool showManualInput = _isDesktopOrIot;

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setInnerState) => AlertDialog(
            backgroundColor: GeniusWalletColors.deepBlueTertiary,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/crypto/wallet-connect.png',
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Text("Wallet Connect"),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: GeniusBreakpoints.small * 1 / 2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    child: showManualInput
                        ? KeyedSubtree(
                            key: ValueKey(
                              "manual-${DateTime.now().millisecondsSinceEpoch}",
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  spacing: 8,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _uriController,
                                        decoration: InputDecoration(
                                          hintText: "wc:...",
                                          errorText: manualInputError,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.paste,
                                        color: GeniusWalletColors
                                            .lightGreenPrimary,
                                      ),
                                      tooltip: "Paste from clipboard",
                                      onPressed: () async {
                                        final data = await Clipboard.getData(
                                          Clipboard.kTextPlain,
                                        );
                                        if (data?.text != null &&
                                            data!.text!.trim().isNotEmpty) {
                                          setInnerState(() {
                                            _uriController.text = data.text!
                                                .trim();
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
                              ],
                            ),
                          )
                        : KeyedSubtree(
                            key: ValueKey(
                              "qr-${DateTime.now().millisecondsSinceEpoch}",
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 250,
                                maxHeight: 250,
                              ),
                              child: QrImageView(
                                backgroundColor: Colors.white,
                                data: wcUri,
                                version: QrVersions.auto,
                              ),
                            ),
                          ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setInnerState(() => showManualInput = !showManualInput);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    icon: const Icon(
                      Icons.link,
                      color: GeniusWalletColors.lightGreenPrimary,
                    ),
                    label: Text(
                      showManualInput ? "Show QR Code" : "Enter URI Manually",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() => _isConnecting = false);
                },
                child: const Text("Cancel"),
              ),
              if (showManualInput)
                FilledButton(
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
                  child: const Text("Connect"),
                ),
            ],
          ),
        ),
      );

      if (_session == null) {
        setState(() {
          _isConnecting = false;
        });
      }

      Future.delayed(const Duration(seconds: 15), () {
        if (_isConnecting && _session == null && mounted) {
          setState(() {
            _isConnecting = false;
            _hasError = true;
            _timedOut = true;
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

    final isMobile = MediaQuery.sizeOf(context).width < GeniusBreakpoints.small;

    IconData icon;
    Color iconColor;
    Color textColor;
    Color backgroundColor;
    String text;

    if (isConnected) {
      icon = Icons.link_off;
      iconColor = Colors.redAccent;
      textColor = Colors.redAccent;
      backgroundColor = Colors.redAccent.withValues(alpha: 0.1);
      text = 'Disconnect';
    } else if (_isConnecting) {
      icon = Icons.sync;
      iconColor = Colors.amber;
      textColor = Colors.amber;
      backgroundColor = Colors.amber.withValues(alpha: 0.1);
      text = 'Connecting';
    } else if (_timedOut) {
      icon = Icons.timer_off;
      iconColor = Colors.orange;
      textColor = Colors.orange;
      backgroundColor = Colors.orange.withValues(alpha: 0.1);
      text = 'Timed Out';
    } else if (_hasError) {
      icon = Icons.error_outline;
      iconColor = Colors.redAccent;
      textColor = Colors.redAccent;
      backgroundColor = Colors.redAccent.withValues(alpha: 0.1);
      text = 'Retry Connect';
    } else {
      icon = Icons.link;
      iconColor = Colors.greenAccent;
      textColor = Colors.white;
      backgroundColor = GeniusWalletColors.deepBlueCardColor;
      text = 'Connect';
    }

    final btn = TextButton(
      style: TextButton.styleFrom(backgroundColor: backgroundColor),
      onPressed: () {
        if (_isConnecting || _isDisconnecting) return;

        if (isConnected) {
          _disconnect();
        } else {
          _connect();
        }
      },
      child: Row(
        spacing: 6,
        children: [
          AnimatedRotation(
            duration: const Duration(milliseconds: 600),
            turns: _isConnecting ? 1 : 0,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          if (!isMobile)
            Text(text, style: TextStyle(fontSize: 14, color: textColor)),
        ],
      ),
    );

    return isMobile ? Tooltip(message: text, child: btn) : btn;
  }
}
