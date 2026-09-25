import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/pin_cubit.dart';
import 'package:genius_wallet/bloc/pin_state.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/formatters.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinScreen extends StatelessWidget {
  final String title;

  /// Typed `void Function(String)` DELIBERATELY, not `Function(String)`.
  ///
  /// With a dynamic return type, `onPressed: onCompleted(...)` compiles — it
  /// CALLS onCompleted during build() and assigns its null return to
  /// onPressed. That is exactly what develop shipped, which left the Continue
  /// button permanently disabled in all four renders of this screen while the
  /// flow advanced as a build-phase side effect.
  ///
  /// With `void` as the return type the analyzer rejects that form outright,
  /// so the defect class cannot silently return. Both call sites already pass
  /// `void Function(String)`, so this costs nothing.
  final void Function(String) onCompleted;

  const PinScreen({super.key, required this.title, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final isNarrow = MediaQuery.sizeOf(context).width < GeniusBreakpoints.small;

    return Center(
      // Systemic onboarding gutter fix — this is the LAST of the screens named
      // by the carried-forward todo. Padding OUTSIDE the ConstrainedBox so the
      // inset is additive and wide-window centring is unchanged by
      // construction (06-01, 67e2821).
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space8,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GeniusBreakpoints.small),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text(
                title,
                style: GeniusWalletTypography.headlineLg.copyWith(
                  color: gw.textPrimary,
                ),
              ),
              MaterialPinField(
                length: GeniusWalletConsts.pinCount,
                obscureText: true,
                onChanged: context.read<PinCubit>().desktopOnChanged,
                pinController: context.watch<PinCubit>().state.pinController,
                inputFormatters: [Formatters.allowIntegers],
                // Geometry is deliberately NOT set here. cellSize (48x56) and
                // spacing (8) are left at MaterialPinTheme's defaults, which is
                // exactly what a null theme resolved to before — the app
                // registers no materialPinTheme extension. So this block
                // changes colour only, never layout.
                //
                // KNOWN, ACCEPTED (06-05 walk, decision 2026-07-22): the row
                // needs 216px (4x48 + 3x8) and the page gutter above costs 32,
                // so it overflows by ~1px below a 248px window. That is
                // narrower than any shipping device — the smallest real phone
                // is 320px logical, leaving 72px spare. Accepted rather than
                // shrinking the cells, so the PIN keeps one size everywhere.
                theme: MaterialPinTheme(
                  fillColor: gw.surfaceWell,
                  followingFillColor: gw.surfaceWell,
                  borderColor: gw.borderSubtle,
                  followingBorderColor: gw.borderSubtle,
                  focusedBorderColor: context.gw.brandPrimaryStrong,
                  filledBorderColor: context.gw.brandPrimaryStrong,
                  cursorColor: context.gw.brandPrimaryStrong,
                  textStyle: GeniusWalletTypography.headlineMd.copyWith(
                    color: gw.textPrimary,
                  ),
                ),
              ),
              BlocBuilder<PinCubit, PinState>(
                builder: (context, state) {
                  if (state.displayIncorrectPin) {
                    // A live region: the mismatch no longer changes screens,
                    // so without it a screen reader would say nothing.
                    return Semantics(
                      liveRegion: true,
                      child: Text(
                        'Incorrect PIN',
                        // gw.statusErrorText, NOT GeniusWalletColors.statusError:
                        // the static is one mode-invariant #FF4D4D, ~3.4:1 on
                        // a light surface (an AA fail). The extension's text
                        // partner clears AA in both modes.
                        style: GeniusWalletTypography.bodyMd.copyWith(
                          color: gw.statusErrorText,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isNarrow ? double.infinity : 250,
                ),
                child: BlocBuilder<PinCubit, PinState>(
                  builder: (context, state) {
                    return GWButton(
                      label: 'Continue',
                      variant: GWButtonVariant.gradient,
                      size: GWButtonSize.lg,
                      expand: true,
                      // CLOSURE-wrapped. develop had `onCompleted(...)` here,
                      // which invoked during build and disabled the button.
                      onPressed: state.pinFullness == PinFullness.completed
                          ? () => onCompleted(state.pinController.text)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
