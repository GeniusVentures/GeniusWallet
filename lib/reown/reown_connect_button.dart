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
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/test/dev_overrides.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/qr_scanner/gw_qr_scanner.dart';
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
            backgroundColor: GeniusWalletColors.statusError,
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
      String wcUri;
      bool usedDemoUri = false;
      try {
        final CreateResponse pairingInfo = await walletKit.core.pairing
            .create()
            .timeout(const Duration(seconds: 8));
        wcUri = pairingInfo.uri.toString();
      } catch (pairErr) {
        // No live WalletConnect relay reachable (e.g. the UI-only mock / QA
        // build, where the native stack is stubbed) — fall back to a demo URI
        // so the connect drawer (QR + paste + Scan QR Code) stays operable for
        // verification. Production builds (no WALLET_PK) rethrow so a real
        // failure still surfaces to the user.
        if (walletPK.isEmpty) rethrow;
        usedDemoUri = true;
        debugPrint(
            "⚠️ pairing.create() failed in mock build ($pairErr) — using demo URI");
        wcUri = 'wc:demo-mock@2?relay-protocol=irn&symKey=demo';
      }
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
                  excludeFromSemantics: true,
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space6),
              Text(
                "Wallet Connect",
                style: GeniusWalletTypography.titleLg,
              ),
            ]),
            content: SizedBox(
              width: 300,
              height: 320,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: GeniusWalletConsts.space6),
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
                                        decoration: InputDecoration(
                                          hintText: "wc:...",
                                          hintStyle: TextStyle(
                                              color: GeniusWalletColors
                                                  .textPrimary38),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: GeniusWalletConsts.space4),
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
                                  const SizedBox(
                                      height: GeniusWalletConsts.space4),
                                  Text(
                                    manualInputError!,
                                    style: const TextStyle(
                                        color: GeniusWalletColors.statusError),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ))
                        : KeyedSubtree(
                            key: ValueKey(
                                "qr-${DateTime.now().millisecondsSinceEpoch}"),
                            child: QrImageView(
                              // Always white: QR quiet zones must stay light
                              // for scanners — textPrimary flips to near-black
                              // in light mode and made the code unreadable.
                              backgroundColor: Colors.white,
                              data: wcUri,
                              version: QrVersions.auto,
                            ),
                          ),
                  )),
                  const SizedBox(height: GeniusWalletConsts.space8),
                  TextButton(
                    onPressed: () {
                      setInnerState(() => showManualInput = !showManualInput);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: GeniusWalletConsts.space6,
                          vertical: GeniusWalletConsts.space2),
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
                        const SizedBox(width: GeniusWalletConsts.space4),
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
                  // Scan a dApp's WalletConnect QR with the camera.
                  TextButton(
                    onPressed: () async {
                      final scanned = await GWQrScanner.show(
                        context,
                        title: 'Scan to connect',
                        hint: 'Point at a WalletConnect QR code on the dApp',
                        accept: (raw) => raw.startsWith('wc:') ? raw : null,
                      );
                      if (scanned == null) return;
                      try {
                        final paired = await _tryPair(Uri.parse(scanned));
                        if (paired) {
                          _didManualPair = true;
                          if (context.mounted) Navigator.of(context).pop();
                        } else {
                          setInnerState(() => manualInputError =
                              '❌ Failed to start WalletConnect session.');
                        }
                      } catch (e) {
                        debugPrint('❌ Scan pair failed: $e');
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_scanner,
                            size: 18,
                            color: GeniusWalletColors.lightGreenPrimary),
                        SizedBox(width: GeniusWalletConsts.space4),
                        Text('Scan QR Code',
                            style: TextStyle(
                              color: GeniusWalletColors.gray500,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  GeniusWalletColors.lightGreenPrimary,
                              decorationThickness: 2.0,
                              fontWeight: FontWeight.w600,
                            )),
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
                            color: GeniusWalletColors.textOnBrand,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height: GeniusWalletConsts.space4,
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
              backgroundColor: GeniusWalletColors.statusError,
            );
          }
        }
      });

      // Call pairing to start the process. Skip when we fell back to the demo
      // URI (mock build) — it can't pair against a live relay.
      if (!_didManualPair && !usedDemoUri) {
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
      icon = Icons.link_off_rounded;
      iconColor = GeniusWalletColors.statusError;
      textColor = GeniusWalletColors.statusError;
      backgroundColor = GeniusWalletColors.statusError.withAlpha(38);
      text = 'Disconnect';
    } else if (_isConnecting) {
      icon = Icons.sync_rounded;
      iconColor = GeniusWalletColors.statusWarning;
      textColor = GeniusWalletColors.statusWarning;
      backgroundColor = GeniusWalletColors.statusWarning.withAlpha(38);
      text = 'Connecting';
    } else if (_timedOut) {
      icon = Icons.timer_off_rounded;
      iconColor = GeniusWalletColors.statusWarning;
      textColor = GeniusWalletColors.statusWarning;
      backgroundColor = GeniusWalletColors.statusWarning.withAlpha(38);
      text = 'Timed Out';
    } else if (_hasError) {
      icon = Icons.error_outline_rounded;
      iconColor = GeniusWalletColors.statusError;
      textColor = GeniusWalletColors.statusError;
      backgroundColor = GeniusWalletColors.statusError.withAlpha(38);
      text = 'Retry';
    } else {
      icon = Icons.qr_code_scanner_rounded;
      iconColor = GeniusWalletColors.brandPrimary;
      textColor = GeniusWalletColors.textPrimary;
      backgroundColor = GeniusWalletColors.surfaceElevated;
      text = 'Connect';
    }

    return SizedBox(
        width: isMobile ? 44 : 130,
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.space4, vertical: 6),
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
                  style:
                      GeniusWalletTypography.bodyMd.copyWith(color: textColor),
                ),
              ]
            ],
          ),
        ));
  }
}
