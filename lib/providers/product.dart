import 'dart:convert';

import 'package:flutter/Material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../config/constants.dart';

class Product with ChangeNotifier {
  String id;
  String title;
  String description;
  double price;
  String imageUrl;
  bool isfavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isfavorite = false,
  });

  void toggleFavoriteStatus() async {
    var box = Hive.box(Constants.strorageBox);
    String authToken = box.get(Constants.token);

    final oldStatus = isfavorite;
    isfavorite = !isfavorite;
    notifyListeners();
    final url =
        'https://shopapp-77183-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    try {
      final response = await http.patch(
        Uri.parse(url),
        body: json.encode({
          'isFavorite': isfavorite,
        }),
      );

      if (response.statusCode >= 400) {
        isfavorite = oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isfavorite = oldStatus;
      notifyListeners();
    }
  }
}
