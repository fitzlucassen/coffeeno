import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../domain/coffee.dart';

/// Displays a coffee's metadata in a clean two-column grid with icons.
class CoffeeMetadataSection extends StatelessWidget {
  const CoffeeMetadataSection({super.key, required this.coffee});

  final Coffee coffee;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final entries = <_MetadataEntry>[
      _MetadataEntry(
        icon: Icons.public_rounded,
        label: l10n.originCountry,
        value: coffee.originCountry,
      ),
      if (coffee.originRegion != null)
        _MetadataEntry(
          icon: Icons.place_rounded,
          label: l10n.originRegion,
          value: coffee.originRegion!,
        ),
      if (coffee.farmName != null)
        _MetadataEntry(
          icon: Icons.agriculture_rounded,
          label: l10n.farmName,
          value: coffee.farmName!,
        ),
      if (coffee.farmerName != null)
        _MetadataEntry(
          icon: Icons.person_rounded,
          label: l10n.farmerName,
          value: coffee.farmerName!,
        ),
      if (coffee.altitude != null)
        _MetadataEntry(
          icon: Icons.terrain_rounded,
          label: l10n.altitude,
          value: coffee.altitude!,
        ),
      if (coffee.variety != null)
        _MetadataEntry(
          icon: Icons.eco_rounded,
          label: l10n.variety,
          value: coffee.variety!,
        ),
      if (coffee.processingMethod != null)
        _MetadataEntry(
          icon: Icons.water_drop_rounded,
          label: l10n.processingMethod,
          value: coffee.processingMethod!,
        ),
      if (coffee.roastLevel != null)
        _MetadataEntry(
          icon: Icons.local_fire_department_rounded,
          label: l10n.roastLevel,
          value: coffee.roastLevel!,
        ),
      if (coffee.roastDate != null)
        _MetadataEntry(
          icon: Icons.calendar_today_rounded,
          label: l10n.roastDate,
          value: DateFormat.yMMMd().format(coffee.roastDate!),
        ),
      if (coffee.price != null)
        _MetadataEntry(
          icon: Icons.euro_rounded,
          label: l10n.price,
          value: '${coffee.price!.toStringAsFixed(2)} €',
        ),
      if (coffee.lot != null)
        _MetadataEntry(
          icon: Icons.tag_rounded,
          label: l10n.lot,
          value: coffee.lot!,
        ),
      if (coffee.harvestYear != null)
        _MetadataEntry(
          icon: Icons.grass_rounded,
          label: l10n.harvestYear,
          value: coffee.harvestYear.toString(),
        ),
    ];

    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Row(
              children: [
                Icon(
                  entry.icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.label,
                        style: theme.textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        entry.value,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MetadataEntry {
  const _MetadataEntry({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
