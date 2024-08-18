import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final List<_CartItem> _items = [];

  List<_CartItem> get items => _items;

  void addItem(String productId, String name, int price, int quantity) {
    var item = _items.firstWhere(
          (item) => item.productId == productId,
      orElse: () => _CartItem(productId, name, price, 0),
    );
    if (item.quantity == 0) {
      _items.add(item);
    }
    item.quantity += quantity;
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    var item = _items.firstWhere((item) => item.productId == productId);
    item.quantity = quantity;
    notifyListeners();
  }

  int get totalQuantity =>
      _items.fold(0, (total, current) => total + current.quantity);

  int get totalPrice =>
      _items.fold(0, (total, current) => total + (current.quantity * current.price));
}

class _CartItem {
  final String productId;
  final String name;
  final int price;
  int quantity;

  _CartItem(this.productId, this.name, this.price, this.quantity);
}
