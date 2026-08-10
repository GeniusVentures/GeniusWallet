import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

/// Apple's input accessory view, as a wrapper: a floating toolbar carrying
/// leading previous/next chevrons and a trailing confirm tick, riding just
/// above the on-screen keyboard for as long as the field inside holds focus.
///
/// WHY IT EXISTS. `TextInputType.numberWithOptions(decimal: true)` and
/// `TextInputType.number` open the iOS decimal/number pad, and that keyboard
/// has no return key at all. `textInputAction` therefore has nothing to set:
/// the field cannot be dismissed FROM the keyboard, and Flutter's own
/// `onTapOutside` default is a no-op on Android and iOS (`EditableText`'s
/// `_defaultOnTapOutside` only unfocuses on the three desktop platforms). So a
/// decimal field on a phone has, out of the box, no exit at all. Jakub hit
/// exactly this on the Swap amount and could not tell how to get out.
///
/// It supplies BOTH exits, so no call site can ship half of the pair: the bar
/// is the visible affordance, and the [TapRegion] below restores
/// tap-anywhere-else as the shortcut.
///
/// HOW IT WATCHES. Focus is observed from descendants, the same shape
/// `GWFocusRing` uses and for the same reason: call sites do not have to own a
/// `FocusNode`, so wrapping a field is one line and works for a bare
/// `TextField`, a `GWTextField`, or anything else that focuses.
///
/// WHERE IT RENDERS. The ROOT overlay, never the nearest one. Two of the
/// wired call sites sit inside a `ResponsiveDrawer`, which pushes with
/// `useRootNavigator: true` while the screens themselves live under
/// `router.dart`'s ShellRoute navigator. An entry inserted into the nearest
/// overlay would land in the shell's and paint UNDER the sheet. The root
/// overlay's entries are painted in insertion order, and this one is inserted
/// after the sheet's route, so it is on top.
///
/// TOUCH PLATFORMS ONLY. There is no on-screen keyboard to sit above anywhere
/// else, and the desktop platforms already unfocus on an outside tap by
/// themselves. The gate is [GeniusBreakpoints.isMobileApp], NOT
/// `useDesktopLayout`: the latter is a WIDTH test (`width > medium &&
/// !isMobileApp`), so a desktop window dragged narrower than 768 reports
/// "not desktop" and would have grown a keyboard bar with no keyboard under
/// it. "Is there a soft keyboard" is a platform question.
///
/// WHY IT FLOATS RATHER THAN SITS ON THE KEYBOARD. The first version drew the
/// pre-iOS-26 convention: a full-bleed 48pt band, flat fill, hairline on top,
/// flush against the keyboard - a Flutter tracing of `UIToolbar` as
/// `inputAccessoryView`. Jakub tested it on iOS 26.6 and it did not read as
/// native, because iOS 26 moved the goalposts twice. The system keyboard grew
/// a margin with rounded top corners, so nothing sits flush against it any
/// more (FB17978212; Apple's answer was "file feedback"), and toolbars moved
/// to Liquid Glass: rounded, inset, translucent, floating clear of what they
/// overlay. Apple's own above-keyboard Done became a checkmark in such a bar.
///
/// A genuinely native accessory view is not on the table - Flutter has no
/// framework support (issue #124784, open since 2023), `keyboard_actions`
/// draws a Flutter widget exactly like this one, and the one package claiming
/// native is 0.0.4 with 314 downloads, which is not a dependency a wallet
/// takes. So this matches what iOS 26 LOOKS like rather than becoming it.
///
/// WHY GLYPHS AND NOT THE WORD "DONE". The first island shipped the word,
/// reasoning that a bare checkmark is a glyph the system teaches and this app
/// does not. iOS 26 settled that: Safari's own accessory bar is now icons
/// end to end (a key, a card, a pin, and a checkmark to dismiss), so the
/// checkmark IS the taught glyph on the platform this component imitates, and
/// spelling it out is the divergence rather than the safe default. The word's
/// tap target is kept to the pixel anyway - see [_GWKeyboardBarButton].
///
/// WHY THE CHEVRONS ARE REAL. Safari's leading pair steps between the fields
/// of the form. Reproducing them as decoration would be worse than omitting
/// them, so every wrapper with [enabled] set registers itself as a navigable
/// stop and the pair walks that list in reading order. A wrapper built with
/// `enabled: false` is deliberately NOT a stop: it opens no keyboard, so
/// stepping onto it would take the bar away mid-navigation. Most surfaces here
/// hold a single numeric field and correctly show both chevrons disabled;
/// `settings_screen.dart`, with four numeric rows, is where they do work.
class GWKeyboardDoneBar extends StatefulWidget {
  const GWKeyboardDoneBar({
    super.key,
    required this.child,
    this.enabled = true,
    this.isTouchPlatform = GeniusBreakpoints.isMobileApp,
  });

