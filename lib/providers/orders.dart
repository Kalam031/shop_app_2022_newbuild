import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetProducts() async {
    var box = Hive.box(Constants.strorageBox);
    String authToken = box.get(Constants.token);

    final url =
        'https://shopapp-77183-default-rtdb.firebaseio.com/orders.json?auth=$authToken';

    final response = await http.get(Uri.parse(url));
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) != null
        ? json.decode(response.body) as Map<String, dynamic>
        : null;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((orderid, orderData) {
      loadedOrders.add(OrderItem(
        id: orderid,
        amount: orderData['amount'],
        products: (orderData['products'] as List<dynamic>)
            .map((item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                ))
            .toList(),
        dateTime: DateTime.parse(orderData['dateTime']),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    var box = Hive.box(Constants.strorageBox);
    String authToken = box.get(Constants.token);
    final url =
        'https://shopapp-77183-default-rtdb.firebaseio.com/orders.json?auth=$authToken';

    final timeStamp = DateTime.now();

    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'amount': total,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      }),
    );

    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp,
        ));
    notifyListeners();
  }
}
