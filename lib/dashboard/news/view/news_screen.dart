import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/news.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/desktop_container.dart';
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
          double screenWidth = MediaQuery.of(context).size.width;
          if (screenWidth < 1400) {
            return ResponsiveGrid(children: [
              for (var news in state.news) NewsCard(news: news, height: 400)
            ]);
          }
          double rowGap = 4;
          double padding = 200;
          double height = MediaQuery.of(context).size.height;
          double fullHeight = height - padding + rowGap;
          double halfHeight = height * .5 - padding * .5;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 3,
                child: Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        flex: 1,
                        child: NewsCard(
                          news: state.news[0],
                          height: halfHeight,
                          isBackgroundImage: true,
                        )),
                    Expanded(
                        flex: 2,
                        child: NewsCard(
                          news: state.news[1],
                          height: halfHeight,
                          isBackgroundImage: true,
                        ))
                  ]),
                  const SizedBox(height: 4),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        flex: 2,
                        child: NewsCard(
                          news: state.news[2],
                          height: halfHeight,
                          isBackgroundImage: true,
                        )),
                    Expanded(
                        flex: 1,
                        child: NewsCard(
                          news: state.news[3],
                          height: halfHeight,
                          isBackgroundImage: true,
                        ))
                  ])
                ])),
            Expanded(
                flex: 1,
                child: NewsCard(news: state.news[4], height: fullHeight)),
          ]);
        }));
  }
}

class Mobile extends StatelessWidget {
  const Mobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: BlocBuilder<NewsCubit, NewsState>(builder: (context, state) {
          if (state.newsLoadingStatus == NewsStatus.loading) {
            return const LoadingScreen();
          }
          return Column(children: [
            for (var news in state.news) NewsCard(news: news, height: 600)
          ]);
        }));
  }
}

class NewsCard extends StatelessWidget {
  final News news;
  final double height;
  final bool isBackgroundImage;
  const NewsCard(
      {Key? key,
      required this.news,
      required this.height,
      this.isBackgroundImage = false})
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
                    child: Container(
                        decoration: isBackgroundImage == true
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(news.imgSrc ?? ""),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      GeniusWalletColors.deepBlueCardColor
                                          .withOpacity(.6),
                                      BlendMode.darken),
                                ),
                                color: GeniusWalletColors.deepBlueCardColor,
                              )
                            : const BoxDecoration(
                                color: GeniusWalletColors.deepBlueCardColor),
                        margin: const EdgeInsets.all(8),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (news.imgSrc != null &&
                                  isBackgroundImage == false)
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
                                                const TextStyle(fontSize: 14)),
                                      ])),
                            ])))
              ]))
        ]));
  }
}