  /// The field (or the subtree containing it) whose focus drives the bar.
  final Widget child;

  /// When false the wrapper is inert and the child renders untouched - for a
  /// field that takes focus but opens no keyboard.
  ///
  /// The case that forced it: Swap's "You Receive" amount is `readOnly`, so it
  /// is focusable for selection and copy but never summons a keyboard. Wrapped
  /// unconditionally, tapping it would raise a keyboard bar with no keyboard
  /// under it. Same flag, same reason, as `GWFocusRing.enabled` one widget out
  /// in that very file.
  final bool enabled;

  /// The touch-platform test, defaulting to the real one.
  ///
  /// `@visibleForTesting`, not premature configurability: the real function
  /// reads `Platform.isIOS`, which `flutter test` cannot override the way
  /// `debugDefaultTargetPlatformOverride` overrides `defaultTargetPlatform` -
  /// the suite runs on macOS, so without this seam the bar would be compiled
  /// out of every test and the behaviour would have no runnable check at all.
  /// Same shape as `MarketsHeroCard.fetchHistoricalPrices`.
  @visibleForTesting
  final bool Function() isTouchPlatform;

  @override
  State<GWKeyboardDoneBar> createState() => _GWKeyboardDoneBarState();
}

class _GWKeyboardDoneBarState extends State<GWKeyboardDoneBar> {
  /// Every wrapper that can currently raise a keyboard, app-wide.
  ///
  /// The chevrons need to know their siblings, and no call site can be asked
  /// to hand-list them: the numeric rows in `settings_screen.dart` are built
  /// from a map, so the set is not knowable where the wrapper is written. A
  /// registry each wrapper joins on its own is the only place the answer
  /// exists. Membership is exactly "would focusing this raise a keyboard", so
  /// an `enabled: false` wrapper (Swap's read-only "You Receive") never joins,
  /// and neither does one off a touch platform.
  ///
  /// Static state on a State class, deliberately: it is a set of live State
  /// objects, every member removes itself in [dispose], and there is exactly
  /// one keyboard per app so there is nothing to scope it to.
  static final Set<_GWKeyboardDoneBarState> _registry =
      <_GWKeyboardDoneBarState>{};

  /// Owned rather than left implicit, because navigation has to reach INTO
  /// this wrapper from a sibling: [_takeFocus] walks down from here to find
  /// the field, and [_updateNeighbours] reads `enclosingScope` off it to keep
  /// a bar inside a modal sheet from stepping onto a field on the screen
  /// underneath it.
  final FocusNode _node = FocusNode(debugLabel: 'GWKeyboardDoneBar');

  OverlayEntry? _entry;
  bool _focused = false;
  _GWKeyboardDoneBarState? _previous;
  _GWKeyboardDoneBarState? _next;

  bool get _isStop => widget.enabled && widget.isTouchPlatform();

  @override
  void initState() {
    super.initState();
    if (_isStop) {
      _registry.add(this);
    }
  }

