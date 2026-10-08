import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// A swap token's logo in a circle of [size]. Squid serves many logos as SVG,
/// which Image.network cannot decode, so those go through flutter_svg. A
/// missing or loading logo is a neutral disc; a broken one adds an icon.
class SwapTokenLogo extends StatelessWidget {
  const SwapTokenLogo({super.key, required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final url = this.url;
    final blank = Container(width: size, height: size, color: gw.surfaceMenu);
    final broken = Container(
      width: size,
      height: size,
      color: gw.surfaceMenu,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image, color: gw.textSecondary, size: 16),
    );
    final Widget logo;
    if (url == null) {
      logo = blank;
    } else if (_isSvg(url)) {
      // A failed SVG still shows the broken disc, but flutter_svg also reports
      // the failure as an uncaught async error, so it reaches Sentry.
      logo = SvgPicture.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => blank,
        errorBuilder: (_, _, _) => broken,
      );
    } else {
      logo = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : blank,
        errorBuilder: (_, _, _) => broken,
      );
    }
    return ClipOval(child: logo);
  }
}

// ponytail: decided by the URL's extension, so an SVG served without `.svg`
// still fails to decode and shows the broken disc. Knowing for sure needs the
// response content type, which means fetching the logo ourselves.
bool _isSvg(String url) =>
    (Uri.tryParse(url)?.path ?? url).toLowerCase().endsWith('.svg');
