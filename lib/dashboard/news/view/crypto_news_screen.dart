import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/hive/models/news_article.dart';
import 'package:genius_wallet/services/coin_telegraph/coin_telegraph_api.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/web/web_utils.dart';

class CryptoNewsScreen extends StatefulWidget {
  const CryptoNewsScreen({super.key});

  @override
  State<CryptoNewsScreen> createState() => _CryptoNewsScreenState();
}

class _CryptoNewsScreenState extends State<CryptoNewsScreen> {
  late final Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = fetchCoinTelegraphNews();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: GeniusBreakpoints.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crypto News',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureStateWidget<List<NewsArticle>>(
                  future: _newsFuture,
                  error: const Center(child: Text('Failed to load news.')),
                  onData: (articles) {
                    if (articles.isEmpty) {
                      return const Center(child: Text('No news found.'));
                    }
                    return SingleChildScrollView(
                      child: StaggeredGrid.extent(
                        maxCrossAxisExtent: 300,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: List.generate(articles.length, (index) {
                          final crossAxisCellCount = index % 5 == 0 ? 2 : 1;
                          return StaggeredGridTile.extent(
                            crossAxisCellCount: crossAxisCellCount,
                            mainAxisExtent: 220,
                            child: _NewsCard(article: articles[index]),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsCard extends StatefulWidget {
  final NewsArticle article;

  const _NewsCard({required this.article});

  @override
  State<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<_NewsCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => launchWebSite(context, widget.article.link),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              CachedNetworkImage(
                imageUrl: widget.article.imageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade800,
                  child: const Center(child: Loading()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
              // Gradient overlay for text readability
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _TextOverlay(article: widget.article),
              ),
              // Hover overlay
              if (_isHovered)
                Container(
                  color: Colors.black87,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Text(
                        widget.article.title.trim(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.article.pubDate,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextOverlay extends StatelessWidget {
  final NewsArticle article;

  const _TextOverlay({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black54,
            Colors.black,
          ],
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 4.0,
        children: [
          Text(
            article.title.trim(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            article.pubDate,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
