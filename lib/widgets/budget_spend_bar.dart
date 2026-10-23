import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Gives labels their measured height and the plot the remaining space.
class BudgetBarLayout extends StatelessWidget {
  const BudgetBarLayout(
      {super.key,
      required this.header,
      required this.bar,
      required this.footer,
      this.width = 64});
  final Widget header, bar, footer;
  final double width;
  @override
  Widget build(BuildContext context) => Column(children: [
        header,
        const SizedBox(height: 8),
        Expanded(child: SizedBox(width: width, child: bar)),
        const SizedBox(height: 8),
        footer,
      ]);
}

/// Places readable details inside the plot, even when the actual bar is short.
class BudgetBarDetails extends StatelessWidget {
  const BudgetBarDetails(
      {super.key,
      required this.bar,
      required this.amount,
      required this.maximum,
      required this.progress,
      required this.color,
      required this.icon,
      required this.amountLabel,
      this.budget,
      this.animation,
      this.amountFormatter});
  final Widget bar;
  final double amount, maximum, progress;
  final double? budget;
  final Color color;
  final IconData icon;
  final String amountLabel;
  final Animation<double>? animation;
  final String Function(double)? amountFormatter;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation ?? const AlwaysStoppedAnimation(1.0),
        child: bar,
        builder: (context, plot) =>
            LayoutBuilder(builder: (context, constraints) {
          final value = animation?.value ?? progress;
          final scale = MediaQuery.textScalerOf(context);
          final textHeight = scale.scale(13) * 1.4;
          final needed = textHeight + 24 + 12 + 20;
          final filled = maximum > 0
              ? (constraints.maxHeight - 5) *
                  (amount / maximum).clamp(0.0, 1.0) *
                  value.clamp(0.0, 1.0)
              : 0.0;
          final baseHeight = maximum > 0 && budget != null
              ? (constraints.maxHeight - 5) *
                  (budget! / maximum).clamp(0.0, 1.0)
              : filled;
          final insideFill = filled >= needed;
          final labelColor = baseHeight >= needed
              ? color
              : Color.lerp(color, Colors.black, 0.32)!;
          final foreground = insideFill
              ? (ThemeData.estimateBrightnessForColor(labelColor) ==
                      Brightness.dark
                  ? Colors.white
                  : const Color(0xff182326))
              : Theme.of(context).colorScheme.onSurface;
          return Stack(fit: StackFit.expand, children: [
            plot!,
            Positioned(
              bottom: insideFill
                  ? 10
                  : math.min(
                      filled + 8, math.max(0, constraints.maxHeight - needed)),
              left: 8,
              right: 8,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon,
                        color: insideFill ? foreground : color, size: 24),
                    const SizedBox(height: 6),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                            amountFormatter?.call(amount * value) ??
                                amountLabel,
                            maxLines: 1,
                            style: TextStyle(
                                color: foreground,
                                fontSize: 13,
                                fontWeight: FontWeight.w900))),
                  ])),
            ),
          ]);
        }),
      );
}

/// Category-colored spending with a target rail and a darker, textured excess.
class BudgetSpendBar extends StatelessWidget {
  const BudgetSpendBar(
      {super.key,
      required this.amount,
      required this.budget,
      required this.maximum,
      required this.color,
      required this.progress,
      required this.semanticLabel,
      this.animation});
  final double amount, maximum, progress;
  final double? budget;
  final Color color;
  final String semanticLabel;
  final Animation<double>? animation;
  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticLabel,
        image: true,
        child: CustomPaint(
            painter: _BudgetPainter(
                amount: amount,
                budget: budget,
                maximum: maximum,
                color: color,
                progress: progress,
                animation: animation),
            size: Size.infinite),
      );
}

class _BudgetPainter extends CustomPainter {
  _BudgetPainter(
      {required this.amount,
      required this.budget,
      required this.maximum,
      required this.color,
      required this.progress,
      this.animation})
      : super(repaint: animation);
  final double amount, maximum, progress;
  final double? budget;
  final Color color;
  final Animation<double>? animation;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !maximum.isFinite || maximum <= 0) return;
    final height = math.max(0.0, size.height - 5);
    final baseline = size.height;
    const left = 5.0;
    final right = size.width - 5;
    double y(double value) =>
        baseline - height * (value / maximum).clamp(0.0, 1.0);
    final target = budget;
    final spent =
        math.max(0.0, amount) * (animation?.value ?? progress).clamp(0.0, 1.0);
    final dark = Color.lerp(color, Colors.black, 0.32)!;
    if (target != null && target > 0) {
      final track = RRect.fromRectAndRadius(
          Rect.fromLTRB(left, y(target), right, baseline),
          const Radius.circular(3));
      canvas.drawRRect(track, Paint()..color = color.withValues(alpha: 0.10));
      canvas.drawRRect(
          track,
          Paint()
            ..color = color.withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
    }
    if (spent > 0) {
      final fill = RRect.fromRectAndRadius(
          Rect.fromLTRB(left, y(spent), right, baseline),
          const Radius.circular(3));
      canvas.save();
      canvas.clipRRect(fill);
      canvas.drawRRect(fill, Paint()..color = color);
      if (target != null && target > 0 && spent > target) {
        final excess = Rect.fromLTRB(left, y(spent), right, y(target));
        canvas.drawRect(excess, Paint()..color = dark);
        canvas.save();
        canvas.clipRect(excess);
        final stripe = Paint()
          ..color = color.withValues(alpha: 0.5)
          ..strokeWidth = 1.5;
        for (double offset = -excess.height; offset < size.width; offset += 9) {
          canvas.drawLine(Offset(offset, excess.bottom),
              Offset(offset + excess.height, excess.top), stripe);
        }
        canvas.restore();
      }
      canvas.restore();
    }
    if (target != null && target > 0) {
      final top = y(target);
      // Short wings and a center notch mark the target without a dotted outline.
      final rail = Paint()
        ..color = dark
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(0, top), Offset(size.width, top), rail);
      canvas.drawLine(Offset(size.width / 2, top - 3),
          Offset(size.width / 2, top + 3), rail);
    }
  }

  @override
  bool shouldRepaint(covariant _BudgetPainter old) =>
      old.amount != amount ||
      old.budget != budget ||
      old.maximum != maximum ||
      old.color != color ||
      old.progress != progress ||
      old.animation != animation;
}
