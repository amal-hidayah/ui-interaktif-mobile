import 'package:flutter/material.dart';

/// Denah venue yang bisa digeser dan diperbesar dengan [InteractiveViewer].
class VenueMapViewer extends StatefulWidget {
  const VenueMapViewer({super.key});

  @override
  State<VenueMapViewer> createState() => _VenueMapViewerState();
}

class _VenueMapViewerState extends State<VenueMapViewer> {
  static const double _minScale = 0.8;
  static const double _maxScale = 4;

  final TransformationController _controller = TransformationController();
  double _scale = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomTo(double target) {
    final clamped = target.clamp(_minScale, _maxScale).toDouble();
    final box = context.findRenderObject() as RenderBox?;
    final size = box?.size ?? Size.zero;
    final focal = Offset(size.width / 2, size.height / 2);

    _controller.value = Matrix4.identity()
      ..setEntry(0, 0, clamped)
      ..setEntry(1, 1, clamped)
      ..setEntry(0, 3, focal.dx * (1 - clamped))
      ..setEntry(1, 3, focal.dy * (1 - clamped));
    setState(() => _scale = clamped);
  }

  void _reset() {
    _controller.value = Matrix4.identity();
    setState(() => _scale = 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
        color: scheme.surfaceContainerLow,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: _minScale,
              maxScale: _maxScale,
              boundaryMargin: const EdgeInsets.all(80),
              onInteractionEnd: (_) {
                setState(() => _scale = _controller.value.getMaxScaleOnAxis());
              },
              child: SizedBox.expand(
                child: CustomPaint(painter: _VenueMapPainter(scheme: scheme)),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _OverlayChip(
              icon: Icons.apartment_rounded,
              label: 'Denah Venue · Lt. 3',
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Perbesar',
                  onPressed: () => _zoomTo(_scale * 1.35),
                ),
                const SizedBox(height: 6),
                _MapButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Perkecil',
                  onPressed: () => _zoomTo(_scale / 1.35),
                ),
                const SizedBox(height: 6),
                _MapButton(
                  icon: Icons.center_focus_strong_rounded,
                  tooltip: 'Reset tampilan',
                  onPressed: _reset,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Flexible(
                  child: _OverlayChip(
                    icon: Icons.pinch_rounded,
                    label: 'Geser & cubit untuk menjelajah',
                  ),
                ),
                const SizedBox(width: 8),
                _OverlayChip(
                  icon: Icons.zoom_in_map_rounded,
                  label: '${(_scale * 100).round()}%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayChip extends StatelessWidget {
  const _OverlayChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 38, height: 38),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _VenueMapPainter extends CustomPainter {
  _VenueMapPainter({required this.scheme});

  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          colors: [scheme.surfaceContainerHigh, scheme.surfaceContainerLowest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
    );

    _drawGrid(canvas, size);

    final width = size.width;
    final height = size.height;

    void block({
      required double left,
      required double top,
      required double w,
      required double h,
      required Color fill,
      required Color labelColor,
      required String label,
      double radius = 14,
    }) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left * width, top * height, w * width, h * height),
        Radius.circular(radius),
      );
      canvas.drawRRect(rect, Paint()..color = fill);
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = labelColor.withValues(alpha: 0.22),
      );
      _drawLabel(
        canvas,
        label,
        rect.outerRect.center,
        labelColor,
        maxWidth: rect.width - 12,
        canvasSize: size,
      );
    }

    block(
      left: 0.30,
      top: 0.055,
      w: 0.40,
      h: 0.105,
      fill: scheme.primary,
      labelColor: scheme.onPrimary,
      label: 'STAGE',
      radius: 10,
    );

    block(
      left: 0.07,
      top: 0.215,
      w: 0.40,
      h: 0.33,
      fill: scheme.secondaryContainer,
      labelColor: scheme.onSecondaryContainer,
      label: 'HALL A\n120 kursi',
    );

    block(
      left: 0.53,
      top: 0.215,
      w: 0.40,
      h: 0.33,
      fill: scheme.tertiaryContainer,
      labelColor: scheme.onTertiaryContainer,
      label: 'HALL B\n80 kursi',
    );

    block(
      left: 0.07,
      top: 0.60,
      w: 0.27,
      h: 0.155,
      fill: scheme.surfaceContainerHighest,
      labelColor: scheme.onSurfaceVariant,
      label: 'WORKSHOP',
    );

    block(
      left: 0.37,
      top: 0.60,
      w: 0.21,
      h: 0.155,
      fill: scheme.surfaceContainerHighest,
      labelColor: scheme.onSurfaceVariant,
      label: 'MEETUP',
    );

    block(
      left: 0.61,
      top: 0.60,
      w: 0.32,
      h: 0.155,
      fill: scheme.primaryContainer,
      labelColor: scheme.onPrimaryContainer,
      label: 'EXPO BOOTH',
    );

    block(
      left: 0.07,
      top: 0.795,
      w: 0.22,
      h: 0.105,
      fill: scheme.secondary,
      labelColor: scheme.onSecondary,
      label: 'REGISTRASI',
      radius: 10,
    );

    block(
      left: 0.40,
      top: 0.795,
      w: 0.20,
      h: 0.105,
      fill: scheme.surfaceContainerHighest,
      labelColor: scheme.onSurfaceVariant,
      label: 'ENTRANCE',
      radius: 10,
    );

    block(
      left: 0.72,
      top: 0.795,
      w: 0.09,
      h: 0.105,
      fill: scheme.surfaceContainerHighest,
      labelColor: scheme.onSurfaceVariant,
      label: 'WC',
      radius: 10,
    );

    block(
      left: 0.83,
      top: 0.795,
      w: 0.10,
      h: 0.105,
      fill: scheme.surfaceContainerHighest,
      labelColor: scheme.onSurfaceVariant,
      label: 'PANTRY',
      radius: 10,
    );

    _drawEntranceArrow(canvas, size);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          width * 0.035,
          height * 0.03,
          width * 0.93,
          height * 0.91,
        ),
        const Radius.circular(22),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = scheme.outline.withValues(alpha: 0.35),
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = scheme.outlineVariant.withValues(alpha: 0.6);
    for (double y = 12; y < size.height; y += 26) {
      for (double x = 12; x < size.width; x += 26) {
        canvas.drawCircle(Offset(x, y), 0.9, dotPaint);
      }
    }
  }

  void _drawEntranceArrow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.955);
    final paint = Paint()
      ..color = scheme.primary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(center.translate(0, 10), center.translate(0, -6), paint);
    canvas.drawLine(center.translate(-5, 0), center.translate(0, -6), paint);
    canvas.drawLine(center.translate(5, 0), center.translate(0, -6), paint);
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset center,
    Color color, {
    required double maxWidth,
    required Size canvasSize,
  }) {
    final fontSize = (canvasSize.shortestSide * 0.032).clamp(8.0, 13.0);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          height: 1.25,
          letterSpacing: 0.3,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth > 0 ? maxWidth : 10);

    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _VenueMapPainter oldDelegate) =>
      oldDelegate.scheme.brightness != scheme.brightness ||
      oldDelegate.scheme.primary != scheme.primary ||
      oldDelegate.scheme.surface != scheme.surface;
}
