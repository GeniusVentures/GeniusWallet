import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/overlay/desktop_tab_bar.dart';
import 'package:genius_wallet/test/dev_tools_widget.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class DesktopOverlay extends StatelessWidget {
  final Widget child;
  const DesktopOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: GeniusWalletColors.deepBlueTertiary,
        body: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return Column(
              children: [
                const DevToolsWidget(),
                const DesktopTopBar(),
                Expanded(child: child),
              ],
            );
          },
        ),
      ),
    );
  }
}
