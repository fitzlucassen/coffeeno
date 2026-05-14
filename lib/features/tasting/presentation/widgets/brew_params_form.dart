import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import 'package:coffeeno/core/constants/app_constants.dart';
import 'package:coffeeno/core/widgets/app_text_field.dart';

/// A reusable form section for capturing brew parameters.
class BrewParamsForm extends StatelessWidget {
  const BrewParamsForm({
    super.key,
    required this.selectedBrewMethod,
    required this.selectedGrindSize,
    required this.doseController,
    required this.waterController,
    required this.ratioDisplay,
    required this.brewTimeMinutes,
    required this.brewTimeSeconds,
    required this.waterTempC,
    required this.onBrewMethodChanged,
    required this.onGrindSizeChanged,
    required this.onDoseOrWaterChanged,
    required this.onBrewTimeChanged,
    required this.onWaterTempChanged,
  });

  final BrewMethod? selectedBrewMethod;
  final GrindSize? selectedGrindSize;
  final TextEditingController doseController;
  final TextEditingController waterController;
  final String ratioDisplay;
  final int brewTimeMinutes;
  final int brewTimeSeconds;
  final int? waterTempC;
  final ValueChanged<BrewMethod?> onBrewMethodChanged;
  final ValueChanged<GrindSize?> onGrindSizeChanged;
  final VoidCallback onDoseOrWaterChanged;
  final void Function(int minutes, int seconds) onBrewTimeChanged;
  final ValueChanged<int?> onWaterTempChanged;

  // The seconds dropdown only has 5-second steps (0, 5, 10, ...); snap any
  // external value (e.g. from an AI suggestion) to the nearest one so the
  // dropdown always has a matching item.
  int _snapToFive(int seconds) {
    final clamped = seconds.clamp(0, 55);
    return ((clamped / 5).round()) * 5;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.brewMethod,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),

        // Brew method — keyed on the value so the FormField rebuilds when
        // the parent sets it externally (e.g. from an AI suggestion).
        // Without this, initialValue is one-shot and the dropdown asserts.
        DropdownButtonFormField<BrewMethod>(
          key: ValueKey('brewMethod-${selectedBrewMethod?.name}'),
          initialValue: selectedBrewMethod,
          decoration: InputDecoration(
            labelText: l10n.brewMethod,
            prefixIcon: const Icon(Icons.coffee_maker_rounded),
          ),
          items: BrewMethod.values
              .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
              .toList(),
          onChanged: onBrewMethodChanged,
          validator: (v) => v == null ? 'Required' : null,
        ),
        const SizedBox(height: 16),

        // Grind size — same keyed pattern as brew method above.
        DropdownButtonFormField<GrindSize>(
          key: ValueKey('grindSize-${selectedGrindSize?.name}'),
          initialValue: selectedGrindSize,
          decoration: InputDecoration(
            labelText: l10n.grindSize,
            prefixIcon: const Icon(Icons.grain_rounded),
          ),
          items: GrindSize.values
              .map((g) => DropdownMenuItem(value: g, child: Text(g.label)))
              .toList(),
          onChanged: onGrindSizeChanged,
          validator: (v) => v == null ? 'Required' : null,
        ),
        const SizedBox(height: 16),

        // Dose & Water
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: doseController,
                label: l10n.dose,
                prefixIcon: Icons.scale_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                onChanged: (_) => onDoseOrWaterChanged(),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: waterController,
                label: l10n.waterAmount,
                prefixIcon: Icons.water_drop_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                onChanged: (_) => onDoseOrWaterChanged(),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Ratio display
        if (ratioDisplay.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '${l10n.ratio}: $ratioDisplay',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Brew time
        Text(l10n.brewTime, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            // Minutes
            SizedBox(
              width: 80,
              child: DropdownButtonFormField<int>(
                key: ValueKey('brewMinutes-$brewTimeMinutes'),
                initialValue: brewTimeMinutes,
                decoration: const InputDecoration(
                  labelText: 'Min',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: List.generate(
                  16,
                  (i) => DropdownMenuItem(value: i, child: Text('$i')),
                ),
                onChanged: (v) =>
                    onBrewTimeChanged(v ?? 0, brewTimeSeconds),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(':', style: theme.textTheme.titleLarge),
            ),
            // Seconds. The suggestion service may return an arbitrary number
            // of seconds (e.g. 28), but this dropdown only accepts multiples
            // of 5. Snap to the nearest 5-sec step so `initialValue` always
            // matches one of the items — otherwise Flutter's dropdown
            // assertion fires.
            SizedBox(
              width: 80,
              child: DropdownButtonFormField<int>(
                key: ValueKey('brewSeconds-${_snapToFive(brewTimeSeconds)}'),
                initialValue: _snapToFive(brewTimeSeconds),
                decoration: const InputDecoration(
                  labelText: 'Sec',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: List.generate(
                  12,
                  (i) => DropdownMenuItem(
                    value: i * 5,
                    child: Text((i * 5).toString().padLeft(2, '0')),
                  ),
                ),
                onChanged: (v) =>
                    onBrewTimeChanged(brewTimeMinutes, v ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Water temperature
        AppTextField(
          label: l10n.waterTemperature,
          prefixIcon: Icons.thermostat_rounded,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          hint: '93',
          onChanged: (v) => onWaterTempChanged(int.tryParse(v)),
        ),
      ],
    );
  }
}
