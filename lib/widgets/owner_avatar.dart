import 'package:flutter/material.dart';

import '../theme/colors/app_colors.dart';

/// Small "who made this" badge shown on shared transactions: a circle with
/// the owner's initial, teal for the current user and blue for their linked
/// partner. Designed to sit as a corner badge on top of the existing
/// category icon bubble without crowding the row.
class OwnerAvatar extends StatelessWidget {
  const OwnerAvatar({
    super.key,
    required this.name,
    required this.isMine,
    this.photoUrl,
    this.size = 20,
  });

  final String name;
  final bool isMine;
  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final color = isMine ? AppColors.primaryColor : AppColors.infoColor;
    final photoUrl = this.photoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    // A thin primary-colored ring frames the badge, and `ClipOval` (not
    // decoration-based clipping) guarantees the photo itself is a crisp,
    // perfect circle.
    const ringWidth = 1.5;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                // Falls back to the initial letter on any load failure
                // (offline, expired URL, etc.) instead of a broken icon.
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: color,
                  child: Center(child: _Initial(initial, size)),
                ),
              )
            : ColoredBox(
                color: color,
                child: Center(child: _Initial(initial, size)),
              ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial(this.initial, this.size);

  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      initial,
      style: TextStyle(
        color: AppColors.white,
        fontSize: size * 0.5,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }
}

/// Wraps [child] (the existing category icon bubble) with an [OwnerAvatar]
/// badge pinned to its bottom-right corner. When [ownerName] is null
/// (no couple linked, or the transaction isn't shared) it renders [child]
/// unchanged — zero visual difference for users without a linked partner.
class OwnerBadgedIcon extends StatelessWidget {
  const OwnerBadgedIcon({
    super.key,
    required this.child,
    this.ownerName,
    this.ownerPhotoUrl,
    this.isMine = true,
    this.badgeSize = 20,
  });

  final Widget child;
  final String? ownerName;
  final String? ownerPhotoUrl;
  final bool isMine;
  final double badgeSize;

  @override
  Widget build(BuildContext context) {
    final ownerName = this.ownerName;
    if (ownerName == null || ownerName.trim().isEmpty) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -2,
          bottom: -2,
          child: OwnerAvatar(
            name: ownerName,
            isMine: isMine,
            photoUrl: ownerPhotoUrl,
            size: badgeSize,
          ),
        ),
      ],
    );
  }
}
