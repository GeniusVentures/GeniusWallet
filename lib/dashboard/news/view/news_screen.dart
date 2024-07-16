import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/news.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/desktop_container.dart';
import 'package:genius_wallet/app/widgets/responsive_dashboard_layout.dart';
import 'package:genius_wallet/app/widgets/responsive_grid.dart';
import 'package:genius_wallet/dashboard/news/view/bloc/news_cubit.dart';
import 'package:genius_wallet/dashboard/news/view/bloc/news_state.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!GeniusBreakpoints.isNativeApp(context)) {
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
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 3,
                child: Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        flex: 1,
                        child: NewsCard(news: state.news[0], height: 400)),
                    Expanded(
                        flex: 3,
                        child: NewsCard(news: state.news[1], height: 400))
                  ]),
                  Row(children: [
                    Expanded(
                        flex: 3,
                        child: NewsCard(news: state.news[2], height: 400)),
                    Expanded(
                        flex: 1,
                        child: NewsCard(news: state.news[3], height: 400))
                  ])
                ])),
            Expanded(
                flex: 1, child: NewsCard(news: state.news[4], height: 800)),
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
            child: BlocBuilder<NewsCubit, NewsState>(builder: (context, state) {
              if (state.newsLoadingStatus == NewsStatus.loading) {
                return const LoadingScreen();
              }
              return Column(children: [
                for (var news in state.news)
                  SizedBox(
                    height: 350,
                    width: 350,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Text(news.body ?? '');
                      },
                    ),
                  ),
              ]);
            })),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final News news;
  final double height;
  const NewsCard({Key? key, required this.news, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        child: CustomScrollView(slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child: Flex(direction: Axis.horizontal, children: [
                Expanded(
                    child: Card(
                        color: GeniusWalletColors.deepBlueCardColor,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (news.imgSrc != null)
                                Image.network(news.imgSrc ?? ""),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 24, bottom: 24),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          news.date ?? '',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(news.headline ?? '',
                                            style:
                                                const TextStyle(fontSize: 20)),
                                        const SizedBox(height: 8),
                                        Text(news.body ?? '',
                                            style:
                                                const TextStyle(fontSize: 14))
                                      ])),
                            ])))
              ]))
        ]));
  }
}
