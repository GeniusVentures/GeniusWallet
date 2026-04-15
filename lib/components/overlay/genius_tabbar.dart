



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/components/overlay/destinations.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:flutter/gestures.dart';


class GeniusTabbar extends StatelessWidget {
  static const _numTabs = 6;
  const GeniusTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();
    final screenList = destinations.map((e) => e.key).toList();

    return BlocBuilder<NavigationOverlayCubit, NavigationOverlayState>(
      builder: (context, state) {
        final selectedScreen = state.selectedScreen;
        final selectedIndex = screenList.indexOf(selectedScreen);

        return _ScrollableSnapTabBar(
          destinations: destinations,
          screenList: screenList,
          selectedIndex: selectedIndex,
        );
      },
    );
  }
}

class _ScrollableSnapTabBar extends StatefulWidget {
  final List<MapEntry<NavigationScreen, BottomNavigationBarItem>> destinations;
  final List<NavigationScreen> screenList;
  final int selectedIndex;

  const _ScrollableSnapTabBar({
    required this.destinations,
    required this.screenList,
    required this.selectedIndex,
    Key? key,
  }) : super(key: key);

  @override
  State<_ScrollableSnapTabBar> createState() => _ScrollableSnapTabBarState();
}

class _ScrollableSnapTabBarState extends State<_ScrollableSnapTabBar> {
  late final ScrollController _scrollController;
  double _tabWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollEnd() {
    if (_tabWidth == 0) return;
    final offset = _scrollController.offset;
    final index = (offset / _tabWidth).round();
    final percent = (offset % _tabWidth) / _tabWidth;
    int snapIndex = index;
    if (percent > 0.5) {
      snapIndex += 1;
    }
    // Clamp so we always have 5 icons in view
    snapIndex = snapIndex.clamp(0, (widget.destinations.length - 5));
    final targetOffset = snapIndex * _tabWidth;
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GeniusWalletColors.deepBlueCardColor,
      height: 64,
      alignment: Alignment.bottomCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _tabWidth = constraints.maxWidth / 5;
          return NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              _onScrollEnd();
              return true;
            },
            child: ScrollConfiguration(
              behavior: const _TabBarScrollBehavior(),
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: widget.destinations.length,
                itemBuilder: (context, i) {
                  final entry = widget.destinations[i];
                  final isSelected = i == widget.selectedIndex;
                  return SizedBox(
                    width: _tabWidth,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.read<NavigationOverlayCubit>().navigationTapped(widget.screenList[i]);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? GeniusWalletColors.lightGreenPrimary.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: entry.value.activeIcon ?? entry.value.icon,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom scroll behavior to enable mouse drag and wheel scrolling for horizontal tab bar
class _TabBarScrollBehavior extends MaterialScrollBehavior {
  const _TabBarScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

// Helper to build the destinations list
List<MapEntry<NavigationScreen, BottomNavigationBarItem>> _buildDestinations() {
    return GeniusTabDestinations.destinations
      .where((e) => e.isVisible ?? true)
      .map((e) {
    final navScreen = e.navScreen;
    return MapEntry(
      navScreen,
      BottomNavigationBarItem(
        backgroundColor: Colors.transparent,
        tooltip: e.label.data,
        icon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Container(height: 1, width: 40, color: Colors.transparent),
            const SizedBox(height: 8),
            e.icon,
          ],
        ),
        activeIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Container(
                height: 1,
                width: 40,
                color: GeniusWalletColors.lightGreenPrimary),
            const SizedBox(height: 8),
            e.selectedIcon ?? e.icon,
          ],
        ),
        label: e.label.data,
      ),
    );
  }).toList();
}
