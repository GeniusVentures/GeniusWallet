import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';

class AppScreenWithBackButtonHeader extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScreenWithBackButtonHeader({
    Key? key,
    required this.title,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SizedBox(
                height: 40,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return BackButtonHeader(
                      constraints,
                      ovrTitle: title,
                    );
                  },
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: body,
          ),
        ],
      ),
    );
  }
}
