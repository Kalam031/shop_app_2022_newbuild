import 'package:flutter/Material.dart';

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

  void toggleFavoriteStatus() {
    isfavorite = !isfavorite;
    notifyListeners();
  }
}
