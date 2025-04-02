import 'package:flutter/material.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class SlidingDrawer extends StatefulWidget {
  final String title;
  final Widget content;
  final SlidingDrawerController controller;

  const SlidingDrawer({
    Key? key,
    required this.title,
    required this.content,
    required this.controller,
  }) : super(key: key);

  @override
  SlidingDrawerState createState() => SlidingDrawerState();
}

class SlidingDrawerState extends State<SlidingDrawer> {
  OverlayEntry? _overlayEntry;
  bool _isDrawerOpen = false;
  VoidCallback? _rebuildContent;

  @override
  void initState() {
    super.initState();
    widget.controller._attachDrawer(this);
  }

  @override
  void didUpdateWidget(covariant SlidingDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller._attachDrawer(this);
    }
  }

  @override
  void dispose() {
    widget.controller._detachDrawer(this);
    _closeDrawer();
    super.dispose();
  }

  void toggleDrawer() {
    if (_isDrawerOpen) {
      _closeDrawer();
    } else {
      _showDrawer();
    }
  }

  void rebuildDrawerContent() {
    _rebuildContent?.call();
  }

  void _showDrawer() {
    if (_isDrawerOpen) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeDrawer,
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                right: 0,
                top: 0,
                bottom: 0,
                child: SafeArea(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: GeniusBreakpoints.useDesktopLayout(context)
                          ? 500
                          : MediaQuery.of(context).size.width * 0.9,
                    ),
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: GeniusWalletColors.deepBlueTertiary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: GeniusWalletColors.deepBlueCardColor,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                                onPressed: toggleDrawer,
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    widget.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                widget.controller._internalDrawerSetState =
                                    setState; // Save it
                                return widget.content;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDrawerOpen = true;
    });
  }

  void _closeDrawer() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _rebuildContent = null;
      setState(() {
        _isDrawerOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class SlidingDrawerController {
  SlidingDrawerState? _drawerState;
  final ValueNotifier<int> _rebuildTrigger = ValueNotifier(0);
  void Function(void Function())? _internalDrawerSetState;

  void rebuildContent() {
    _internalDrawerSetState?.call(() {});
  }

  void _attachDrawer(SlidingDrawerState state) {
    _drawerState = state;
  }

  void _detachDrawer(SlidingDrawerState state) {
    _drawerState = null;
    _internalDrawerSetState = null;
  }

  void openDrawer() {
    _drawerState?._showDrawer();
  }

  void closeDrawer() {
    _drawerState?._closeDrawer();
  }

  ValueNotifier<int> get rebuildTrigger => _rebuildTrigger;
}