  @override
  void dispose() {
    _registry.remove(this);
    // The entry lives in an overlay that outlives this State, so navigating
    // away with the keyboard open would otherwise strand a bar on screen.
    _removeBar();
    _node.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GWKeyboardDoneBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isStop) {
      _registry.add(this);
    } else {
      _registry.remove(this);
    }
    // Turning the wrapper off drops the `Focus` node with it, so nothing would
    // ever report the loss of focus that normally retires the bar.
    if (!widget.enabled) {
      _focused = false;
      _removeBar();
    }
  }

  void _handleFocusChange(bool hasFocus) {
    if (hasFocus == _focused) {
      return;
    }
    _focused = hasFocus;
    if (hasFocus) {
      _showBar();
      return;
    }
    // NOT removed here. The keyboard takes about a quarter of a second to
    // slide out, and a bar that vanished on the first frame of that would pop
    // rather than ride it down. The overlay drops itself once the inset
    // reaches zero.
    _entry?.markNeedsBuild();
  }

  void _showBar() {
    // `insert` calls `setState` on the OverlayState, and so does another bar's
    // `remove` below. A focus change normally lands in a microtask, safely
    // outside the build phase - but an `autofocus` field can deliver one from
    // inside it, and mutating another widget there throws. Defer only in that
    // case; the common path stays synchronous so the bar is up on the same
    // frame the keyboard starts on. This guard sits ahead of everything else
    // precisely because every branch below now touches the overlay.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focused) {
          _showBar();
        }
      });
      return;
    }
    _updateNeighbours();
    // One island at a time. A bar whose field lost focus keeps its entry until
    // the keyboard inset reaches zero (that is what makes it ride the keyboard
    // down), which is right when the keyboard is leaving and wrong when a
    // SIBLING field took the focus: the stale entry would stay in the overlay,
    // and on the third hop it would be the one on top - painting one field's
    // chevrons over another field's bar. Nothing flickers, because the entry
    // that replaces it is inserted in this same call.
    for (final bar in _registry) {
      if (!identical(bar, this)) {
        bar._removeBar();
      }
    }
    if (_entry != null) {
      _entry!.markNeedsBuild();
      return;
    }
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }
    _entry = OverlayEntry(
      builder: (context) => _GWKeyboardDoneBarOverlay(
        // Read on every rebuild of the builder, never captured once: the
        // `markNeedsBuild` above is what turns this false.
        focused: _focused,
        onDone: _dismiss,
        onKeyboardGone: _removeBarIfIdle,
        // Null IS the disabled state, so a chevron with nowhere to go cannot
        // be wired up by accident.
        onPrevious: _previous == null ? null : _focusPrevious,
        onNext: _next == null ? null : _focusNext,
      ),
    );
    overlay.insert(_entry!);
  }

  /// This wrapper's box in screen coordinates, or null while it has no layout
  /// to report - an unmounted, detached or unsized subtree simply drops out of
  /// the ordering rather than sorting to the origin.
  Rect? _fieldRect() {
    if (!mounted) {
      return null;
    }
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) {
      return null;
    }
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Works out which stop the chevrons point at, once per bar appearance.
  ///
  /// Reading order, top then left, which is what the app's traversal order
  /// already is: `WidgetsApp` wraps everything in a `FocusTraversalGroup`
  /// whose default policy is `ReadingOrderTraversalPolicy`. Sorting by
  /// geometry rather than by registration order also survives a reordered or
  /// re-keyed list, which registration order would not.
  ///
  /// Computed here, off a focus change, rather than inside the overlay's
  /// builder: reading another subtree's transform mid-build is asking for a
  /// stale or dirty layout, and by the time focus moves the frame that placed
  /// every field has already been laid out.
  void _updateNeighbours() {
    _previous = null;
    _next = null;
    // A bar inside a modal sheet must not step onto a field on the screen
    // below it - `ModalRoute` gives every route its own `FocusScope`, so
    // "same scope" is exactly "same surface", and Swap's settings drawer is
    // the live case.
    final scope = _node.enclosingScope;
    final rects = <_GWKeyboardDoneBarState, Rect>{};
    for (final bar in _registry) {
      if (bar._node.enclosingScope != scope) {
        continue;
      }
      final rect = bar._fieldRect();
      if (rect == null) {
        continue;
      }
      rects[bar] = rect;
    }
    final ordered = rects.keys.toList()
      ..sort((a, b) {
        final rows = rects[a]!.top.compareTo(rects[b]!.top);
        if (rows != 0) {
          return rows;
        }
        return rects[a]!.left.compareTo(rects[b]!.left);
      });
    final index = ordered.indexOf(this);
    if (index < 0) {
      return;
    }
    if (index > 0) {
      _previous = ordered[index - 1];
    }
    if (index < ordered.length - 1) {
      _next = ordered[index + 1];
    }
  }

  void _focusPrevious() {
    _previous?._takeFocus();
  }

  void _focusNext() {
    _next?._takeFocus();
  }

  /// Hands the keyboard to this wrapper's field.
  void _takeFocus() {
    if (!mounted) {
      return;
    }
    _firstFocusable(_node)?.requestFocus();
  }

  /// The shallowest focusable node under [node] - the field itself.
  ///
  /// Pre-order on purpose. `FocusNode.traversalDescendants` is POST-order, so
  /// on a `GWTextField` carrying a suffix button it would hand back the
  /// button, whose node is a child of the field's own. Walking down from the
  /// top instead reaches the field first and stops, and skips the wrapper
  /// nodes on the way (this one and `GWFocusRing`'s), which report
  /// `canRequestFocus: false`.
  static FocusNode? _firstFocusable(FocusNode node) {
    for (final child in node.children) {
      if (child.canRequestFocus && !child.skipTraversal) {
        return child;
      }
      final nested = _firstFocusable(child);
      if (nested != null) {
        return nested;
      }
    }
    return null;
  }

  void _removeBarIfIdle() {
    // A field re-focused inside the same frame that scheduled the removal must
    // keep its bar.
    if (_focused) {
      return;
    }
    _removeBar();
  }

  void _removeBar() {
    final entry = _entry;
    if (entry == null) {
      return;
    }
    _entry = null;
    entry.remove();
    entry.dispose();
  }

  void _dismiss() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || !widget.isTouchPlatform()) {
      return widget.child;
    }
    return TapRegion(
      // Shared with the bar itself, so a tap on the toolbar (its padding, not
      // just the Done label) is INSIDE the group and does not read as
      // "tapped away".
      groupId: GWKeyboardDoneBar,
      onTapOutside: (_) {
        if (_focused) {
          _dismiss();
        }
      },
      child: Focus(
        focusNode: _node,
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: _handleFocusChange,
        child: widget.child,
      ),
    );
  }
}

