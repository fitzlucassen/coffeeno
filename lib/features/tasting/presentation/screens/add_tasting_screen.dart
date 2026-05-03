import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/core/widgets/app_button.dart';
import 'package:coffeeno/core/widgets/app_text_field.dart';
import 'package:coffeeno/core/constants/app_constants.dart';
import '../../../coffee/presentation/providers/coffee_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/upgrade_prompt.dart';
import '../../data/brew_suggestion_service.dart';
import '../../domain/tasting.dart';
import '../providers/tasting_provider.dart';
import '../widgets/brew_params_form.dart';
import '../widgets/flavor_selector.dart';
import '../widgets/tasting_notes_input.dart';

class AddTastingScreen extends ConsumerStatefulWidget {
  const AddTastingScreen({super.key, required this.coffeeId});

  final String coffeeId;

  @override
  ConsumerState<AddTastingScreen> createState() => _AddTastingScreenState();
}

class _AddTastingScreenState extends ConsumerState<AddTastingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doseController = TextEditingController();
  final _waterController = TextEditingController();
  final _notesController = TextEditingController();

  BrewMethod? _brewMethod;
  GrindSize? _grindSize;
  String _ratioDisplay = '';
  int _brewTimeMinutes = 3;
  int _brewTimeSeconds = 0;
  int? _waterTempC;

  int _aroma = 3;
  int _flavor = 3;
  int _acidity = 3;
  int _body = 3;
  int _sweetness = 3;
  int _aftertaste = 3;
  double _overallRating = 3.0;

  List<String> _flavorNotes = [];

  bool _isSaving = false;
  bool _isSuggesting = false;
  String? _suggestionTips;

  @override
  void dispose() {
    _doseController.dispose();
    _waterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateRatio() {
    final dose = double.tryParse(_doseController.text);
    final water = double.tryParse(_waterController.text);
    if (dose != null && dose > 0 && water != null && water > 0) {
      final ratio = water / dose;
      setState(() => _ratioDisplay = '1:${ratio.toStringAsFixed(1)}');
    } else {
      setState(() => _ratioDisplay = '');
    }
  }

  Future<void> _fetchSuggestion() async {
    setState(() {
      _isSuggesting = true;
      _suggestionTips = null;
    });

    try {
      final coffee =
          await ref.read(coffeeDetailProvider(widget.coffeeId).future);
      if (coffee == null) return;

      final service = BrewSuggestionService();
      final suggestion = await service.suggest(
        name: coffee.name,
        originCountry: coffee.originCountry,
        originRegion: coffee.originRegion,
        variety: coffee.variety,
        processingMethod: coffee.processingMethod,
        roastLevel: coffee.roastLevel,
      );

      if (!mounted) return;

      // Match brew method label to enum value.
      final matchedBrewMethod = BrewMethod.values.cast<BrewMethod?>().firstWhere(
        (e) => e!.label.toLowerCase() == suggestion.brewMethod.toLowerCase(),
        orElse: () => null,
      );

      // Match grind size label to enum value.
      final matchedGrindSize = GrindSize.values.cast<GrindSize?>().firstWhere(
        (e) => e!.label.toLowerCase() == suggestion.grindSize.toLowerCase(),
        orElse: () => null,
      );

      setState(() {
        if (matchedBrewMethod != null) _brewMethod = matchedBrewMethod;
        if (matchedGrindSize != null) _grindSize = matchedGrindSize;
        _doseController.text = suggestion.doseGrams.toString();
        _waterController.text = suggestion.waterMl.toString();
        _waterTempC = suggestion.waterTempC;
        _brewTimeMinutes = suggestion.brewTimeSec ~/ 60;
        _brewTimeSeconds = suggestion.brewTimeSec % 60;
        _suggestionTips = suggestion.tips;
      });

      _calculateRatio();
    } catch (_) {
      // Silently hide suggestion on failure.
    } finally {
      if (mounted) setState(() => _isSuggesting = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final isPremium = ref.read(isPremiumProvider);

    if (!isPremium) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final tastingCount =
          await ref.read(tastingRepositoryProvider).countForUserInMonth(uid);
      if (tastingCount >= AppConstants.freeTierMaxTastingsPerMonth && mounted) {
        final l10n = AppLocalizations.of(context);
        showUpgradePrompt(context,
            l10n.tastingLimitReached(AppConstants.freeTierMaxTastingsPerMonth));
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final coffee =
          await ref.read(coffeeDetailProvider(widget.coffeeId).future);
      final repository = ref.read(tastingRepositoryProvider);

      final dose = double.parse(_doseController.text);
      final water = double.parse(_waterController.text);
      final brewTimeSec = (_brewTimeMinutes * 60) + _brewTimeSeconds;

      final currentUser = FirebaseAuth.instance.currentUser;
      final tasting = Tasting(
        id: '',
        userId: userId,
        authorName: currentUser?.displayName ?? currentUser?.email?.split('@').first ?? '',
        authorAvatar: currentUser?.photoURL,
        coffeeId: widget.coffeeId,
        coffeeName: coffee?.name ?? '',
        coffeePhotoUrl: coffee?.photoUrl,
        roasterName: coffee?.roaster ?? '',
        brewMethod: _brewMethod!.label,
        grindSize: _grindSize!.label,
        doseGrams: dose,
        waterMl: water,
        ratio: _ratioDisplay,
        brewTimeSec: brewTimeSec,
        waterTempC: _waterTempC,
        aroma: _aroma,
        flavor: _flavor,
        acidity: _acidity,
        body: _body,
        sweetness: _sweetness,
        aftertaste: _aftertaste,
        overallRating: _overallRating,
        flavorNotes: _flavorNotes,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        tastingDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await repository.addTasting(tasting);

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).error)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final coffeeAsync = ref.watch(coffeeDetailProvider(widget.coffeeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addTasting),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Coffee info header
            coffeeAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
              data: (coffee) {
                if (coffee == null) return const SizedBox.shrink();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.secondaryContainer,
                          child: Icon(
                            Icons.coffee_rounded,
                            color:
                                theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coffee.name,
                                style: theme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                coffee.roaster,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // ── AI Brew Suggestion (premium only) ──
            if (ref.watch(isPremiumProvider))
              OutlinedButton.icon(
                onPressed: _isSuggesting ? null : _fetchSuggestion,
                icon: _isSuggesting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(l10n.getSuggestion),
              ),

            if (_suggestionTips != null) ...[
              const SizedBox(height: 12),
              Card(
                color: theme.colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.suggestedParams,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _suggestionTips!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── SECTION 1: Brew Parameters ──
            BrewParamsForm(
              selectedBrewMethod: _brewMethod,
              selectedGrindSize: _grindSize,
              doseController: _doseController,
              waterController: _waterController,
              ratioDisplay: _ratioDisplay,
              brewTimeMinutes: _brewTimeMinutes,
              brewTimeSeconds: _brewTimeSeconds,
              waterTempC: _waterTempC,
              onBrewMethodChanged: (v) => setState(() => _brewMethod = v),
              onGrindSizeChanged: (v) => setState(() => _grindSize = v),
              onDoseOrWaterChanged: _calculateRatio,
              onBrewTimeChanged: (min, sec) => setState(() {
                _brewTimeMinutes = min;
                _brewTimeSeconds = sec;
              }),
              onWaterTempChanged: (v) => setState(() => _waterTempC = v),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // ── SECTION 2: Tasting Scores ──
            TastingNotesInput(
              aroma: _aroma,
              flavor: _flavor,
              acidity: _acidity,
              body: _body,
              sweetness: _sweetness,
              aftertaste: _aftertaste,
              overallRating: _overallRating,
              onAromaChanged: (v) => setState(() => _aroma = v),
              onFlavorChanged: (v) => setState(() => _flavor = v),
              onAcidityChanged: (v) => setState(() => _acidity = v),
              onBodyChanged: (v) => setState(() => _body = v),
              onSweetnessChanged: (v) => setState(() => _sweetness = v),
              onAftertasteChanged: (v) => setState(() => _aftertaste = v),
              onOverallRatingChanged: (v) =>
                  setState(() => _overallRating = v),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // ── SECTION 3: Flavor Notes ──
            FlavorSelector(
              selectedFlavors: _flavorNotes,
              onChanged: (v) => setState(() => _flavorNotes = v),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // ── SECTION 4: Notes ──
            Text(l10n.notes, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            AppTextField(
              controller: _notesController,
              hint: 'How was it? Any special observations...',
              maxLines: 5,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ),

            const SizedBox(height: 32),

            // Save button
            AppButton(
              label: l10n.save,
              icon: Icons.check_rounded,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
