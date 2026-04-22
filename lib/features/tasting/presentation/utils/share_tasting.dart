import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, XFile;

import 'package:coffeeno/features/tasting/domain/tasting.dart';
import '../widgets/tasting_share_card.dart';

/// Captures the [TastingShareCard] as a PNG image and opens the system share
/// sheet so the user can send it to any app.
///
/// The card is rendered off-screen via an [OverlayEntry], captured with
/// [RenderRepaintBoundary.toImage], saved to the temp directory, and then
/// shared using [SharePlus].
Future<void> shareTasting(BuildContext context, Tasting tasting) async {
  final cardKey = GlobalKey();

  // Insert an off-screen overlay so the widget can be laid out and painted
  // without being visible to the user.
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -500,
      top: -700,
      child: RepaintBoundary(
        key: cardKey,
        child: TastingShareCard(tasting: tasting),
      ),
    ),
  );
  overlay.insert(entry);

  try {
    // Wait for the overlay entry to be laid out and painted.
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final boundary = cardKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;

    // Capture at 3x for a crisp share image.
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/coffeeno_tasting.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '${tasting.coffeeName} by ${tasting.roasterName}'
            ' - ${tasting.overallRating.toStringAsFixed(1)}/5',
      ),
    );

    await file.delete().catchError((_) => file);
  } finally {
    entry.remove();
  }
}