/// The bar as the overlay paints it. A widget rather than a `_buildBar()`, so
/// it rebuilds on its own when `MediaQuery` reports a new keyboard inset -
/// which is what makes it track the keyboard through the animation instead of
/// jumping to the settled height.
class _GWKeyboardDoneBarOverlay extends StatelessWidget {
  const _GWKeyboardDoneBarOverlay({
    required this.focused,
    required this.onDone,
    required this.onKeyboardGone,
    required this.onPrevious,
    required this.onNext,
  });

  final bool focused;
  final VoidCallback onDone;
  final VoidCallback onKeyboardGone;

  /// Null when there is no stop in that direction, which is both the disabled
  /// state and the reason for it.
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  /// 44, the platform toolbar height and Apple's minimum target in one - not a
  /// spacing token, the same way `kHeaderControlSize` and
  /// `kGWSectionTitleHeaderHeight` are not. The previous 48 (`space24`) came
  /// from wanting headroom over the 44 floor once a hairline was taken off the
  /// top; the island has no hairline eating into its box, so the platform
  /// number is available exactly.
  static const double _height = 44;

  /// The clearance between the island and whatever it floats over. `space4` is
  /// 8pt, the separation iOS 26 puts between a floating toolbar and the
  /// content below it, and the smallest gap that still reads as detached
  /// rather than as a misaligned edge.
  static const double _gap = GeniusWalletConsts.space4;

  /// The inset from both screen edges. `space10` is 20pt, which is `GWScreen`'s
  /// own horizontal page padding - so the island's edges land on the same two
  /// vertical lines as the form content it floats over, instead of cutting
  /// across it at an offset of their own.
  static const double _inset = GeniusWalletConsts.space10;

  /// `radius2xl` (16) - gnus.ai's `--radius-2xl`, and the radius
  /// `GWGradientBorderCard` already uses for the app's floating glass panel,
  /// which is exactly what this is. Not `radiusPill`: at 44 tall a pill caps at
  /// a 22 radius, and Done's 16pt trailing padding would then sit inside the
  /// cap's arc rather than clear of it.
  static const BorderRadius _shape = BorderRadius.all(
    Radius.circular(GeniusWalletConsts.radius2xl),
  );

  /// Matches `GWGradientBorderCard.glassBlur`'s default, so the app has one
  /// frosted-glass strength rather than two.
  static const double _blurSigma = 24;

  /// The trailing control keeps the footprint the word "Done" had, so swapping
  /// four letters for one glyph cannot cost anyone the target. The word
  /// measured 97x44 in the widget-test font (which draws every glyph one em
  /// wide, so 4 x 16 plus 16 a side) and roughly 76 wide in Inter, where the
  /// letters are narrower than an em; 96 is the 4-pt-grid step that covers
  /// both and, being a fixed width rather than a measured string, does not
  /// move again if the type step or the font changes. Deliberately one point
  /// under the test-font figure and 20 over the shipping one - see the note in
  /// the test.
  static const double _doneTargetWidth = 96;

