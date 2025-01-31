import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/widgets/components/custom/hamburger_menu_icon_custom.dart';

class GeniusAppbar extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrGeniusAppbarLogo;
  final Widget? ovrChatbubbles;
  const GeniusAppbar(
    this.constraints, {
    Key? key,
    this.ovrGeniusAppbarLogo,
    this.ovrChatbubbles,
  }) : super(key: key);
  @override
  _GeniusAppbar createState() => _GeniusAppbar();
}

class _GeniusAppbar extends State<GeniusAppbar> {
  _GeniusAppbar();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Container(
              decoration: BoxDecoration(),
              child: Stack(children: [
                Positioned(
                  right: 0,
                  width: 36.6,
                  top: 7.5,
                  child: HamburgerMenuIconCustom(
                      child: const Icon(
                    Icons.menu,
                    size: 30,
                  )),
                ),
                Positioned(
                  left: 2,
                  top: 0,
                  child: widget.ovrGeniusAppbarLogo ??
                      IconButton(
                          onPressed: () {
                            context
                                .read<NavigationOverlayCubit>()
                                .selectNavigation(NavigationScreen.dashboard);
                          },
                          iconSize: 30,
                          icon: Image.asset(
                            'assets/images/geniusappbarlogo.png',
                            package: 'genius_wallet',
                            height: 30,
                            width: 30,
                          )),
                ),
              ])),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
