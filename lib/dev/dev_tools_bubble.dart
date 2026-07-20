import 'package:flutter/material.dart';
import 'package:genius_wallet/reown/test/test_buy_buttons.dart';
import 'package:genius_wallet/reown/test/test_swap_buttons.dart';
import 'package:genius_wallet/test/test_transaction_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

/// Draggable, dev-only overlay bubble (kDebugMode && kShowDevTools, gated at
/// the insertion site — see [responsive_overlay.dart]'s DesktopOverlay /
/// MobileOverlay). Replaces the old header-row [DevToolsWidget], which was
/// prepended to `_buildActionRowWidgets` and RenderFlex-overflowed
/// `_DesktopTopBar` at ~1240px. This widget is `Positioned` inside a `Stack`
/// overlaid on top of the app body, so it occupies ZERO layout space in the
/// real chrome.
///
/// Collapsed: a small circular FAB, draggable, tap to expand. Expanded: the
/// same dev actions the old row exposed (Test transaction/swap/buy,
/// Tokens/Gallery push targets) plus a light/dark appearance toggle using the
/// same `GWAppearance.instance.setMode` mechanism as the dev Gallery /
/// token-probe screens.
class DevToolsBubble extends StatefulWidget {
  const DevToolsBubble({super.key});

  @override
  State<DevToolsBubble> createState() => _DevToolsBubbleState();
}

class _DevToolsBubbleState extends State<DevToolsBubble> {
  static const double _collapsedSize = 48.0;
  static const double _panelWidth = 260.0;

  // Lazily initialised on first build (needs MediaQuery, unavailable in
  // initState). ponytail: not persisted across app restarts — dev-only, a
  // fresh corner position each launch is an acceptable ceiling.
  Offset? _position;
  bool _expanded = false;

  Offset _clamp(Offset offset, Size screenSize) {
    final maxX = (screenSize.width - _collapsedSize).clamp(0.0, double.infinity);
    final maxY = (screenSize.height - _collapsedSize).clamp(0.0, double.infinity);
    return Offset(offset.dx.clamp(0.0, maxX), offset.dy.clamp(0.0, maxY));
  }

  void _dragBy(Offset delta, Size screenSize) {
    setState(() {
      _position = _clamp((_position ?? Offset.zero) + delta, screenSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    _position ??= _clamp(
      Offset(
        GeniusWalletConsts.space8,
        screenSize.height - GeniusWalletConsts.space32 * 2,
      ),
      screenSize,
    );

    return ValueListenableBuilder<GWAppearanceMode>(
      valueListenable: GWAppearance.instance,
      builder: (context, mode, _) {
        final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
        final isLight = GWAppearance.isLight;
        final position = _clamp(_position!, screenSize);

        return Positioned(
          left: position.dx,
          top: position.dy,
          child: _expanded
              ? _buildExpandedPanel(context, gw, isLight)
              : _buildCollapsedBubble(gw),
        );
      },
    );
  }

  Widget _buildCollapsedBubble(GWColors gw) {
    return GestureDetector(
      onPanUpdate: (details) =>
          _dragBy(details.delta, MediaQuery.sizeOf(context)),
      onTap: () => setState(() => _expanded = true),
      child: Container(
        width: _collapsedSize,
        height: _collapsedSize,
        decoration: BoxDecoration(
          color: gw.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: gw.borderStrong),
        ),
        child: Icon(Icons.bug_report, color: gw.textPrimary),
      ),
    );
  }

  Widget _buildExpandedPanel(BuildContext context, GWColors gw, bool isLight) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _panelWidth,
        padding: const EdgeInsets.all(GeniusWalletConsts.space6),
        decoration: BoxDecoration(
          color: gw.surfaceMenu,
          border: Border.all(color: gw.borderSubtle),
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radius2xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onPanUpdate: (details) =>
                  _dragBy(details.delta, MediaQuery.sizeOf(context)),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    color: gw.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: GeniusWalletConsts.space2),
                  Text(
                    'Dev',
                    style: TextStyle(color: gw.textSecondary, fontSize: 14),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.close, color: gw.textSecondary, size: 18),
                    onPressed: () => setState(() => _expanded = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GeniusWalletConsts.space4),
            Wrap(
              spacing: GeniusWalletConsts.space2,
              runSpacing: GeniusWalletConsts.space2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const TestTransactionButton(),
                const TestSwapButtons(),
                const TestBuyButtons(),
                TextButton(
                  onPressed: () => context.push('/dev/token-probe'),
                  child: Text('Tokens', style: TextStyle(color: gw.textPrimary)),
                ),
                TextButton(
                  onPressed: () => context.push('/design_gallery'),
                  child: Text(
                    'Gallery',
                    style: TextStyle(color: gw.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GeniusWalletConsts.space4),
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: isLight ? 'Switch to dark' : 'Switch to light',
                  icon: Icon(
                    isLight ? Icons.dark_mode : Icons.light_mode,
                    color: gw.textPrimary,
                  ),
                  onPressed: () {
                    GWAppearance.instance.setMode(
                      isLight ? GWAppearanceMode.dark : GWAppearanceMode.light,
                    );
                  },
                ),
                Text(
                  isLight ? 'Light' : 'Dark',
                  style: TextStyle(color: gw.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