  /// The opaque floor under the glass, and it is a floor rather than a taste
  /// call. A `BackdropFilter` blurs but does not lighten or darken, so the
  /// label's contrast is decided by whatever the fill lets through. Measured
  /// against the extremes the bar could ever float over:
  ///
  /// | fill alpha | dark label over white | light label over black |
  /// |---|---|---|
  /// | 224 (88%) | 4.74:1 | **4.26:1** X |
  /// | 235 (92%) | 5.44:1 | 4.70:1 |
  /// | **240 (94%)** | **5.81:1** | **4.93:1** |
  ///
  /// Light mode binds, as it always does here: a fill translucent enough to
  /// look like glass cannot hold AA for a dark label over dark content. 240 is
  /// the first step with real margin on both sides. Over the app's own canvas
  /// the numbers are 6.83:1 dark and 5.60:1 light, i.e. within a rounding step
  /// of the opaque values this replaced (6.81:1 / 5.61:1). The blur therefore
  /// buys motion and depth at the edges, not see-through.
  static const int _fillAlpha = 240;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final inset = media.viewInsets.bottom;

    if (!focused && inset <= 0) {
      // Nothing left to track. An entry cannot remove itself mid-build, so the
      // next frame is the earliest legal moment.
      WidgetsBinding.instance.addPostFrameCallback((_) => onKeyboardGone());
      return const SizedBox.shrink();
    }

