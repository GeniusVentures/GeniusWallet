import 'package:flutter/material.dart';

class AppScreenView extends StatelessWidget {
  final Widget body;
  const AppScreenView({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: body,
            ),
          ],
        ),
      ],
    );
  }
}
