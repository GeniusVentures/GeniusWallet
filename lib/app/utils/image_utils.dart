import 'package:flutter/material.dart';

Widget buildTokenIcon({required String iconPath, required double size}) {
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
Widget _defaultIcon(size) {
  return Container(
    height: size,
    width: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.grey, // Background color for default icon
    ),
    child: const Icon(Icons.image_not_supported, color: Colors.white),
  );
}
