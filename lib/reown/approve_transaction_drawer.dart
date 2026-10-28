import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

class ApproveTransactionDrawer {
  static Future<bool?> show({
    required BuildContext context,
    required Widget content,
    required String dappName,
    required String dappUrl,
    String? iconUrl,
    String title = "Transaction Request",
  }) async {
    final gw = context.gw;
    return ResponsiveDrawer.show<bool>(
      context: context,
      title: title,
      child: ListView(
        children: [
          // `Flexible(child: content)` below needs a Flex ancestor -- a bare
          // `ListView.children` list is a sliver list, not a Flex, so this
          // Column (not the deleted zero-inset Padding) is what the shell's
          // single scrolling body item actually is.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 033-B1: the dApp identity is borderless -- favicon, url, a
              // hairline under it, no pill, no box. The bordered Container
              // this used to sit in is gone.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (iconUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        GeniusWalletConsts.radiusPill,
                      ),
                      // The errorBuilder collapsing to nothing is a mitigation
                      // (T-21-12), not decoration: it stops a hostile dApp
                      // placing a broken-image glyph or an oversized
                      // failed-load box on a signing prompt.
                      child: Image.network(
                        iconUrl,
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(width: GeniusWalletConsts.space6),
                  ],
                  // Wraps rather than ellipsizes: a look-alike origin must be
                  // readable whole on a prompt that asks for consent.
                  Flexible(
                    child: Text(
                      dappUrl,
                      style: GeniusWalletTypography.bodyMd.copyWith(
                        color: gw.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GeniusWalletConsts.space4),
              Container(height: 1, color: gw.borderSubtle),
              const SizedBox(height: GeniusWalletConsts.space6),
              // `content` is caller-supplied and must keep rendering whatever
              // it is handed -- this drawer does not know or care which body
              // it was given.
              Flexible(fit: FlexFit.loose, child: content),
            ],
          ),
        ],
      ),
      // The drawer's own context, not the caller's: each button answers for
      // this route only, never for whatever sits on top of it.
      footer: Builder(
        builder: (drawerContext) => Row(
          children: [
            Expanded(
              child: GWButton(
                label: "Reject",
                variant: GWButtonVariant.gradientOutline,
                size: GWButtonSize.sm,
                expand: true,
                onPressed: () => ResponsiveDrawer.close(drawerContext, false),
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            Expanded(
              child: _ArmedApproveButton(
                onPressed: () => ResponsiveDrawer.close(drawerContext, true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const Duration _armDelay = Duration(milliseconds: 500);

/// Approve stays disabled until its drawer has finished opening, plus
/// [_armDelay]. The page that asked decides when the drawer appears, so a
/// click it baited could otherwise land on Approve as the drawer slides in.
class _ArmedApproveButton extends StatefulWidget {
  const _ArmedApproveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_ArmedApproveButton> createState() => _ArmedApproveButtonState();
}

class _ArmedApproveButtonState extends State<_ArmedApproveButton>
    with SingleTickerProviderStateMixin {
  // A ticker rather than a Timer, so tests that settle the drawer also arm it.
  late final AnimationController _arming =
      AnimationController(vsync: this, duration: _armDelay)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() {});
          }
        });
  Animation<double>? _entrance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final entrance = ModalRoute.of(context)?.animation;
    if (entrance == _entrance) {
      return;
    }
    _entrance?.removeStatusListener(_onEntrance);
    _entrance = entrance;
    if (entrance == null || entrance.isCompleted) {
      _arming.forward();
    } else {
      entrance.addStatusListener(_onEntrance);
    }
  }

  void _onEntrance(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _arming.forward();
    }
  }

  @override
  void dispose() {
    _entrance?.removeStatusListener(_onEntrance);
    _arming.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GWButton(
    label: "Approve",
    variant: GWButtonVariant.gradient,
    size: GWButtonSize.sm,
    expand: true,
    onPressed: _arming.isCompleted ? widget.onPressed : null,
  );
}
