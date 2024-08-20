import 'package:flutter/foundation.dart';

// カート内の各アイテムを表すモデルクラス
class CartItem {
  final String productId;
  final String name;
  final int price;
  final String imageUrl; // imageUrl プロパティを追加
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl, // コンストラクタに imageUrl を追加
    this.quantity = 1,
  });
}

// カート全体を管理するモデルクラス
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // カートにアイテムを追加するメソッド
  void addItem(
      String productId, String name, int price, String imageUrl, int quantity) {
    print('addItem called with productId: $productId'); // デバッグ用ログ
    var item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
          productId: productId,
          name: name,
          price: price,
          imageUrl: imageUrl, // imageUrl を適切に渡す
          quantity: 0),
    );
    if (item.quantity == 0) {
      _items.add(item);
    }
    item.quantity += quantity;
    debugPrint('Item added: $name, Quantity: ${item.quantity}'); // デバッグ用のログ
    notifyListeners();
  }

  // カートからアイテムを削除するメソッド
  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  // アイテムの数量を更新するメソッド
  void updateQuantity(String productId, int quantity) {
    var item = _items.firstWhere((item) => item.productId == productId);
    item.quantity = quantity;
    notifyListeners();
  }

  // カート内のアイテムの合計数量を取得するゲッター
  int get totalQuantity =>
      _items.fold(0, (total, current) => total + current.quantity);

  // カート内のアイテムの合計金額を取得するゲッター
  int get totalPrice => _items.fold(
      0, (total, current) => total + (current.quantity * current.price));
}
