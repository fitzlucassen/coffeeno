import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A reusable circular avatar widget that displays a user's profile photo
/// or falls back to their initials.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.displayName,
    this.size = UserAvatarSize.medium,
    this.onTap,
  });

  final String? imageUrl;
  final String displayName;
  final UserAvatarSize size;
  final VoidCallback? onTap;

  double get _diameter {
    return switch (size) {
      UserAvatarSize.small => 32,
      UserAvatarSize.medium => 40,
      UserAvatarSize.large => 56,
    };
  }

  String get _initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final avatar = imageUrl != null && imageUrl!.isNotEmpty
        ? CircleAvatar(
            radius: _diameter / 2,
            backgroundColor: colorScheme.secondaryContainer,
            backgroundImage: CachedNetworkImageProvider(imageUrl!),
          )
        : CircleAvatar(
            radius: _diameter / 2,
            backgroundColor: colorScheme.secondaryContainer,
            child: Text(
              _initials,
              style: TextStyle(
                fontSize: _diameter * 0.38,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          );

    if (onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }
}

enum UserAvatarSize { small, medium, large }
