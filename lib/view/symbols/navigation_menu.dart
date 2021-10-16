import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  final constraints;

  NavigationMenu(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 0.887,
        height: constraints.maxHeight * 0.514,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 11,
                  child: Padding(
                      padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.84,
                      ),
                      child: Image.asset(
                        'assets/images/0_12092.png',
                        width: constraints.maxWidth * 0.044,
                        height: constraints.maxHeight * 0.054,
                      )),
                ),
                Flexible(
                  flex: 100,
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.85,
                      ),
                      child: Image.asset(
                        'assets/images/0_12096.png',
                        width: constraints.maxWidth * 0.041,
                        height: constraints.maxHeight * 0.514,
                      )),
                ),
              ]),
        ));
  }
}
