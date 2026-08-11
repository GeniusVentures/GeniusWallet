import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/toast/toast_widget.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

enum ToastType { success, error, warning }

/// Height each toast reserves for the one below it. Density-aware rather than
/// one flat stride, because a compact pill is roughly half a card.
///
/// ponytail: these are measured constants, not laid-out heights — a card whose
/// message WRAPS, or is scaled up, still overlaps the toast under it. The
/// upgrade is to hoist all live toasts into a single `OverlayEntry` holding a
/// `Column`, at which point the stack lays itself out and these disappear. Not
/// done here because it rewrites the entry lifecycle.
///
/// A card is 92 at 1.0x — `space6` padding twice (24) + the 44pt dismiss row +
/// `space2` (4) + one `bodySm` line (20) — so 84 overlapped two stacked cards
/// by 8px before anything wrapped. 4 of slack on top of the 92.
const double _kCardStride = 96.0;

/// A pill is 30 — `space3` padding twice (12) + one `labelMd` line (18).
const double _kCompactStride = 44.0;

/// Beyond this the oldest is evicted. Was uncapped: at the old flat 85px
/// stride the fourth toast sat at 355px and the sixth was off screen.
const int _kMaxVisible = 3;

/// Mobile app bar height — `MobileHeader.preferredSize`.
const double _kMobileHeaderHeight = 60.0;

/// The title an untitled error is given so it still gets the card.
///
/// Density is chosen by [showToast]'s `title`, which for a receipt is the
/// right question — but an error is never a receipt. Left compact, "Failed to
/// load tokens. Check your connection and try again." ellipsized to one line,
/// carried no dismiss button and was gone in two seconds, which is how you
/// lose the half of the sentence that says what to do. `bridge_screen` had
/// already written this exact title by hand.
const String _kErrorTitle = 'Error';

/// The one call. Everything in the app that has something to tell the user
/// comes through here.
///
/// Density is chosen by [title]: with one the toast is an alert and gets the
/// card, the dismiss button and the longer read; without one it is a
/// confirmation and gets the compact pill. That is not a shortcut — a title is
/// what distinguishes "Verification failed / Please try again" from
/// "Link copied", and the two want different amounts of the screen.
///
/// One exception: [ToastType.error] always gets the card, titled or not — see
/// [_kErrorTitle]. Nothing the user has to act on is allowed to be a receipt.
void showToast(
  BuildContext context,
  String message, {
  String? title,
  ToastType type = ToastType.success,
  Duration? duration,
  VoidCallback? onClose,
}) {
  ToastManager.instance.show(
    context: context,
    message: message,
    title: title,
    type: type,
    duration: duration,
    onClose: onClose,
  );
}

/// Manages toast notifications as overlay entries.
class ToastManager {
  static final ToastManager instance = ToastManager._();
  ToastManager._();

  final List<_ActiveToast> _toasts = [];

  @visibleForTesting
  int get visibleCount => _toasts.length;

  void show({
    required BuildContext context,
    required String message,
    String? title,
    ToastType type = ToastType.success,
    Duration? duration,
    VoidCallback? onClose,
  }) {
    // Every in-page caller has an ancestor Overlay (the app shell's own), so
    // `Overlay.maybeOf` resolves on the first branch. The fallback is for a
    // context that IS the root Navigator's own element - dev_tools_bubble's
    // actions run from one at the mount point above the root Navigator (quick
    // task 260731-gow), where there is no Overlay ancestor to find.
    // Deliberately no early return if neither resolves: throwing is what
    // `Overlay.of` already did, and swallowing the toast would be worse.
    final overlay = Overlay.maybeOf(context) ?? Navigator.of(context).overlay!;
    final cardTitle = title ?? (type == ToastType.error ? _kErrorTitle : null);
    final isCard = cardTitle != null;

    while (_toasts.length >= _kMaxVisible) {
      _dismiss(_toasts.first, null);
    }

    late final _ActiveToast toast;
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _AnimatedToast(
        offsetAbove: _offsetAbove(toast),
        title: cardTitle,
        message: message,
        type: type,
        // The auto-dismiss timer lives on the State, not here, so that a tree
        // torn down while a toast is up cancels it. Held on the manager it
        // survived its own overlay — which in a widget test is a pending-timer
        // failure, and in the app is a callback into a dead route.
        duration:
            duration ??
            (isCard ? const Duration(seconds: 5) : _kCompactDuration),
        onControllerReady: (c) => toast.controller = c,
        onDismiss: () => _dismiss(toast, onClose),
        onDisposed: () => _forget(toast),
      ),
    );

