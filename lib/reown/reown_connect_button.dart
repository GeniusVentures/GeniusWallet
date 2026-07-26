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
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/nav_chip_style.dart';
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
          backgroundColor: GeniusWalletColors.statusError,
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
            backgroundColor:
                Theme.of(ctx).extension<GWColors>()?.surfaceElevated ??
                    GWColors.dark().surfaceElevated,
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
                                        color: GeniusWalletColors.brandPrimary,
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
                      color: GeniusWalletColors.brandPrimary,
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
              backgroundColor: GeniusWalletColors.statusError,
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
    // Appearance-aware read IS needed here: light's surfaceElevated is pure
    // white, and raw brandPrimaryStrong on white is 2.56:1 (fails AA) -- see
    // connectBrandColor. Every branch below now shares one visual language
    // (transparent fill + 1px state-coloured outline), decided 2026-07-26,
    // sketch 039-B -- so this appearance read only matters for idle's brand
    // colour.
    final isConnected = _session != null;

    final isMobile = MediaQuery.sizeOf(context).width < GeniusBreakpoints.small;

    IconData icon;
    Color stateColor;
    String text;

    if (isConnected) {
      icon = Icons.link_off;
      stateColor = GeniusWalletColors.statusError;
      text = 'Disconnect';
    } else if (_isConnecting) {
      icon = Icons.sync;
      stateColor = GeniusWalletColors.statusWarning;
      text = 'Connecting';
    } else if (_timedOut) {
      icon = Icons.timer_off;
      stateColor = GeniusWalletColors.statusWarning;
      text = 'Timed Out';
    } else if (_hasError) {
      icon = Icons.error_outline;
      stateColor = GeniusWalletColors.statusError;
      text = 'Retry Connect';
    } else {
      // Appearance-aware brand outline & text/icon so it clears AA in BOTH
      // modes (dark = brandPrimaryStrong, light = a darker brand -- see
      // connectBrandColor). Connection logic (_connect/_disconnect) is
      // untouched.
      icon = Icons.link;
      stateColor = connectBrandColor(context);
      text = 'Connect';
    }

    // Sketch 043 variant 4A. This is the FOURTH FIELD inside the navbar's
    // control track, so it takes the track's chip geometry (36px, pill) and —
    // like its three neighbours — carries NO fill and NO border of its own.
    // The track is the one fill and the one hairline.
    //
    // State is carried by a dot plus the label colour. The IDLE branch, and
    // only the idle branch, paints its label and dot with the brand gradient:
    // idle is the one state that INVITES a click, while the other three report
    // a status a brand gradient cannot express. That keeps the brand accent in
    // the bar without adding a surface to a side we just cleared of its CTA.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final bool isIdle =
        !isConnected && !_isConnecting && !_timedOut && !_hasError;
    final iconColor = stateColor;
    final textColor = stateColor;

    final btn = TextButton(
      style: navContextChipStyle(context).copyWith(
        overlayColor: WidgetStatePropertyAll(
          stateColor.withValues(alpha: 0.16),
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
        spacing: GeniusWalletConsts.space4,
        children: [
          // The connecting spinner keeps its icon — a rotating mark is the one
          // thing a static dot cannot say. Every settled state shows the dot,
          // which is quieter and is what carries the colour.
          if (_isConnecting)
            AnimatedRotation(
              duration: const Duration(milliseconds: 600),
              turns: 1,
              child: Icon(icon, color: iconColor, size: 16),
            )
          else
            _StateDot(color: isIdle ? null : stateColor, gw: gw),
          if (!isMobile)
            // Idle gets the gradient; the status branches get their flat
            // colour. ShaderMask paints the child's alpha with the shader, so
            // the Text colour below only has to be non-transparent.
            if (isIdle)
              ShaderMask(
                shaderCallback: (bounds) =>
                    GeniusWalletGradient.brandCtaText(gw.surfaceMenu)
                        .createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: const Text(
                  'Connect',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              )
            else
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
        ],
      ),
    );

    return isMobile ? Tooltip(message: text, child: btn) : btn;
  }
}

/// The 9px state mark in the navbar's Connect field (sketch 043 variant 4A).
///
/// A null [color] means the IDLE branch, which paints the brand gradient
/// instead of a flat colour — same rule as the label beside it, so the two
/// marks can never disagree about which state they are showing.
class _StateDot extends StatelessWidget {
  const _StateDot({required this.color, required this.gw});

  final Color? color;
  final GWColors gw;

  @override
  Widget build(BuildContext context) {
    final Color? flat = color;
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: flat,
        gradient: flat == null
            ? GeniusWalletGradient.brandCtaText(gw.surfaceMenu)
            : null,
      ),
    );
  }
}
