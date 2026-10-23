import 'package:billey/theme/billey_palette.dart';
import 'package:billey/theme/billey_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'theme extension interpolates every semantic color instead of switching palettes',
      () {
    final dark = BilleyTheme(BilleyPalette.dark());
    final light = BilleyTheme(BilleyPalette.light());
    final half = dark.lerp(light, 0.5);
    expect(half.backgroundColor,
        Color.lerp(dark.backgroundColor, light.backgroundColor, 0.5));
    expect(half.surfaceInput,
        Color.lerp(dark.surfaceInput, light.surfaceInput, 0.5));
    expect(
        half.textPrimary, Color.lerp(dark.textPrimary, light.textPrimary, 0.5));
    expect(half.borderSubtle,
        Color.lerp(dark.borderSubtle, light.borderSubtle, 0.5));
    expect(dark.lerp(light, 0).palette, dark.palette);
    expect(dark.lerp(light, 1).palette, light.palette);
  });
}
