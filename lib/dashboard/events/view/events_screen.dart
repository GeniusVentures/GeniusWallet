import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/desktop_container.dart';
import 'package:genius_wallet/dashboard/events/view/bloc/events_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/date_selector.g.dart';
import 'package:genius_wallet/widgets/components/transaction_filter.g.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (GeniusBreakpoints.useDesktopLayout(context)) {
      return BlocProvider(
        create: (context) =>
            EventsCubit(api: context.read<GeniusApi>())..loadEvents(),
        child: const Desktop(),
      );
    }
    return AppScreenView(
      body: BlocProvider(
        create: (context) =>
            EventsCubit(api: context.read<GeniusApi>())..loadEvents(),
        child: const Mobile(),
      ),
    );
  }
}

class Desktop extends StatelessWidget {
  const Desktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DesktopContainer(
      title: 'Events',
      child: Column(
        children: [
          const SizedBox(height: 30),
          const SizedBox(height: 50),
          SizedBox(
            height: 20,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return TransactionFilter(constraints);
              },
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class Mobile extends StatelessWidget {
  const Mobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueTertiary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const SizedBox(height: 30),
              SizedBox(
                height: 30,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return DateSelector(constraints);
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
