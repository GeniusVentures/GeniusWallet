import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';

class AppScreenDesktop extends StatelessWidget {
  final String title;
  final List<Widget> bodyWidgets;

  const AppScreenDesktop({
    Key? key,
    required this.title,
    required this.bodyWidgets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenView(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 50,
                width: 100,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return BackButtonHeader(
                      constraints,
                      ovrTitle: '',
                    );
                  },
                ),
              ),
              const Spacer(),
              Text(title),
              const Spacer()
            ],
          ),
          const SizedBox(height: 240),
          ...bodyWidgets
        ],
      ),
    );
  }
}
