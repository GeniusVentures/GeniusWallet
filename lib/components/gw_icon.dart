import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Unified Icon API. Prefer this over mixing `Icons.*`, `SvgPicture.asset`,
/// and `Image.asset` at call sites.
class GWIcon extends StatelessWidget {
  const GWIcon.material(
    this.materialIcon, {
    super.key,
    this.size = 20,
    this.color,
    this.package,
    this.semanticLabel,
  })  : svgAsset = null,
        pngAsset = null;

  const GWIcon.svg(
    String this.svgAsset, {
    super.key,
    this.size = 20,
    this.color,
    this.package = 'genius_wallet',
    this.semanticLabel,
  })  : materialIcon = null,
        pngAsset = null;

  const GWIcon.png(
    String this.pngAsset, {
    super.key,
    this.size = 20,
    this.color,
    this.package = 'genius_wallet',
    this.semanticLabel,
  })  : materialIcon = null,
        svgAsset = null;

  final IconData? materialIcon;
  final String? svgAsset;
  final String? pngAsset;
  final double size;
  final Color? color;
  final String? package;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (materialIcon != null) {
      return Icon(
        materialIcon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    }
    if (svgAsset != null) {
      return SvgPicture.asset(
        svgAsset!,
        package: package,
        width: size,
        height: size,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        semanticsLabel: semanticLabel,
      );
    }
    return Image.asset(
      pngAsset!,
      package: package,
      width: size,
      height: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}
