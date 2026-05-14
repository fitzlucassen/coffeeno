import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A round, tappable avatar used on profile-edit screens (roaster, farm) that
/// shows either the currently-saved [photoUrl], a freshly-picked local image
/// via [pendingPath], or an icon fallback when neither exists.
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({
    super.key,
    required this.photoUrl,
    required this.pendingPath,
    required this.uploading,
    required this.onTap,
    required this.fallbackIcon,
    this.size = 112,
  });

  final String? photoUrl;
  final String? pendingPath;
  final bool uploading;
  final VoidCallback onTap;
  final IconData fallbackIcon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: _buildContent(colorScheme),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: uploading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    if (pendingPath != null) {
      return Image.file(File(pendingPath!), fit: BoxFit.cover);
    }
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => _fallback(colorScheme),
      );
    }
    return _fallback(colorScheme);
  }

  Widget _fallback(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.secondaryContainer,
      child: Icon(
        fallbackIcon,
        size: size * 0.4,
        color: colorScheme.onSecondaryContainer.withValues(alpha: 0.6),
      ),
    );
  }
}
