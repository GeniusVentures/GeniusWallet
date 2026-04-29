import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/toast/ticker_provider.dart';
import 'package:genius_wallet/components/toast/toast_widget.dart';

/// Manages toast notifications as overlay entries.
class ToastManager {
  static final ToastManager instance = ToastManager._();
  ToastManager._();

  final List<_ActiveToast> _toasts = [];

  void showToast({
    required BuildContext context,
    required String title,
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onClose,
  }) {
    final overlay = Overlay.of(context);
    final topOffset = 100.0 + _toasts.length * 85.0;

    late final _ActiveToast toast;
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _AnimatedToast(
        topOffset: topOffset,
        title: title,
        message: message,
        type: type,
        onControllerReady: (c) => toast.controller = c,
        onDismiss: () => _dismiss(toast, onClose),
      ),
    );

    toast = _ActiveToast(entry: entry);
    _toasts.add(toast);
    overlay.insert(entry);

    toast.timer = Timer(duration, () => _dismiss(toast, onClose));
  }

  void _dismiss(_ActiveToast toast, VoidCallback? onClose) {
    if (toast.dismissed) return;
    toast.dismissed = true;
    toast.timer?.cancel();
    _toasts.remove(toast);

    final controller = toast.controller;
    if (controller != null &&
        (controller.isAnimating || controller.isCompleted)) {
      controller.reverse().then((_) => toast.entry.remove());
    } else {
      toast.entry.remove();
    }

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
  AnimationController? controller; // set once the widget initializes
  Timer? timer;
  bool dismissed = false;

  _ActiveToast({required this.entry});
}

class _AnimatedToast extends StatefulWidget {
  final double topOffset;
  final String title;
  final String message;
  final ToastType type;
  final ValueChanged<AnimationController> onControllerReady;
  final VoidCallback onDismiss;

  const _AnimatedToast({
    required this.topOffset,
    required this.title,
    required this.message,
    required this.type,
    required this.onControllerReady,
    required this.onDismiss,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));

    widget.onControllerReady(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Positioned(
      top: widget.topOffset,
      left: isMobile ? 0 : null,
      right: 0,
      child: Align(
        alignment: isMobile ? Alignment.center : Alignment.topRight,
        child: SizedBox(
          width: isMobile ? double.infinity : 600,
          child: SlideTransition(
            position: _slide,
            child: ToastWidget(
              title: widget.title,
              message: widget.message,
              type: widget.type,
              onDismiss: widget.onDismiss,
            ),
          ),
        ),
      ),
    );
  }
}

enum ToastType { success, error, warning }
