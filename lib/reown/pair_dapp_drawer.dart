import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// The QR / paste-a-link surface for starting a WalletConnect pairing --
/// a [ResponsiveDrawer], replacing the old raw `AlertDialog` so the connect
/// flow reads as one surface through to the approve drawer that follows it.
class PairDappDrawer {
  static Future<void> show({
    required BuildContext context,
    required String wcUri,
    required bool startWithPaste,
    required Future<bool> Function(Uri uri) onPair,
  }) {
    // Body and footer are siblings under ResponsiveDrawer -- these three
    // notifiers are the only state either side needs, and the one place
    // that creates them is the one place that disposes them below.
    final controller = TextEditingController();
    final showPaste = ValueNotifier<bool>(startWithPaste);
    final fieldError = ValueNotifier<String?>(null);

    return ResponsiveDrawer.show<void>(
      context: context,
      title: 'WalletConnect',
      child: _PairDappBody(
        wcUri: wcUri,
        controller: controller,
        showPaste: showPaste,
        fieldError: fieldError,
      ),
      footer: _PairDappFooter(
        controller: controller,
        showPaste: showPaste,
        fieldError: fieldError,
        onPair: onPair,
      ),
    );
    // Disposal lives in _PairDappFooterState.dispose(), not chained here --
    // show()'s route resolves this future as soon as pop() is called, which
    // is BEFORE the dialog/sheet's own exit animation finishes, and the
    // still-visible field would race a disposed controller. A State's own
    // dispose() only runs once Flutter actually unmounts the drawer.
  }
}

class _PairDappBody extends StatelessWidget {
  const _PairDappBody({
    required this.wcUri,
    required this.controller,
    required this.showPaste,
    required this.fieldError,
  });

  final String wcUri;
  final TextEditingController controller;
  final ValueNotifier<bool> showPaste;
  final ValueNotifier<String?> fieldError;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showPaste,
      builder: (context, paste, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: GeniusWalletConsts.space6,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: paste
                  ? _PasteView(
                      key: const ValueKey('paste'),
                      controller: controller,
                      fieldError: fieldError,
                    )
                  : _QrView(key: const ValueKey('qr'), wcUri: wcUri),
            ),
            GWButton(
              variant: GWButtonVariant.ghost,
              label: paste ? 'Show QR Code' : 'Enter URI Manually',
              onPressed: () => showPaste.value = !paste,
            ),
          ],
        );
      },
    );
  }
}

class _PasteView extends StatelessWidget {
  const _PasteView({
    super.key,
    required this.controller,
    required this.fieldError,
  });

  final TextEditingController controller;
  final ValueNotifier<String?> fieldError;

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) {
      controller.text = text;
      fieldError.value = null;
    } else {
      fieldError.value = 'Clipboard is empty or has no text.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: fieldError,
      builder: (context, errorText, _) {
        final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
        return GWTextField(
          controller: controller,
          hint: 'wc:…',
          errorText: errorText,
          // A drawer field: the lighter fill on the panel, and the ring's
          // control-strength edge, since the fill alone cannot mark the input.
          fill: gw.surfaceMenu,
          focusRing: true,
          // An opaque, case-sensitive link: a capitalised `Wc:` fails the
          // scheme check, and the keyboard must not learn or suggest it.
          keyboardType: TextInputType.url,
          textCapitalization: TextCapitalization.none,
          autocorrect: false,
          enableSuggestions: false,
          enableIMEPersonalizedLearning: false,
          suffix: GWButton.icon(
            icon: const Icon(Icons.paste),
            tooltip: 'Paste from clipboard',
            onPressed: _paste,
          ),
        );
      },
    );
  }
}

class _QrView extends StatelessWidget {
  const _QrView({super.key, required this.wcUri});

  final String wcUri;

  @override
  Widget build(BuildContext context) {
    // Centred: the drawer is wider than the 250px code on desktop.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250, maxHeight: 250),
        child: QrImageView(
          // Fixed white regardless of appearance: a QR code needs a light
          // quiet zone around its dark modules to scan reliably -- a
          // scannability requirement, not a style choice.
          // raw-color-ok: fixed white quiet zone, required for scan reliability
          backgroundColor: Colors.white,
          data: wcUri,
          version: QrVersions.auto,
        ),
      ),
    );
  }
}

/// A `StatefulWidget` (not the body's `ValueListenableBuilder` shape) because
/// Connect owns its own in-flight `isLoading` state, on top of the shared
/// view/error notifiers.
class _PairDappFooter extends StatefulWidget {
  const _PairDappFooter({
    required this.controller,
    required this.showPaste,
    required this.fieldError,
    required this.onPair,
  });

  final TextEditingController controller;
  final ValueNotifier<bool> showPaste;
  final ValueNotifier<String?> fieldError;
  final Future<bool> Function(Uri uri) onPair;

  @override
  State<_PairDappFooter> createState() => _PairDappFooterState();
}

class _PairDappFooterState extends State<_PairDappFooter> {
  bool _isConnecting = false;

  @override
  void dispose() {
    widget.controller.dispose();
    widget.showPaste.dispose();
    widget.fieldError.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_isConnecting) {
      return;
    }
    final text = widget.controller.text.trim();
    if (!text.startsWith('wc:') || !text.contains('@')) {
      widget.fieldError.value = 'That is not a WalletConnect link.';
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    // The link carries a symKey, so on any outcome only a fixed string
    // reaches the screen -- never the link itself or an exception's text.
    try {
      final paired = await widget.onPair(Uri.parse(text));
      if (!mounted) {
        return;
      }
      if (paired) {
        Navigator.of(context).pop();
        return;
      }
      widget.fieldError.value = "Couldn't start the connection. Try again.";
    } catch (_) {
      if (!mounted) {
        return;
      }
      widget.fieldError.value = "Couldn't start the connection. Try again.";
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.showPaste,
      builder: (context, paste, _) {
        return Row(
          children: [
            Expanded(
              child: GWButton(
                label: 'Cancel',
                variant: GWButtonVariant.gradientOutline,
                size: GWButtonSize.md,
                expand: true,
                onPressed: _isConnecting
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
            ),
            if (paste) ...[
              const SizedBox(width: GeniusWalletConsts.space6),
              Expanded(
                child: GWButton(
                  label: 'Connect',
                  variant: GWButtonVariant.gradient,
                  size: GWButtonSize.md,
                  expand: true,
                  isLoading: _isConnecting,
                  onPressed: _isConnecting ? null : _connect,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
