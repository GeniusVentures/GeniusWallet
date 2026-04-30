import 'package:flutter/material.dart';

class DesktopBodyContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final String? title;
  final String? subText;
  const DesktopBodyContainer(
      {super.key,
      this.child = const SizedBox(),
      this.width = 600,
      this.height,
      this.subText,
      this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: Column(children: [
          Text(title ?? "",
              style:
                  const TextStyle(fontSize: 48, fontWeight: FontWeight.w500)),
          const SizedBox(
            height: 20,
          ),
          Text(subText ?? ""),
          const SizedBox(
            height: 20,
          ),
          child
        ]));
  }
}