    toast = _ActiveToast(entry: entry, isCard: isCard);
    _toasts.add(toast);
    overlay.insert(entry);
    _restack();
  }

  /// Drops a toast whose widget has gone away without being dismissed — the
  /// route was popped, or the whole tree was disposed. No animation, no
  /// `entry.remove()`: the entry is already going.
  void _forget(_ActiveToast toast) {
    if (toast.dismissed) {
      return;
    }
    toast.dismissed = true;
    _toasts.remove(toast);
  }

  static const Duration _kCompactDuration = Duration(seconds: 2);

  /// Sum of the strides of every toast currently above this one. Read inside
  /// the entry's builder, so [_restack] only has to mark entries dirty.
  double _offsetAbove(_ActiveToast toast) {
    final index = _toasts.indexOf(toast);
    if (index <= 0) {
      return 0;
    }
    var total = 0.0;
    for (var i = 0; i < index; i++) {
      total += _toasts[i].isCard ? _kCardStride : _kCompactStride;
    }
    return total;
  }

  /// Positions are derived from list order, so anything that changes the list
  /// has to rebuild the survivors — otherwise a dismissed toast leaves a hole
  /// and the ones under it never move up.
  void _restack() {
    for (final toast in _toasts) {
      // `mounted` guards the teardown path: _forget runs from State.dispose,
      // and marking a sibling entry dirty while the overlay itself is being
      // disposed asserts.
      if (toast.entry.mounted) {
        toast.entry.markNeedsBuild();
      }
    }
  }

  void _dismiss(_ActiveToast toast, VoidCallback? onClose) {
    if (toast.dismissed) {
      return;
    }
    toast.dismissed = true;
    _toasts.remove(toast);

    final controller = toast.controller;
    if (controller != null &&
        (controller.isAnimating || controller.isCompleted)) {
      controller.reverse().then((_) => toast.entry.remove());
    } else {
      toast.entry.remove();
    }

    _restack();
    onClose?.call();
  }

  void disposeAll() {
    // Iterate a copy — _dismiss mutates the list.
    for (final toast in [..._toasts]) {
      _dismiss(toast, null);
    }
  }
}

class _ActiveToast {
  final OverlayEntry entry;
  final bool isCard;
  AnimationController? controller; // set once the widget initializes
  bool dismissed = false;

  _ActiveToast({required this.entry, required this.isCard});
}

class _AnimatedToast extends StatefulWidget {
  final double offsetAbove;
  final String? title;
  final String message;
  final ToastType type;
  final Duration duration;
  final ValueChanged<AnimationController> onControllerReady;
  final VoidCallback onDismiss;
  final VoidCallback onDisposed;

  const _AnimatedToast({
    required this.offsetAbove,
    required this.title,
    required this.message,
    required this.type,
    required this.duration,
    required this.onControllerReady,
    required this.onDismiss,
    required this.onDisposed,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _autoDismiss;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    widget.onControllerReady(_controller);
    _controller.forward();
    _autoDismiss = Timer(widget.duration, widget.onDismiss);
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    widget.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // The repo's own breakpoint, not a second one — a literal 600 here meant a
    // toast switched to its phone placement at a width nothing else in the app
    // treats as a phone. `useDesktopLayout` also forces this branch on native
    // iOS/Android whatever the width, which is what the safe-area maths below
    // is for.
    final isMobile = !GeniusBreakpoints.useDesktopLayout(context);

    // Derived, never guessed. The old `top: 100` was a literal with no
    // reference to the inset anywhere in this file, so it landed differently
    // on every device — on a 14 Pro the inset alone is 44-59pt before the
    // 60pt header.
    final top = isMobile
        ? media.padding.top +
              _kMobileHeaderHeight +
              GeniusWalletConsts.space4 +
              widget.offsetAbove
        : GeniusWalletConsts.space12 + widget.offsetAbove;

    // A phone toast drops from the top and is swiped back up; a desktop one
    // slides in horizontally at the top-right and is swiped back out the way
    // it came.
    final slideFrom = isMobile ? const Offset(0, -1) : const Offset(1, 0);
    final dismissDirection = isMobile
        ? DismissDirection.up
        : DismissDirection.startToEnd;

    final toast = ToastWidget(
      title: widget.title,
      message: widget.message,
      type: widget.type,
      onDismiss: widget.onDismiss,
    );

    // Respect the OS "reduce motion" switch: fade in place rather than travel.
    final animated = media.disableAnimations
        ? FadeTransition(opacity: _controller, child: toast)
        : SlideTransition(
            position: Tween<Offset>(begin: slideFrom, end: Offset.zero).animate(
              CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
            ),
            child: toast,
          );

    return Positioned(
      top: top,
      left: isMobile ? GeniusWalletConsts.space3 : null,
      right: isMobile ? GeniusWalletConsts.space3 : GeniusWalletConsts.space12,
      child: Align(
        alignment: isMobile ? Alignment.topCenter : Alignment.topRight,
        child: ConstrainedBox(
          // Not full screen off mobile — a 1400px-wide toast for "Link copied"
          // is what the desktop branch used to allow at maxWidth 600.
          constraints: BoxConstraints(maxWidth: isMobile ? 560 : 420),
          child: Dismissible(
            key: ValueKey(widget.hashCode),
            direction: dismissDirection,
            onDismissed: (_) => widget.onDismiss(),
            child: animated,
          ),
        ),
      ),
    );
  }
}
