import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data_models.dart';

class ShoppingListProvider extends ChangeNotifier {
  final String categoriesUrl;
  final String productsUrl;
  final String loginUrl;
  final String registerUrl;
  http.Client? client;
  static const String ipAddress = '10.0.2.2';
  ShoppingListProvider({
    this.categoriesUrl = 'http://$ipAddress:3000/categories',
    this.productsUrl = 'http://$ipAddress:3000/products',
    this.loginUrl = 'http://$ipAddress:3000/login',
    this.registerUrl = 'http://$ipAddress:3000/register',
    this.client,
  }) {
    client ??= http.Client();
  }
  List<Category> _categories = [];
  List<Product> _products = [];
  List<Category> get categories => _categories;
  List<Product> get products => _products;

  Future<void> getCategories() async {
    final response = await client!.get(Uri.parse(categoriesUrl));
    if (response.statusCode == 200) {
      final categoriesJson = (json.decode(response.body) as List);
      _categories = categoriesJson.map((e) => Category.fromJson(e)).toList();
      return notifyListeners();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  bool _isBusy = false;
  bool get isBusy => _isBusy;
  String? _error;
  String? get error => _error;
  Future<void> getProducts() async {
    _isBusy = true;
    _error = null;
    notifyListeners();
    _getToken();
    final response = await http.get(
      Uri.parse('$productsUrl?userId=$_userId'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      final productsJson = (json.decode(response.body) as List);
      _products = productsJson.map((e) => Product.fromJson(e)).toList();
    } else {
      _error = 'Failed to load products';
    }
    _isBusy = false;
    notifyListeners();
  }

  bool groupByCategory = false;
  bool moveBoughtDown = false;

  void addItem(Product item) async {
    _error = null;
    _isBusy = true;
    notifyListeners();
    try {
      await _getToken();
      final response = await client!.post(Uri.parse(productsUrl),
          body: jsonEncode({'userId': _userId, ...item.toJson()}),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          });
      if (response.statusCode == 201) {
        _products.add(item);
      } else {
        _error = 'Failed to add item! Error: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void itemBoughtChanged(Product item) async {
    _error = null;
    _isBusy = true;
    notifyListeners();
    _getToken();
    try {
      item.isBought = !item.isBought;
      final response = await client!.patch(Uri.parse('$productsUrl/${item.id}'),
          body: jsonEncode({'userId': _userId, ...item.toJson()}),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          });
      if (response.statusCode == 200) {
        _doSorting();
      } else {
        _error = 'Failed to update item! Error: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }
    _isBusy = false;
    notifyListeners();
  }

  String? _token;
  int? _userId;
  Future<void> _getToken() async {
    if (_token != null) {
      return;
    } else {
      _error = null;
      try {
        final response = await client!.post(Uri.parse(loginUrl),
            body: json.encode({'email': '1@example.com', 'password': '12'}),
            headers: {
              'Content-Type': 'application/json',
            });
        if (response.statusCode == 200) {
          var body = json.decode(response.body);
          _token = body['accessToken'];
          _userId = body['user']['id'];
        } else {
          _error = 'Failed to login with status code ${response.statusCode}';
        }
      } catch (e) {
        _error = e.toString();
      }
    }
  }

  void removeItem(Product item) {
    _error = null;
    _isBusy = true;
    notifyListeners();
    _getToken();
    try {
      // final response = client.delete(Uri.parse(productsUrl));
    } catch (e) {
      // print(e);
    }
  }

  void groupByCategoryChanged(bool value) {
    groupByCategory = value;
    _doSorting();
    notifyListeners();
  }

  void _doSorting() {
    if (groupByCategory && moveBoughtDown) {
      products.sort((a, b) => a.category.name.compareTo(b.category.name));
      products.sort((a, b) => a.isBought ? 1 : -1);
    } else if (groupByCategory && !moveBoughtDown) {
      products.sort((a, b) => a.id.compareTo(b.id));
      products.sort((a, b) => a.category.name.compareTo(b.category.name));
    } else if (!groupByCategory && moveBoughtDown) {
      products.sort((a, b) => a.id.compareTo(b.id));
      products.sort((a, b) => a.isBought ? 1 : -1);
    } else {
      products.sort((a, b) => a.id.compareTo(b.id));
    }
  }

  void moveBoughtDownChanged(bool value) {
    moveBoughtDown = value;
    _doSorting();
    notifyListeners();
  }
}
