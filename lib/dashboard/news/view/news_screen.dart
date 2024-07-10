import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/desktop_container.dart';
import 'package:genius_wallet/dashboard/news/view/bloc/news_cubit.dart';
import 'package:genius_wallet/dashboard/news/view/bloc/news_state.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/date_selector.g.dart';
import 'package:genius_wallet/widgets/components/transaction_filter.g.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (GeniusBreakpoints.useDesktopLayout(context)) {
      return BlocProvider(
        create: (context) =>
            NewsCubit(api: context.read<GeniusApi>())..loadNews(),
        child: const Desktop(),
      );
    }
    return AppScreenView(
      body: BlocProvider(
        create: (context) =>
            NewsCubit(api: context.read<GeniusApi>())..loadNews(),
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
        title: 'Crypto News',
        child: BlocBuilder<NewsCubit, NewsState>(builder: (context, state) {
          if (state.newsLoadingStatus == NewsStatus.loading) {
            return const LoadingScreen();
          }
          return Wrap(
              spacing: GeniusWalletConsts.itemSpacing,
              runSpacing: GeniusWalletConsts.itemSpacing,
              children: [
                for (var news in state.news)
                  SizedBox(
                    height: 350,
                    width: 350,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Text(news.headline);
                      },
                    ),
                  ),
              ]);
        }));
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
