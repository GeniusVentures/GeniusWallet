import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// [tint] recolours an asset icon, for the white testnet artwork on a light
/// surface; remote logos are never tinted.
Widget buildTokenIcon({
  String? iconPath,
  required double size,
  String? label,
  Color? tint,
}) {
  return TokenIcon(iconPath: iconPath, size: size, label: label, tint: tint);
}

/// A token logo that never leaves a hole: a missing, unparsable or failed
/// image shows the token's first letters on a neutral disc instead.
class TokenIcon extends StatelessWidget {
  const TokenIcon({
    super.key,
    this.iconPath,
    required this.size,
    this.label,
    this.tint,
  });

  final String? iconPath;
  final double size;
  final Color? tint;

  /// Symbol or name; its first letters fill the disc when no logo loads.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>()!;
    final path = iconPath;
    final fallback = _FallbackDisc(size: size, label: label);
    if (path == null || path.isEmpty) {
      return fallback;
    }

    final isNetwork = path.startsWith('http');
    // Squid serves many logos as SVG; Image.network cannot decode them.
    // ponytail: judged by the URL's extension, so an SVG served without
    // `.svg` falls back to the letters; knowing needs the content type.
    final isSvg = (Uri.tryParse(path)?.path ?? path).toLowerCase().endsWith(
      '.svg',
    );
    final Widget image;
    if (isSvg && isNetwork) {
      image = SvgPicture.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => fallback,
        errorBuilder: (_, _, _) => fallback,
      );
    } else if (isNetwork) {
      image = Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallback,
        errorBuilder: (_, _, _) => fallback,
      );
    } else {
      image = Image.asset(
        path,
        width: size,
        height: size,
        color: tint,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    // Dark-on-transparent remote logos (USDFI) vanish on dark surfaces, so the
    // disc behind them is light in dark mode. Bundled icons are tinted to the
    // same colour and need no backing.
    final backed = Theme.of(context).brightness == Brightness.dark && isNetwork;
    return ClipOval(
      child: backed ? ColoredBox(color: gw.textPrimary, child: image) : image,
    );
  }
}

class _FallbackDisc extends StatelessWidget {
  const _FallbackDisc({required this.size, this.label});

  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>()!;
    final text = (label ?? '').trim();
    final letters = text.isEmpty
        ? '?'
        : text.substring(0, text.length < 2 ? text.length : 2).toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: gw.surfaceMenu),
      child: Text(
        letters,
        style: GeniusWalletTypography.titleMd.copyWith(
          color: gw.textSecondary,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
