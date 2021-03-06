import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_app/models/http_exception.dart';
import '../config/constants.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
/*     Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ), */
  ];

  // ignore: prefer_final_fields
  var _showFavoritesOnly = false;

  List<Product>? get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isfavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isfavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var box = Hive.box(Constants.strorageBox);
    String authToken = box.get(Constants.token);
    String userId = box.get(Constants.userId);

    final String filterProducts =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : "";

    var url =
        'https://shopapp-77183-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterProducts';

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) != null
          ? json.decode(response.body) as Map<String, dynamic>
          : null;

      url =
          'https://shopapp-77183-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favoriteResponse = await http.get(Uri.parse(url));

      final favoriteStatus = json.decode(favoriteResponse.body);

      final List<Product> loadedProduct = [];
      extractedData?.forEach((prodId, prodData) {
        loadedProduct.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isfavorite:
              favoriteStatus == null ? false : favoriteStatus[prodId] ?? false,
        ));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    var box = Hive.box(Constants.strorageBox);
    String authToken = box.get(Constants.token);
    String userId = box.get(Constants.userId);

    final url =
        'https://shopapp-77183-default-rtdb.firebaseio.com/products.json?auth=$authToken';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
          },
        ),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    var box = Hive.box(Constants.strorageBox);
    String authToken = box.get(Constants.token);

    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://shopapp-77183-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    var box = Hive.box(Constants.strorageBox);
    String authToken = box.get(Constants.token);

    final url =
        'https://shopapp-77183-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProdIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProdIndex];
    _items.removeAt(existingProdIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode >= 400) {
      _items.insert(existingProdIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
  }
}
