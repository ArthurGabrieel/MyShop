import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/product.dart';
import 'package:shop/utils/constants.dart';

class ProductList with ChangeNotifier {
  ProductList([
    this._token = '',
    this._uid = '',
    this._items = const [],
  ]);

  String _token;
  String _uid;
  List<Product> _items = [];
  final _baseUrl = Constants.BASE_URL;

  List<Product> get items => [..._items];

  List<Product> get favoriteItems =>
      _items.where((product) => product.isFavorite).toList();

  int get itemsCount => _items.length;

  Future<void> loadProducts() async {
    _items.clear();
    final response =
        await http.get(Uri.parse('$_baseUrl/products.json?auth=$_token'));
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);

    final favResponse = await http.get(
      Uri.parse(
        '${Constants.BASE_URL}/userFavorites/$_uid.json?auth=$_token',
      ),
    );

    Map<String, dynamic> favData =
        favResponse.body == 'null' ? {} : jsonDecode(favResponse.body);

    data.forEach((productId, productData) {
      final isFavorite = favData[productId] ?? false;
      _items.add(
        Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: isFavorite,
        ),
      );
    });
    notifyListeners();
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId
          ? data['id'] as String
          : Random.secure().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/products.json?auth=$_token'),
      body: jsonEncode(
        {
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
        },
      ),
    );
    _items.add(Product(
      id: jsonDecode(response.body)['name'],
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      await http.patch(
        Uri.parse('$_baseUrl/products/${product.id}.json?auth=$_token'),
        body: jsonEncode(
          {
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
          },
        ),
      );
      _items[index] = product;
      notifyListeners();
    }
    return Future.value();
  }

  Future<void> removeProduct(Product product) async {
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse('$_baseUrl/products/${product.id}.json?auth=$_token'),
      );

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw const HttpException('Could not delete product.');
      }
    }
  }
}
