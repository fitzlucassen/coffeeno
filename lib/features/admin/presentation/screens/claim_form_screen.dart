import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../domain/claim.dart';
import '../providers/admin_provider.dart';

class ClaimFormScreen extends ConsumerStatefulWidget {
  const ClaimFormScreen({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.entityName,
  });

  final String entityType;
  final String entityId;
  final String entityName;

  @override
  ConsumerState<ClaimFormScreen> createState() => _ClaimFormScreenState();
}

class _ClaimFormScreenState extends ConsumerState<ClaimFormScreen> {
  final _messageController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _submitting = true);

    try {
      final repo = ref.read(claimRepositoryProvider);
      final claim = Claim(
        id: '',
        userId: uid,
        entityType: widget.entityType,
        entityId: widget.entityId,
        entityName: widget.entityName,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
        createdAt: DateTime.now(),
      );
      await repo.submitClaim(claim);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.claimSubmitted)),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.claimProfile)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.entityName, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: l10n.claimMessage,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.submitClaim),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
