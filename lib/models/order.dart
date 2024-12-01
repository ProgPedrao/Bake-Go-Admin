import 'package:bake_and_go_admin/models/cart_item.dart';
import 'package:bake_and_go_admin/models/checkout.dart';

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;
  final CheckoutData? checkout;

  Order({
    required this.id,
    required this.total,
    required this.products,
    required this.date,
    this.checkout
  });
}
