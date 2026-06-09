import 'package:flutter/material.dart';

/// Rect seguro para el share sheet en iOS/iPadOS (requerido por share_plus).
Rect shareOriginForContext(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box != null && box.hasSize) {
    final origin = box.localToGlobal(Offset.zero) & box.size;
    final screen = MediaQuery.sizeOf(context);
    if (origin.width > 0 &&
        origin.height > 0 &&
        origin.left >= 0 &&
        origin.top >= 0 &&
        origin.right <= screen.width &&
        origin.bottom <= screen.height) {
      return origin;
    }
  }

  final size = MediaQuery.sizeOf(context);
  return Rect.fromCenter(
    center: Offset(size.width / 2, size.height / 2),
    width: 2,
    height: 2,
  );
}
