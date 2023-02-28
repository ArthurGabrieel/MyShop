import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/constants.dart';
import 'cart.dart';

import 'cart_item.dart';
import 'order.dart';

class OrderList with ChangeNotifier {
  OrderList([
    this._token = '',
    this._uid = '',
    this._items = const [],
  ]);

  String _token;
  String _uid;
  List<Order> _items = [];

  List<Order> get items => [..._items];

  int get itemsCount => _items.length;

  Future<void> loadOrders() async {
    List<Order> items = [];

    final response = await http.get(
      Uri.parse('${Constants.BASE_URL}/orders/$_uid.json?auth=$_token'),
    );
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);

    data.forEach((orderId, orderData) {
      items.add(
        Order(
          id: orderId,
          dateTime: DateTime.parse(orderData['dateTime']),
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>).map((item) {
            return CartItem(
              id: item['id'],
              productId: item['productId'],
              name: item['name'],
              quantity: item['quantity'],
              price: item['price'],
            );
          }).toList(),
        ),
      );
    });

    _items = items.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(
      Uri.parse('${Constants.BASE_URL}/orders/$_uid.json?auth=$_token'),
      body: jsonEncode({
        'amount': cart.totalAmount,
        'dateTime': date.toIso8601String(),
        'products': cart.items.values
            .map((cartItem) => {
                  'id': cartItem.id,
                  'productId': cartItem.productId,
                  'name': cartItem.name,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                })
            .toList(),
      }),
    );
    _items.add(
      Order(
        id: jsonDecode(response.body)['name'],
        amount: cart.totalAmount,
        products: cart.items.values.toList(),
        dateTime: date,
      ),
    );
    notifyListeners();

    _items.insert(
      0,
      Order(
        id: Random().nextDouble().toString(),
        amount: cart.totalAmount,
        products: cart.items.values.toList(),
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
