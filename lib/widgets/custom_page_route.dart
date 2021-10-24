import 'package:flutter/material.dart';

class SlidingPageRoute extends PageRouteBuilder {
  final Widget target;
  final AxisDirection direction;

  SlidingPageRoute({
    @required this.target,
    this.direction = AxisDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => target,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: getBeginOffset(),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Function that maps [AxisDirection] to [Offset]
  Offset getBeginOffset() {
    switch (direction) {
      case AxisDirection.up:
        return Offset(0, 1);
      case AxisDirection.down:
        return Offset(0, -1);
      case AxisDirection.right:
        return Offset(-1, 0);
      case AxisDirection.left:
        return Offset(1, 0);
      default:
        return Offset.zero;
    }
  }
}
