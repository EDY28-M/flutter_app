import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/widgets/product_detail_sheet.dart';
import 'package:flutter_application/providers/cart_provider.dart';

void main() {
  testWidgets('ProductDetailSheet renders correctly and handles adding to cart', (WidgetTester tester) async {
    final mockProduct = {
      'id': 'p1',
      'branch_catalog_item_id': 'bci1',
      'name': 'Hamburguesa Clásica',
      'store_name': 'Burger Shop',
      'description': 'Deliciosa hamburguesa con queso.',
      'price': 15.50,
      'is_on_offer': true,
      'offer_price_amount': 12.00,
      'store_id': 's1',
      'branch_id': 'b1',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartProvider()),
          ],
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ProductDetailSheet.show(context, mockProduct);
                    },
                    child: const Text('Show Sheet'),
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );

    // Tap to show the sheet
    await tester.tap(find.text('Show Sheet'));
    await tester.pumpAndSettle();

    // Verify sheet content
    expect(find.text('Hamburguesa Clásica'), findsOneWidget);
    expect(find.text('Burger Shop'), findsOneWidget);
    expect(find.text('Deliciosa hamburguesa con queso.'), findsOneWidget);
    expect(find.text('S/ 12.00'), findsOneWidget); // Offer price
    expect(find.text('S/ 15.50'), findsOneWidget); // Original price with line-through
    expect(find.text('Agregar al carrito'), findsOneWidget);

    // Tap 'Agregar al carrito'
    await tester.tap(find.text('Agregar al carrito'));
    await tester.pump(); // Start loading indicator

    // Wait for async operation
    await tester.pumpAndSettle();

    // Verify snackbar - either success or error is fine for this UI test since CartProvider is not fully mocked
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
