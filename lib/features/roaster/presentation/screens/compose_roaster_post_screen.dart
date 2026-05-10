import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/core/utils/validators.dart';
import 'package:coffeeno/core/widgets/app_button.dart';
import 'package:coffeeno/core/widgets/app_text_field.dart';
import '../../../coffee/domain/coffee.dart';
import '../../../coffee/presentation/providers/coffee_provider.dart';
import '../../domain/roaster_post.dart';
import '../providers/roaster_post_provider.dart';
import '../providers/roaster_provider.dart';

final _roasterCoffeesProvider =
    FutureProvider.family<List<Coffee>, String>((ref, roasterId) {
  final repo = ref.watch(coffeeRepositoryProvider);
  return repo.getCoffeesForRoaster(roasterId).first;
});

class ComposeRoasterPostScreen extends ConsumerStatefulWidget {
  const ComposeRoasterPostScreen({super.key, required this.roasterId});

  final String roasterId;

  @override
  ConsumerState<ComposeRoasterPostScreen> createState() =>
      _ComposeRoasterPostScreenState();
}

class _ComposeRoasterPostScreenState
    extends ConsumerState<ComposeRoasterPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _ctaLabelCtrl = TextEditingController();
  final _ctaUrlCtrl = TextEditingController();
  String? _selectedCoffeeId;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _ctaLabelCtrl.dispose();
    _ctaUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(List<Coffee> coffees) async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final roaster = ref.read(roasterDetailProvider(widget.roasterId)).value;
    if (roaster == null) return;

    setState(() => _submitting = true);
    try {
      final linked = _selectedCoffeeId != null
          ? coffees.firstWhere((c) => c.id == _selectedCoffeeId,
              orElse: () => coffees.first)
          : null;

      final now = DateTime.now();
      final post = RoasterPost(
        id: '',
        roasterId: widget.roasterId,
        authorUid: uid,
        roasterName: roaster.name,
        roasterLogoUrl: roaster.photoUrl,
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        coffeeId: linked?.id,
        coffeeName: linked?.name,
        ctaLabel: _ctaLabelCtrl.text.trim().isEmpty
            ? null
            : _ctaLabelCtrl.text.trim(),
        ctaUrl:
            _ctaUrlCtrl.text.trim().isEmpty ? null : _ctaUrlCtrl.text.trim(),
        createdAt: now,
        expiresAt: now.add(RoasterPost.defaultLifetime),
      );

      await ref.read(roasterPostRepositoryProvider).createPost(post);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.postPublished)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final coffeesAsync = ref.watch(_roasterCoffeesProvider(widget.roasterId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.composePostTitle)),
      body: SafeArea(
        child: coffeesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${l10n.error}: $e')),
          data: (coffees) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _titleCtrl,
                    label: l10n.postTitleLabel,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.required(v, l10n.postTitleLabel),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _bodyCtrl,
                    label: l10n.postBodyLabel,
                    maxLines: 5,
                    validator: (v) =>
                        Validators.required(v, l10n.postBodyLabel),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedCoffeeId,
                    decoration: InputDecoration(
                      labelText: l10n.postLinkCoffeeLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.postNoLinkedCoffee),
                      ),
                      ...coffees.map((c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name),
                          )),
                    ],
                    onChanged: (v) => setState(() => _selectedCoffeeId = v),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _ctaLabelCtrl,
                    label: l10n.postCtaLabelField,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _ctaUrlCtrl,
                    label: l10n.postCtaUrlField,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: l10n.publishPost,
                    isLoading: _submitting,
                    onPressed: () => _submit(coffees),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
