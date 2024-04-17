import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/registration_header.g.dart';

class AppScreenWithHeaderMobile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;
  final Widget footer;

  const AppScreenWithHeaderMobile({
    Key? key,
    required this.title,
    required this.subtitle,
    this.body = const SizedBox(),
    this.footer = const SizedBox(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return RegistrationHeader(
                    constraints,
                    ovrTitle: title,
                    ovrSubtitle: subtitle,
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: body),
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
    );
  }
}
