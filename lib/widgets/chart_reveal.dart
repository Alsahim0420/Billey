import 'route_entrance_mixin.dart';
import 'package:flutter/material.dart';

/// Plays [builder] through a 0→1 progress once, on mount — used to make a
/// chart "fill in" the first time it's shown instead of appearing at full
/// height/size immediately. Give it a key that changes with the underlying
/// dataset so switching filters replays the reveal.
class ChartReveal extends StatefulWidget {
  const ChartReveal({super.key, this.builder, this.animationBuilder})
      : assert((builder == null) != (animationBuilder == null));

  final Widget Function(BuildContext context, double progress)? builder;
  final Widget Function(BuildContext context, Animation<double> progress)?
      animationBuilder;

  @override
  State<ChartReveal> createState() => ChartRevealState();
}

class ChartRevealState extends State<ChartReveal>
    with SingleTickerProviderStateMixin, RouteEntranceMixin<ChartReveal> {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progress =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void startEntranceAnimation() => _controller.forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animationBuilder != null) {
      return widget.animationBuilder!(context, _progress);
    }
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => widget.builder!(context, _progress.value),
    );
  }
}
