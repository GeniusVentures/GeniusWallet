import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/hive/models/news_article.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/web/web_utils.dart';

class WideNewsCard extends StatelessWidget {
  final NewsArticle article;

  const WideNewsCard({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => launchWebSite(context, article.link),
      child: Card(
        color: GeniusWalletColors.deepBlueCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            // Full image background
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
            // Overlay content
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: GeniusWalletColors.deepBlueTertiary.withOpacity(.7),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Text on top
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.pubDate,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
