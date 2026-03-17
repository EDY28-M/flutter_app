import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/screens/home_screen.dart';

void main() {
  test('themeForCategory returns green theme for Tienda/store', () {
    final themeTienda = HomeScreen.themeForCategory('Tienda');
    expect(themeTienda['icon'], Icons.shopping_basket_rounded);
    expect(themeTienda['iconColor'], Colors.green.shade600);

    final themeStore = HomeScreen.themeForCategory('store');
    expect(themeStore['icon'], Icons.shopping_basket_rounded);
    expect(themeStore['iconColor'], Colors.green.shade600);
  });

  test('themeForCategory returns orange theme for Comida', () {
    final theme = HomeScreen.themeForCategory('Comida');
    expect(theme['iconColor'], Colors.orange.shade800);
  });
}
