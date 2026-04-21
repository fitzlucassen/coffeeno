import 'package:flutter/material.dart';

import 'package:coffeeno/features/tasting/domain/tasting.dart';

/// A visually appealing card widget designed for sharing a tasting as an image.
///
/// Sized at 400x520 pixels. Uses the app's warm color palette
/// (cream, espresso, terracotta) and the Plus Jakarta Sans font.
class TastingShareCard extends StatelessWidget {
  const TastingShareCard({super.key, required this.tasting});

  final Tasting tasting;

  static const _cream = Color(0xFFFFF8F0);
  static const _espresso = Color(0xFF3C2415);
  static const _espressoLight = Color(0xFF5C3D2E);
  static const _espressoMuted = Color(0xFF8B7355);
  static const _terracotta = Color(0xFFCC704B);
  static const _terracottaLight = Color(0xFFE8956E);
  static const _sage = Color(0xFF8FA68A);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 520,
      child: Material(
        color: _cream,
        borderRadius: BorderRadius.circular(24),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: _cream,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _espressoMuted.withValues(alpha: 0.15),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coffee name
              Text(
                tasting.coffeeName,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _espresso,
                  height: 1.2,
                  decoration: TextDecoration.none,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Roaster
              Text(
                tasting.roasterName,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _espressoMuted,
                  decoration: TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),

              // Overall rating - big number + stars
              Center(
                child: Column(
                  children: [
                    Text(
                      tasting.overallRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: _terracotta,
                        height: 1.0,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStars(tasting.overallRating),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Brew method chip
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _sage.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.coffee_maker_rounded,
                        size: 16,
                        color: _sage,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tasting.brewMethod,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _espressoLight,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Flavor scores grid
              _buildFlavorScores(),

              const Spacer(),

              // Branding footer
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_cafe_rounded,
                      size: 16,
                      color: _espressoMuted.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Coffeeno',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _espressoMuted.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                        decoration: TextDecoration.none,
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

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        IconData icon;
        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(
          icon,
          size: 24,
          color: rating >= starValue - 0.5
              ? _terracottaLight
              : _espressoMuted.withValues(alpha: 0.3),
        );
      }),
    );
  }

  Widget _buildFlavorScores() {
    final scores = [
      ('Aroma', tasting.aroma),
      ('Flavor', tasting.flavor),
      ('Acidity', tasting.acidity),
      ('Body', tasting.body),
      ('Sweet', tasting.sweetness),
      ('Finish', tasting.aftertaste),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: scores.map((entry) {
        final (label, value) = entry;
        return SizedBox(
          width: 100,
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _espressoMuted,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _ScoreBar(value: value, maxValue: 5),
              ),
              const SizedBox(width: 6),
              Text(
                '$value',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _espresso,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.value, required this.maxValue});

  final int value;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    const barColor = Color(0xFFCC704B);
    const trackColor = Color(0xFFE8D5C4);

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 6,
        child: LinearProgressIndicator(
          value: value / maxValue,
          backgroundColor: trackColor,
          valueColor: const AlwaysStoppedAnimation<Color>(barColor),
        ),
      ),
    );
  }
}
