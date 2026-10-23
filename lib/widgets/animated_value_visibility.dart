import 'package:flutter/material.dart';

/// Crossfades display-only financial values, without exposing outgoing semantics.
class AnimatedValueVisibility extends StatelessWidget {
  const AnimatedValueVisibility(
      {super.key,
      required this.hidden,
      required this.child,
      required this.replacement,
      this.alignment = Alignment.centerLeft});
  final bool hidden;
  final Widget child, replacement;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 280);
    return AnimatedSize(
      duration: duration,
      curve: Curves.easeInOutCubic,
      alignment: alignment,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        layoutBuilder: (current, previous) => Stack(
          alignment: alignment,
          children: [
            for (final old in previous)
              ExcludeSemantics(child: IgnorePointer(child: old)),
            if (current != null) current
          ],
        ),
        child: KeyedSubtree(
            key: ValueKey(hidden), child: hidden ? replacement : child),
      ),
    );
  }
}
