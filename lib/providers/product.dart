import 'package:flutter/Material.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
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