    // Fail-soft read: registers the InheritedWidget dependency that forces a
    // rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    return Positioned(
      left: _inset,
      right: _inset,
      // The keyboard is the anchor, and `_gap` rides on top of it, so the
      // clearance tracks the slide rather than opening up once it settles.
      // When there is no keyboard - a hardware one on iPadOS leaves the inset
      // at 0 while the field stays focused - the bar falls back to clearing
      // the home indicator instead.
      bottom: (inset > 0 ? inset : media.viewPadding.bottom) + _gap,
      child: TapRegion(
        groupId: GWKeyboardDoneBar,
        child: DecoratedBox(
          // Outside the clip, so the shadow reads as the island casting one
          // rather than as a gradient painted inside its own edge. This is
          // what makes the 8pt gap look like clearance instead of a hole.
          decoration: BoxDecoration(
            borderRadius: _shape,
            boxShadow: GeniusWalletElevation.card,
          ),
          child: ClipRRect(
            // Not optional: an unclipped `BackdropFilter` blurs the whole
            // layer it sits in, which here is the entire screen.
            borderRadius: _shape,
            child: BackdropFilter(
              // The blur exists only while the overlay entry does, and the
              // entry is removed the frame after the keyboard inset reaches
              // zero - so nothing is being blurred between edits.
              filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
              child: Material(
                // Chrome, not content: `surfaceMenu` is this app's sheet/menu
                // surface, a step off the card canvas the form behind it is
                // painted on, so the island reads as an overlaying layer
                // rather than as one more row of the page.
                color: gw.surfaceMenu.withAlpha(_fillAlpha),
                shape: RoundedRectangleBorder(
                  // Decorative rim, so `borderSubtle` and not the 3:1
                  // `borderControl` - see the token's own doc for that split.
                  // A shape rather than a `Border` inside a `Container`: the
                  // latter insets its child by the border width, which would
                  // quietly take the Done target from 44 to 42.
                  side: BorderSide(color: gw.borderSubtle),
                  borderRadius: _shape,
                ),
                child: SizedBox(
                  height: _height,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // The tap target is the bar's full height, not the
                    // glyph's - at 44 that is exactly Apple's floor, so the
                    // line is now load-bearing rather than generous.
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Up is BACK. Safari's pair is vertical, not
                          // horizontal, because a form is read down the page
                          // and not across it - `chevron_left`/`right` would
                          // suggest paging between screens instead.
                          // `keyboard_arrow_*` is Material's name for the
                          // bare chevron (`arrow_upward` carries a stem), and
                          // the keyboard is literally what it steps around.
                          _GWKeyboardBarButton(
                            icon: Icons.keyboard_arrow_up,
                            semanticLabel: 'Previous field',
                            onTap: onPrevious,
                          ),
                          _GWKeyboardBarButton(
                            icon: Icons.keyboard_arrow_down,
                            semanticLabel: 'Next field',
                            onTap: onNext,
                          ),
                        ],
                      ),
                      // The bare tick, not `Icons.check_circle`. Both are
                      // already in this app's vocabulary and they are not
                      // interchangeable: `check_circle` is the SELECTED-state
                      // mark (`GWSelectRow`, `network_page`), where the disc
                      // is what reads as a filled radio; the bare tick is the
                      // ACTION mark (`crypto_address_qr`'s copy confirmation),
                      // which is what a toolbar button is. It is also the
                      // glyph Safari's own bar uses.
                      _GWKeyboardBarButton(
                        icon: Icons.check,
                        semanticLabel: 'Done',
                        onTap: onDone,
                        width: _doneTargetWidth,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One control on the island: a glyph in a tap target, or a glyph that is
/// plainly not one.
class _GWKeyboardBarButton extends StatelessWidget {
  const _GWKeyboardBarButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.width = _minWidth,
  });

  final IconData icon;

  /// The word the glyph replaced, kept for anyone who cannot see the glyph.
  final String semanticLabel;

  /// Null is the disabled state: no callback, no ink, no tap action in the
  /// semantics tree.
  final VoidCallback? onTap;

  /// The tap target's width. Defaults to the glyph plus a gutter either side;
  /// anything wider grows INWARD from the island's edge, so the glyph keeps
  /// its 16pt gutter and only the invisible half of the target moves.
  final double width;

  /// Half the 44pt bar, which is where iOS puts a toolbar glyph, and the
  /// `GWButtonSize.lg` icon step this app already draws at that size.
  static const double _glyphSize = 22;

  /// `space8` (16) either side, the same gutter the word "Done" had, so the
  /// outermost glyphs sit on the island's own 16pt inset rather than drifting
  /// closer to its edge than the label did.
  static const double _gutter = GeniusWalletConsts.space8;

  /// 54: past the 44 floor, and the width at which the two chevrons read as
  /// two buttons rather than one double-headed glyph.
  static const double _minWidth = _glyphSize + _gutter * 2;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read, and re-read per build so a live appearance toggle takes.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final enabled = onTap != null;
    return Semantics(
      button: true,
      // Announces "dimmed" rather than leaving a chevron that reads as
      // actionable and then does nothing. With `onTap` null there is also no
      // tap action on the node at all, so this is a label on a fact.
      enabled: enabled,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          // Not a centred `SizedBox`: centring the tick inside 96 would park
          // it 37 from the island's edge while the chevrons sit on 16, and the
          // bar would read as lopsided. The extra target is taken off the
          // inboard side, where there is nothing but empty bar.
          padding: EdgeInsets.only(
            left: width - _glyphSize - _gutter,
            right: _gutter,
          ),
          child: Icon(
            icon,
            size: _glyphSize,
            // Measured against the translucent fill, not the opaque token -
            // see `_fillAlpha` - and at the extremes the island can float
            // over, which is where the fill lets the most through.
            //
            // | glyph | dark | light |
            // |---|---|---|
            // | enabled `brandPrimaryOnSurface` | 5.81:1 | 4.93:1 |
            // | disabled `textSecondary` | 4.60:1 | 4.93:1 |
            //
            // The disabled step is a HUE change, not a fade: dropping the
            // brand colour is what says "not the live control", and holding
            // 4.6:1 is what keeps it readable as a chevron at all. Both rows
            // clear 1.4.11's 3:1 for a non-text control, so the exemption
            // inactive controls get is not being leaned on. It is also the
            // platform's own convention - iOS greys a disabled bar button off
            // tint rather than fading it - and the semantics node carries
            // `enabled: false` so the state is not colour-only.
            //
            // ponytail: in LIGHT the two rows measure the same 4.93:1, so the
            // difference there is hue alone with no drop in weight. Ceiling:
            // it holds AA and reads as grey-not-teal, but it is softer than
            // the dark step. Upgrade path: an appearance-aware disabled
            // foreground token, in the light pass rather than here - no token
            // in `GWColors` today is both weaker than the brand and over 3:1
            // on this fill in both modes.
            color: enabled ? gw.brandPrimaryOnSurface : gw.textSecondary,
          ),
        ),
      ),
    );
  }
}
