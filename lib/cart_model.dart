import 'package:flutter/foundation.dart';
import 'package:s2connect/services/firebase_service.dart';

// カート内の各アイテムを表すモデルクラス
class CartItem {
  final String productId;
  final String name;
  final int price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
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

  // クーポンの適用
  Future<void> applyCoupon(String couponId, String userId) async {
    FirebaseService firebaseService = FirebaseService();
    var coupon = await firebaseService.getCoupon(couponId);

    if (coupon.exists) {
      double discountRate = coupon['discount_rate'];
      bool isDynamic = coupon['is_dynamic'];

      if (isDynamic) {
        String eventId = coupon['event_id'];
        int participants = await firebaseService.getEventParticipants(eventId);
        discountRate = firebaseService.calculateDynamicDiscountRate(
            participants, coupon['shipping_cost']);
      }

      // ユーザーの注文に割引を適用する処理を追加
      await firebaseService.applyDiscountToUserOrder(userId, discountRate);

      // クーポンの適用をユーザーに反映
      await firebaseService.addCouponToUser(couponId, userId);

      notifyListeners();
    }
  }

  // クーポンのキャンセル
  Future<void> cancelCoupon(String couponId, String userId) async {
    FirebaseService firebaseService = FirebaseService();
    await firebaseService.removeCouponFromUser(couponId, userId);
    notifyListeners();
  }
}
