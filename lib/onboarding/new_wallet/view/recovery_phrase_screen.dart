import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

class RecoveryPhraseScreen extends StatefulWidget {
  const RecoveryPhraseScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RecoveryPhraseScreenState();
  }
}

class _RecoveryPhraseScreenState extends State<RecoveryPhraseScreen> {
  bool _isVisible = true;

  /// Explicitly owned so the [Scrollbar] and its [SingleChildScrollView] share
  /// one position. Without this the Scrollbar falls back to
  /// PrimaryScrollController, which is NOT attached on desktop for a vertical
  /// ScrollView — it then throws "Scrollbar's ScrollController has no
  /// ScrollPosition attached" on every paint. Caught in the 06-03 walk from the
  /// console; scrolling still worked, so it was invisible on screen.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final isNarrow = MediaQuery.sizeOf(context).width < GeniusBreakpoints.small;
    context.read<NewWalletBloc>().add(LoadRecoveryPhrase());
    return Center(
      // Walk-driven (06-03 Task 3): this screen shipped the systemic onboarding
      // gutter bug — ConstrainedBox(maxWidth:) is inert once the viewport is
      // narrower than it, so content ran edge-to-edge with zero inset. Same
      // pattern and token as 06-01's fix (67e2821) and 06-02's two screens:
      // Padding OUTSIDE the ConstrainedBox, so the gutter is additive and the
      // wide-window centring is unchanged by construction.
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space8,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GeniusBreakpoints.small),
          // Walk-driven (06-03 Task 3): develop shipped this screen with no
          // scroll view, so once the grid went two-column on mobile the content
          // overflowed the viewport vertically. The verify screen already has a
          // SingleChildScrollView; this makes the pair consistent. Scrollbar is
          // explicit so desktop users get a visible affordance.
          child: Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16.0,
                children: [
                  Text(
                    "Your Recovery Phrase",
                    style: GeniusWalletTypography.headlineLg.copyWith(
                      color: gw.textPrimary,
                    ),
                  ),
                  Text(
                    "Write down this 12-word Secret Recovery Phrase and save it in a place that you trust and only you can access.",
                    style: GeniusWalletTypography.bodyMd.copyWith(
                      color: gw.textSecondary,
                    ),
                  ),
                  _buildWordsGridWithCopyAndToggle(),
                  // Walk-driven: full-width CTA on mobile; the 300px cap is a
                  // desktop affordance and looked stranded on a phone.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isNarrow ? double.infinity : 300,
                    ),
                    child: GWButton(
                      label: 'Continue',
                      variant: GWButtonVariant.gradient,
                      size: GWButtonSize.lg,
                      expand: true,
                      onPressed: () {
                        context.read<NewWalletBloc>().add(
                          RecoveryPhraseContinue(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordsGridWithCopyAndToggle() {
    return BlocBuilder<NewWalletBloc, NewWalletState>(
      builder: (context, state) {
        final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

        if (state.recoveryPhraseStatus != NewWalletStatus.loaded) {
          return const Center(child: Loading());
        }

        final words = state.recoveryWords;

        // Freeze rule (test/freeze_rule_test.dart): no dimension may be derived
        // CONTINUOUSLY from constraints. This replaces a FittedBox(scaleDown),
        // which ran a per-frame scale search on every drag-resize — the same
        // defect that hung the app from the dashboard chart. The size below is
        // a discrete choice between exactly TWO tokens, so the set is bounded.
        //
        // Deliberately NOT ellipsised: truncating a recovery word makes it
        // unreadable, and this is the one screen where that is unacceptable.
        // bodySm (14) is sized so the longest possible tile string — "01. " +
        // an 8-character BIP-39 word, monospace — still fits the narrow tile.
        final isNarrow =
            MediaQuery.sizeOf(context).width < GeniusBreakpoints.small;
        final wordStyle =
            (isNarrow
                    ? GeniusWalletTypography.bodySm
                    : GeniusWalletTypography.bodyLg)
                .copyWith(fontFamily: "JetBrainsMono", color: gw.textPrimary);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8.0,
          children: [
            Container(
              decoration: GWDecorations.surface(
                radius: GeniusWalletConsts.radiusLg,
                border: gw.borderSubtle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.count(
                  shrinkWrap: true,
                  // Walk-driven (06-03 Task 3): at 3 columns the narrow tile is
                  // too tight for a long BIP-39 word and the text was clipping.
                  // Two columns buys ~60% more tile width; the aspect ratio is
                  // raised in step so six rows do not grow the grid vertically.
                  // Both values are discrete literals — freeze rule holds.
                  crossAxisCount: isNarrow ? 2 : 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: isNarrow ? 4.5 : 3.0,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(words.length, (index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          GeniusWalletConsts.radiusMd,
                        ),
                        border: Border.all(color: gw.borderSubtle, width: 1.0),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '${(index + 1).toString().padLeft(2, '0')}. ${_isVisible ? words[index] : '••••••'}',
                        maxLines: 1,
                        style: wordStyle,
                      ),
                    );
                  }),
                ),
              ),
            ),
            // Walk-driven (06-03 Task 3): a Row overflowed at narrow widths.
            // On mobile both actions go full-width and stack; on desktop they
            // keep develop's side-by-side spaceBetween pairing. The branch is a
            // boolean, so no dimension is derived continuously (freeze rule).
            _CopyAndToggleActions(
              isNarrow: isNarrow,
              copyButton: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: gw.textSecondary),
                onPressed: () async {
                  await FlutterClipboard.copy(words.join(' '));
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Recovery phrase copied to clipboard!"),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text("Copy to clipboard"),
              ),
              toggleButton: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: gw.textSecondary),
                onPressed: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                },
                icon: Icon(
                  _isVisible ? Icons.visibility_off : Icons.visibility,
                ),
                label: Text(
                  _isVisible ? "Hide seed phrase" : "Show seed phrase",
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Lays out the Copy and hide/show actions.
///
/// Desktop keeps develop's shipped pairing — one row, `spaceBetween`. Mobile
/// stacks them full-width, because at narrow widths the row overflowed and two
/// half-width icon buttons are an awkward tap target on a phone.
///
/// The two buttons are passed in already built so this widget makes no
/// decisions about their behaviour — in particular the copy handler's
/// `if (!mounted) return;` guard stays in the State that owns it.
class _CopyAndToggleActions extends StatelessWidget {
  const _CopyAndToggleActions({
    required this.isNarrow,
    required this.copyButton,
    required this.toggleButton,
  });

  final bool isNarrow;
  final Widget copyButton;
  final Widget toggleButton;

  @override
  Widget build(BuildContext context) {
    if (isNarrow) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        // Walk-driven: stacked full-width buttons read as one blob without a
        // gap between them.
        spacing: GeniusWalletConsts.space4,
        children: [
          SizedBox(width: double.infinity, child: copyButton),
          SizedBox(width: double.infinity, child: toggleButton),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [copyButton, toggleButton],
    );
  }
}
