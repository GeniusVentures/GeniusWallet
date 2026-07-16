import 'package:flutter/material.dart';

class AppScreenView extends StatelessWidget {
  final Widget body;
  final Widget footer;
  const AppScreenView({
    super.key,
    required this.body,
    this.footer = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: body,
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 50),
                  child: footer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
