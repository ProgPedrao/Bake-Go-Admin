import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bake_and_go_admin/errors/http_exception.dart';
import 'package:bake_and_go_admin/models/category.dart';
import 'package:bake_and_go_admin/utils/constants.dart';

class CategoryList with ChangeNotifier {
  final String _token;
  List<ProductCategory> _items = [];

  CategoryList([
    this._token = '',
    this._items = const [],
  ]);

  List<ProductCategory> get items {
    return [..._items];
  }

  int get itemsCount {
    return items.length;
  }

  Future<void> saveCategory(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final category = ProductCategory(
      id: hasId ? data['id'].toString() : Random().nextDouble().toString(),
      name: data['name'].toString(),
    );

    if (hasId) {
      return updateCategory(category);
    } else {
      return addCategory(category);
    }
  }

  Future<void> loadCategories() async {
    final response = await http
        .get(Uri.parse('${Contants.CATEGORY_BASE_URL}.json?auth=$_token'));

    if (response.body == 'null') {
      return;
    }

    Map<String, dynamic> data = jsonDecode(response.body);

    _items.clear();
    
    data.forEach((categoryId, categoryData) {
      _items.add(
        ProductCategory(
          id: categoryId,
          name: (categoryData['name'] ?? '') as String
        ),
      );
    });

    notifyListeners();
  }

  Future<void> addCategory(ProductCategory category) async {
    final response = await http.post(
      Uri.parse('${Contants.CATEGORY_BASE_URL}.json?auth=$_token'),
      body: jsonEncode(
        {
          "name": category.name,
        },
      ),
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(ProductCategory(
      id: id,
      name: category.name,
    ));

    notifyListeners();
  }

  Future<void> updateCategory(ProductCategory category) async {
    int index = _items.indexWhere((element) => element.id == category.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse(
            '${Contants.CATEGORY_BASE_URL}/${category.id}.json?auth=$_token'),
        body: jsonEncode(
          {
            "name": category.name,
          },
        ),
      );

      _items[index] = category;
      notifyListeners();
    }

    return Future.delayed(Duration(seconds: 1));
  }

  Future<void> removeCategory(ProductCategory category) async {
    int index = _items.indexWhere((element) => element.id == category.id);

    if (index >= 0) {
      final selectedCategory = _items[index];
      _items.remove(selectedCategory);
      notifyListeners();

      final response = await http.delete(
        Uri.parse(
            '${Contants.CATEGORY_BASE_URL}/${selectedCategory.id}.json?auth=$_token'),
      );

      if (response.statusCode >= 400) {
        _items.insert(index, selectedCategory);
        notifyListeners();
        throw HttpException(
          msg: 'Não foi possível excluir o produto.',
          statusCode: response.statusCode,
        );
      }
    }
  }

}
