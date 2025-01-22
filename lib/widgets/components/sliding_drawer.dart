import 'package:flutter/material.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class SlidingDrawer extends StatefulWidget {
  final String title;
  final Widget content;
  final SlidingDrawerController controller; // Controller to manage state

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

  @override
  void initState() {
    super.initState();
    widget.controller._attachDrawer(this); // Attach controller to instance
  }

  void toggleDrawer() {
    if (_overlayEntry == null) {
      _showDrawer();
    } else {
      _closeDrawer();
    }
  }

  void _showDrawer() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context),
          child: Stack(
            children: [
              // Backdrop to Close Drawer When Clicking Outside
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeDrawer,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),

              // Sliding Drawer Panel
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                right: 0,
                top: 0,
                bottom: 0,
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
                        color: Colors.black.withOpacity(0.3),
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
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
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

                      // Drawer Content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: widget.content,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Insert Drawer Overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDrawer() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // No need to wrap a child, use keys instead
  }
}

/// **Controller to manage SlidingDrawer**
class SlidingDrawerController {
  SlidingDrawerState? _drawerState;

  void _attachDrawer(SlidingDrawerState state) {
    _drawerState = state;
  }

  void openDrawer() {
    _drawerState?.toggleDrawer();
  }
}
