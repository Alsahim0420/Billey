import 'package:billey/services/category_suggestion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategorySuggestionService', () {
    test('sugiere banco para "Deudas"', () {
      final suggestion = CategorySuggestionService.suggest('Deudas');

      expect(suggestion, isNotNull);
      expect(suggestion!.icon, Icons.account_balance);
      expect(suggestion.icon, isNot(Icons.water_drop));
    });

    test('sugiere gotas solo para "Agua"', () {
      final suggestion = CategorySuggestionService.suggest('Agua');

      expect(suggestion, isNotNull);
      expect(suggestion!.icon, Icons.water_drop);
    });

    test('no confunde deudas con agua', () {
      final deudas = CategorySuggestionService.suggest('Deudas');
      final agua = CategorySuggestionService.suggest('Agua');

      expect(deudas!.icon, isNot(agua!.icon));
    });

    test('sugiere icono de donación para "Donación"', () {
      final suggestion = CategorySuggestionService.suggest('Donación');

      expect(suggestion, isNotNull);
      expect(suggestion!.icon, Icons.volunteer_activism);
    });

    test('sugiere icono de comida para "Restaurante"', () {
      final suggestion = CategorySuggestionService.suggest('Restaurante');

      expect(suggestion, isNotNull);
      expect(suggestion!.icon, Icons.restaurant);
    });

    test('devuelve fallback determinista para nombres sin regla', () {
      final first = CategorySuggestionService.suggest('Miscelanea X');
      final second = CategorySuggestionService.suggest('Miscelanea X');

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first!.icon, second!.icon);
      expect(first.color, second.color);
    });
  });
}
