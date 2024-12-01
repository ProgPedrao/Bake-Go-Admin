import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bake_and_go_admin/models/cart.dart';
import 'package:bake_and_go_admin/models/cart_item.dart';
import 'package:bake_and_go_admin/models/checkout.dart';
import 'package:bake_and_go_admin/models/order.dart';
import 'package:bake_and_go_admin/utils/constants.dart';

class OrderList with ChangeNotifier {

  OrderList([this._token = '', this._userId = '', this._items = const []]);

  final String _token;
  final String _userId;
  List<Order> _items = [];

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadOrders() async {
    List<Order> items = [];

    final response =
        await http.get(Uri.parse('${Contants.ORDER_BASE_URL}/$_userId.json?auth=$_token'));

    if (response.body == 'null') return;

    Map<String, dynamic> data = jsonDecode(response.body);

    data.forEach(
      (orderId, orderData) {
        items.add(
          Order(
            id: orderId,
            total: orderData['total'],
            products: (orderData['products'] as List<dynamic>)
                .map((e) => CartItem(
                    id: e['id'],
                    productId: e['productId'],
                    name: e['name'],
                    quantity: e['quantity'],
                    price: e['price']))
                .toList(),
            date: DateTime.parse(orderData['date']),
          ),
        );
      },
    );

    _items = items.reversed.toList();

    notifyListeners();
  }

  Future<void> addOrder(Cart cart, CheckoutData checkoutData) async {
  final date = DateTime.now();
  final response = await http.post(
    Uri.parse('${Contants.ORDER_BASE_URL}/$_userId.json?auth=$_token'),
    body: jsonEncode({
      'total': cart.totalAmount,
      'date': date.toIso8601String(),
      'products': cart.items.values
          .map((cartItem) => {
                'id': cartItem.id,
                'productId': cartItem.productId,
                'name': cartItem.name,
                'quantity': cartItem.quantity,
                'price': cartItem.price,
              })
          .toList(),
      'checkout': checkoutData.toJson(),
    }),
  );

  final id = jsonDecode(response.body)['name'];
  _items.insert(
    0,
    Order(
      id: id,
      total: cart.totalAmount,
      products: cart.items.values.toList(),
      date: date,
    ),
  );

  notifyListeners();
}

}
