import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/dummy_data.dart';
import 'package:shop/models/product.dart';
import 'package:shop/errors/http_exception.dart';
import 'package:shop/utils/constants.dart';

class ProductList with ChangeNotifier {
  final String _token;
  final String _userId;
  List<Product> _items = [];

  ProductList([
    this._token = '',
    this._userId = '',
    this._items = const [],
  ]);

  List<Product> get items {
    return [..._items];
  }

  int get itemsCount {
    return items.length;
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite == true).toList();
  }
  
  List<Product> categoryItems(String categoryId) {
    return _items.where((element) => element.categoryId == categoryId).toList();
  }

  // bool _showFavoriteOnly = false;

  // List<Product> get items {
  //   if (_showFavoriteOnly) {
  //     return _items.where((element) => element.isFavorite == true).toList();
  //   } else {
  //     return [..._items];
  //   }
  // }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'].toString() : Random().nextDouble().toString(),
      name: data['name'].toString(),
      description: data['description'].toString(),
      price: data['price'] as double,
      categoryId: data['categoryId'].toString(),
      imageUrl: data['imageUrl'].toString(),
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> loadProducts() async {
        // print('${Contants.PRODUCT_BASE_URL}.json?auth=$_token');

    final response = await http
        .get(Uri.parse('${Contants.PRODUCT_BASE_URL}.json?auth=$_token'));

    if (response.body == 'null') {
      return;
    }

    final favResponse = await http.get(Uri.parse(
        '${Contants.USER_FAVORITES_URL}/${_userId}.json?auth=$_token'));

    Map<String, dynamic> favData =
        favResponse.body == 'null' ? {} : jsonDecode(favResponse.body);

    Map<String, dynamic> data = jsonDecode(response.body);

    _items.clear();
    
    data.forEach((productId, productData) {
      final isFavorite = favData[productId] ?? false;
      _items.add(
        Product(
          id: productId,
          name: (productData['name'] ?? '') as String,
          price: (productData['price'] ?? 0) as double,
          description: (productData['description'] ?? '') as String,
          imageUrl: (productData['imageUrl'] ?? '') as String,
          categoryId: (productData['categoryId'] ?? '') as String,
          isFavorite: isFavorite
        ),
      );
    });

    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('${Contants.PRODUCT_BASE_URL}.json?auth=$_token'),
      body: jsonEncode(
        {
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "categoryId": product.categoryId,
          "imageUrl": product.imageUrl,
        },
      ),
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(Product(
      id: id,
      name: product.name,
      description: product.description,
      price: product.price,
      categoryId: product.categoryId,
      imageUrl: product.imageUrl,
    ));

    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse(
            '${Contants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token'),
        body: jsonEncode(
          {
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "categoryId": product.categoryId,
            "imageUrl": product.imageUrl,
          },
        ),
      );

      _items[index] = product;
      notifyListeners();
    }

    return Future.delayed(Duration(seconds: 1));
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse(
            '${Contants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token'),
      );

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException(
          msg: 'Não foi possível excluir o produto.',
          statusCode: response.statusCode,
        );
      }
    }
  }

  // void showFavoriteOnly(){
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAllOnly(){
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }
}
