import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/events.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/desktop_container.dart';
import 'package:genius_wallet/app/widgets/responsive_grid.dart';
import 'package:genius_wallet/dashboard/events/view/bloc/events_cubit.dart';
import 'package:genius_wallet/dashboard/events/view/bloc/events_state.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

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
        child: BlocBuilder<EventsCubit, EventsState>(builder: (context, state) {
          if (state.eventsLoadingStatus == EventsStatus.loading) {
            return const LoadingScreen();
          }

          return ResponsiveGrid(children: [
            for (var event in state.events) EventsCard(event: event)
          ]);
        }));
  }
}

class Mobile extends StatelessWidget {
  const Mobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(builder: (context, state) {
      if (state.eventsLoadingStatus == EventsStatus.loading) {
        return const LoadingScreen();
      }
      return Wrap(
          runSpacing: GeniusWalletConsts.itemSpacing,
          alignment: WrapAlignment.center,
          children: [
            for (var event in state.events)
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: EventsCard(event: event))
          ]);
    });
  }
}

class EventsCard extends StatelessWidget {
  final Events event;
  const EventsCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: GeniusWalletColors.deepBlueCardColor,
      child: SizedBox(
        height: 250, // Adjust height based on your layout
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 24),
          child: SingleChildScrollView(
            // Make content scrollable
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        event.date ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Flexible(
                      child: AutoSizeText(
                        event.weekDay ?? "",
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Divider(),
                const SizedBox(height: 4),
                ListTile(
                  horizontalTitleGap: 1,
                  contentPadding: const EdgeInsets.only(left: 0),
                  leading: const Icon(Icons.pin_drop),
                  title: Text(event.location ?? ''),
                ),
                const SizedBox(height: 16),
                AutoSizeText(
                  event.body ?? "",
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
