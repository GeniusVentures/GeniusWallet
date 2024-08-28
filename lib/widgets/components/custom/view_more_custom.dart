import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:go_router/go_router.dart';

class ViewMoreCustom extends StatefulWidget {
  final Widget? child;
  ViewMoreCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _ViewMoreCustomState createState() => _ViewMoreCustomState();
}

class _ViewMoreCustomState extends State<ViewMoreCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        context
            .read<NavigationOverlayCubit>()
            .selectNavigation(NavigationScreen.transactions);
      },
      child: widget.child!,
    );
  }
}
