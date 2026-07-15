import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

Widget buildTokenIcon({String? iconPath, required double size}) {
  if (iconPath == null || iconPath.isEmpty) {
    return _defaultIcon(size);
  }

  bool isNetworkImage =
      iconPath.startsWith('http') || iconPath.startsWith('https');

  return ClipOval(
    child: isNetworkImage
        ? Image.network(
            iconPath,
            height: size,
            width: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _defaultIcon(size);
            },
          )
        : Image.asset(
            iconPath,
            height: size,
            width: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _defaultIcon(size);
            },
          ),
  );
}

/// Default icon when image fails to load
Widget _defaultIcon(double size) {
  return Container(
    height: size,
    width: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.grey, // Background color for default icon
    ),
    child:
        Icon(Icons.image_not_supported, color: GeniusWalletColors.textPrimary),
  );
}
