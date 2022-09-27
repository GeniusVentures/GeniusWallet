import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/widgets/components/registration_header.g.dart';

class AppScreenWithHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> bodyWidgets;
  final Widget footer;

  const AppScreenWithHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.bodyWidgets,
    this.footer = const SizedBox(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenView(
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 190,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return RegistrationHeader(
                  constraints,
                  ovrTitle: title,
                  ovrSubtitle: subtitle,
                );
              },
            ),
          ),
          const SizedBox(height: 50),
          ...bodyWidgets,
        ],
      ),
      footer: footer,
    );
  }
}
