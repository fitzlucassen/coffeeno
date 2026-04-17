import 'package:flutter/material.dart';

/// A semi-transparent overlay with a rounded-rectangle cutout for framing
/// the coffee bag label during scanning.
class CameraOverlay extends StatelessWidget {
  const CameraOverlay({
    super.key,
    this.instructionText = 'Position the coffee bag label in the frame',
  });

  final String instructionText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cutoutWidth = constraints.maxWidth * 0.82;
        final cutoutHeight = cutoutWidth * 0.65; // landscape card ratio
        final cutoutRect = Rect.fromCenter(
          center: Offset(
            constraints.maxWidth / 2,
            constraints.maxHeight * 0.42,
          ),
          width: cutoutWidth,
          height: cutoutHeight,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            // Semi-transparent scrim with cutout.
            CustomPaint(
              painter: _OverlayPainter(
                cutoutRect: cutoutRect,
                borderRadius: 20,
                scrimColor: Colors.black.withValues(alpha: 0.55),
                borderColor: colors.primary,
              ),
            ),

            // Corner decorations.
            Positioned.fromRect(
              rect: cutoutRect,
              child: _CornerDecorations(
                color: colors.primary,
                borderRadius: 20,
              ),
            ),

            // Instruction text below cutout.
            Positioned(
              left: 24,
              right: 24,
              top: cutoutRect.bottom + 32,
              child: Text(
                instructionText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Paints a darkened overlay with a rounded-rectangle cutout.
class _OverlayPainter extends CustomPainter {
  _OverlayPainter({
    required this.cutoutRect,
    required this.borderRadius,
    required this.scrimColor,
    required this.borderColor,
  });

  final Rect cutoutRect;
  final double borderRadius;
  final Color scrimColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      cutoutRect,
      Radius.circular(borderRadius),
    );

    // Draw the semi-transparent overlay with a hole.
    final scrimPath = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(scrimPath, Paint()..color = scrimColor);

    // Draw a subtle border around the cutout.
    final borderPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) =>
      cutoutRect != oldDelegate.cutoutRect ||
      borderRadius != oldDelegate.borderRadius ||
      scrimColor != oldDelegate.scrimColor ||
      borderColor != oldDelegate.borderColor;
}

/// Draws decorative corner brackets inside the cutout area.
class _CornerDecorations extends StatelessWidget {
  const _CornerDecorations({
    required this.color,
    required this.borderRadius,
  });

  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    const length = 28.0;
    const thickness = 3.0;

    Widget corner({
      required Alignment alignment,
      required BorderRadius radius,
    }) {
      return Align(
        alignment: alignment,
        child: Container(
          width: length,
          height: length,
          decoration: BoxDecoration(
            border: Border(
              top: alignment.y < 0
                  ? BorderSide(color: color, width: thickness)
                  : BorderSide.none,
              bottom: alignment.y > 0
                  ? BorderSide(color: color, width: thickness)
                  : BorderSide.none,
              left: alignment.x < 0
                  ? BorderSide(color: color, width: thickness)
                  : BorderSide.none,
              right: alignment.x > 0
                  ? BorderSide(color: color, width: thickness)
                  : BorderSide.none,
            ),
            borderRadius: radius,
          ),
        ),
      );
    }

    return Stack(
      children: [
        corner(
          alignment: Alignment.topLeft,
          radius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
          ),
        ),
        corner(
          alignment: Alignment.topRight,
          radius: BorderRadius.only(
            topRight: Radius.circular(borderRadius),
          ),
        ),
        corner(
          alignment: Alignment.bottomLeft,
          radius: BorderRadius.only(
            bottomLeft: Radius.circular(borderRadius),
          ),
        ),
        corner(
          alignment: Alignment.bottomRight,
          radius: BorderRadius.only(
            bottomRight: Radius.circular(borderRadius),
          ),
        ),
      ],
    );
  }
}
