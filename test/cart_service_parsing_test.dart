import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/services/cart_service.dart';

void main() {
  test('parseCartResponseBody extrae data cuando viene envuelto', () {
    const body = '''
{
  "success": true,
  "data": {
    "id": "cart-1",
    "store_id": "store-1",
    "branch_id": "branch-1",
    "items": [
      {"id": "item-1", "qty": 2}
    ],
    "item_count": 2,
    "subtotal": 20,
    "total": 20
  }
}
''';

    final cart = CartService.parseCartResponseBody(body);

    expect(cart['id'], 'cart-1');
    expect((cart['items'] as List).length, 1);
    expect(cart['item_count'], 2);
  });

  test('parseCartResponseBody soporta respuesta plana', () {
    const body = '''
{
  "id": "cart-2",
  "store_id": "store-2",
  "branch_id": "branch-2",
  "items": [],
  "item_count": 0,
  "subtotal": 0,
  "total": 0
}
''';

    final cart = CartService.parseCartResponseBody(body);

    expect(cart['id'], 'cart-2');
    expect((cart['items'] as List).isEmpty, true);
  });

  test('parseCartsResponseBody extrae lista envuelta en data', () {
    const body = '''
{
  "success": true,
  "data": [
    {"id": "cart-a", "item_count": 1},
    {"id": "cart-b", "item_count": 3}
  ]
}
''';

    final carts = CartService.parseCartsResponseBody(body);

    expect(carts.length, 2);
    expect(carts.first['id'], 'cart-a');
    expect(carts.last['item_count'], 3);
  });
}
