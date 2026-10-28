import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genius_wallet/components/overlay/mobile_header.dart'
    show kHeaderControlSize;
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/reown/pair_dapp_drawer.dart';
import 'package:genius_wallet/reown/reown_walletkit_instance.dart';
import 'package:genius_wallet/reown/wallet_connect_host.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/theme/nav_chip_style.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

class ReownConnectButton extends StatefulWidget {
  const ReownConnectButton({super.key});

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
  late final WalletConnectHost _host;
  bool _listenersAttached = false;
  late final void Function(SessionConnect?) _sessionConnectHandler;

  @override
  void initState() {
    super.initState();
    _host = context.read<WalletConnectHost>();
    _initializeWalletKit();
  }

  @override
  void dispose() {
    if (_listenersAttached) {
      walletKit.onSessionConnect.unsubscribe(_sessionConnectHandler);
      _listenersAttached = false;
    }
    super.dispose();
  }

  Future<void> _initializeWalletKit() async {
    if (!await _host.start()) {
      return;
    }

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

    _sessionConnectHandler = (event) {
      if (!mounted || event == null) {
        return;
      }

      setState(() {
        _session = event.session;
        _isConnecting = false;
        _hasError = false;
        _timedOut = false;
      });
      debugPrint("✅ Connected to ${event.session.peer.metadata.name}");
    };
    walletKit.onSessionConnect.subscribe(_sessionConnectHandler);
    _listenersAttached = true;
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

    final started = await _host.start();

    if (!started) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isConnecting = false;
        _hasError = true;
      });
      debugPrint('❌ Connection failed: WalletKit not initialized');
      if (context.mounted) {
        showToast(
          context,
          "WalletConnect couldn't start. Check your connection, then try "
          "again.",
          type: ToastType.error,
        );
      }
      return;
    }

    // Init may have just succeeded on this press after an earlier failure --
    // attach the session listeners now (idempotent, no-op if already done).
    _attachWalletKitListeners();

    try {
      final CreateResponse pairingInfo = await walletKit.core.pairing.create();
      // The pairing URI carries a symKey — it goes to the QR and the manual
      // copy field, never to the console.
      final wcUri = pairingInfo.uri.toString();

      if (!mounted) {
        return;
      }

      await PairDappDrawer.show(
        context: context,
        wcUri: wcUri,
        startWithPaste: true,
        onPair: (uri) async {
          final paired = await _tryPair(uri);
          if (paired) {
            _didManualPair = true;
          }
          return paired;
        },
      );

      if (!mounted) {
        return;
      }

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
            showToast(
              context,
              "Wallet connection failed. Please try again.",
              type: ToastType.error,
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
      // walletKit.pair and Uri.parse can quote the link in their exception,
      // and the link carries a symKey -- log the type only.
      debugPrint('❌ Connection failed: ${e.runtimeType}');
    }
  }

  Future<bool> _tryPair(Uri uri) async {
    try {
      await walletKit.pair(uri: uri);
      return true;
    } catch (e) {
      debugPrint('❌ WalletKit pair failed: ${e.runtimeType}');
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

    final isMobile = !GeniusBreakpoints.useDesktopLayout(context);

    IconData icon;
    Color stateColor;
    String text;

    if (isConnected) {
      icon = Icons.link_off;
      stateColor = context.gw.statusErrorText;
      text = 'Disconnect';
    } else if (_isConnecting) {
      icon = Icons.sync;
      stateColor = context.gw.statusWarningText;
      text = 'Connecting';
    } else if (_timedOut) {
      icon = Icons.timer_off;
      stateColor = context.gw.statusWarningText;
      text = 'Timed Out';
    } else if (_hasError) {
      icon = Icons.error_outline;
      stateColor = context.gw.statusErrorText;
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
    final textColor = stateColor;

    void onPressed() {
      if (_isConnecting || _isDisconnecting) {
        return;
      }

      if (isConnected) {
        _disconnect();
      } else {
        _connect();
      }
    }

    // Phones: the state's own glyph in a header-sized box. The tooltip is
    // also the control's semantic label.
    if (isMobile) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: kHeaderControlSize,
          height: kHeaderControlSize,
        ),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(icon, size: 24),
        color: stateColor,
        tooltip: text,
        onPressed: onPressed,
      );
    }

    return TextButton(
      style: navContextChipStyle(context).copyWith(
        overlayColor: WidgetStatePropertyAll(
          stateColor.withValues(alpha: 0.16),
        ),
      ),
      onPressed: onPressed,
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
              child: Icon(icon, color: stateColor, size: 16),
            )
          else
            _StateDot(color: isIdle ? null : stateColor, gw: gw),
          // Idle gets the gradient; the status branches get their flat
          // colour. ShaderMask paints the child's alpha with the shader, so
          // the Text colour below only has to be non-transparent.
          if (isIdle)
            ShaderMask(
              shaderCallback: (bounds) => GeniusWalletGradient.brandCtaText(
                gw.surfaceMenu,
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              // Fixed white regardless of appearance: BlendMode.srcIn
              // recolors every opaque pixel with the shader above, using
              // only this text's alpha channel -- the RGB value never
              // reaches the screen (same pattern as GWButton's
              // gradientOutline pre-mask placeholder).
              child: Text(
                'Connect',
                style: GeniusWalletTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          else
            Text(
              text,
              style: GeniusWalletTypography.labelMd.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
        ],
      ),
    );
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
