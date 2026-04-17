import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:coffeeno/features/map/domain/origin_stats.dart';

/// A wrapper around [FlutterMap] configured for displaying coffee origin
/// markers on an OpenStreetMap tile layer.
class WorldMap extends StatelessWidget {
  const WorldMap({
    super.key,
    required this.origins,
    required this.onMarkerTap,
  });

  final List<OriginStats> origins;
  final void Function(OriginStats origin) onMarkerTap;

  /// Computes marker radius proportional to coffee count,
  /// clamped between 12 and 36 pixels.
  double _markerRadius(OriginStats origin) {
    if (origins.isEmpty) return 16;
    final maxCount =
        origins.map((o) => o.coffeeCount).reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) return 16;
    final ratio = origin.coffeeCount / maxCount;
    return 12 + (ratio * 24);
  }

  /// Computes marker color intensity based on average rating.
  /// Higher ratings -> deeper terracotta, lower -> lighter/muted.
  Color _markerColor(OriginStats origin) {
    final normalized = (origin.avgRating / 5.0).clamp(0.0, 1.0);
    return Color.lerp(
      const Color(0xFFB5C9B0), // sageMuted
      const Color(0xFFCC704B), // terracotta
      normalized,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(5, 20),
        initialZoom: 2.0,
        minZoom: 1.5,
        maxZoom: 8,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.coffeeno.app',
        ),
        MarkerLayer(
          markers: origins
              .where((o) => o.latitude != 0 || o.longitude != 0)
              .map((origin) {
            final radius = _markerRadius(origin);
            final color = _markerColor(origin);

            return Marker(
              point: LatLng(origin.latitude, origin.longitude),
              width: radius * 2,
              height: radius * 2,
              child: GestureDetector(
                onTap: () => onMarkerTap(origin),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.85),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${origin.coffeeCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
