import 'package:flutter/material.dart';

/// Reports pointer hover state to [builder] so the CALLER keeps full control of
/// its own visual response to a hover -- the property that makes this
/// extraction provable without a visual baseline. A component that decided the
/// response itself would repaint every call site at once, with nothing to
/// check the repaint against; this one only ever moves state plumbing.
///
/// Promoted from `lib/squid_router/swap_field.dart`'s private `_Hoverable`
/// (23-05, `AGENTS.md` rung 4 -- something already in the tree solves it,
/// rather than an invented abstraction). Thirteen call sites hand-rolled the
/// identical `bool` field + `MouseRegion` + `setState` pair before this
/// promotion; see `23-05-EXTRACTION-AUDIT.md` for the full inventory and the
/// candidates this plan declined to extract for the same reason.
///
/// **Owns:** the hover flag, the pointer region, the no-op `setState` guard
/// (only rebuilds when the value actually changes -- carried over from
/// `GWViewAllLink`'s `_setHover`, the one existing site that already had it),
/// and the [cursor] the region reports while the pointer is over it.
///
/// **Does not own:** anything about paint. No colour, no radius, no padding --
/// a caller that needs one of those reads the builder's `hovered` flag and
/// decides for itself, exactly as every site it replaces already did.
///
/// [cursor] defaults to [SystemMouseCursors.click] because most existing sites
/// set it explicitly. The sites that didn't -- `GWSelectRow`, the swap field's
/// two `InkWell` consumers, and `SwapSettingsDrawer`'s `_PresetChip` -- all
/// wrap an `InkWell` as their tappable child, and `InkWell` already resolves
/// its own `WidgetStateMouseCursor.clickable` when it has an `onTap`; their
/// parent region's cursor was therefore redundant with the child's, not a
/// deliberate "no cursor" choice. Defaulting to click keeps every migrated
/// site's cursor behaviour unchanged: the sites that already stated it get the
/// same value, and the sites that relied on `InkWell` gain a second, identical
/// cursor region that composites with no visible difference.
class GWHoverable extends StatefulWidget {
  const GWHoverable({
    super.key,
    required this.builder,
    this.cursor = SystemMouseCursors.click,
  });

  /// Called with the current hover flag on every build. The caller decides
  /// everything about what is painted; this widget decides only when it is
  /// called.
  final Widget Function(bool hovered) builder;

  /// The cursor the region reports while the pointer is over it. See the class
  /// doc for the default and the site split that justified it.
  final MouseCursor cursor;

  @override
  State<GWHoverable> createState() => _GWHoverableState();
}

class _GWHoverableState extends State<GWHoverable> {
  bool _hovered = false;

  void _setHovered(bool value) {
    // No-op guard, carried over from `GWViewAllLink._setHover`: only rebuild
    // when the value actually changes. Every previously-unguarded site gets
    // this rebuild saving for free -- it changes nothing about what is
    // painted, only how often the frame is asked to repaint it.
    if (_hovered != value) {
      setState(() => _hovered = value);
    }
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: widget.cursor,
    onEnter: (_) => _setHovered(true),
    onExit: (_) => _setHovered(false),
    child: widget.builder(_hovered),
  );
}
