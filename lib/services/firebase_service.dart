import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserProfile({
    required String name,
    required String nickName, // ニックネームを追加
    required String email,
    required String password,
    required DateTime dateOfBirth,
    String? communityId, // オプションのコミュニティIDを追加
    List<String>? coupons, // クーポンリストを追加
  }) async {
    try {
      // Firebase Authenticationでユーザーを作成
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        print('ユーザーID: ${user.uid}');

        // Firestoreにユーザープロフィールを保存
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'nickName': nickName, // ニックネームを保存
          'email': email,
          'date_of_birth': dateOfBirth.toIso8601String(),
          'communityId': communityId ?? null, // コミュニティIDを追加（デフォルトはnull）
          'appliedCoupons': coupons ?? [], // クーポンリストを追加（デフォルトは空リスト）
        });
        print('Firestoreにユーザープロフィールが保存されました');
      } else {
        print('ユーザーがnullです');
      }
    } catch (e) {
      print('Firestoreにデータを書き込む際にエラーが発生しました: $e');
      rethrow;
    }
  }

  Future<void> updateUserCommunity(String userId, String communityId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'communityId': communityId,
      });
      print('コミュニティ情報が更新されました');
    } catch (e) {
      print('コミュニティ情報の更新中にエラーが発生しました: $e');
      rethrow;
    }
  }

  Future<void> addCouponToUser(String userId, String couponId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'appliedCoupons': FieldValue.arrayUnion([couponId]),
      });
      print('クーポンが追加されました');
    } catch (e) {
      print('クーポン情報の追加中にエラーが発生しました: $e');
      rethrow;
    }
  }

  Future<void> removeCouponFromUser(String userId, String couponId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'appliedCoupons': FieldValue.arrayRemove([couponId]),
      });
      print('クーポンが削除されました');
    } catch (e) {
      print('クーポン情報の削除中にエラーが発生しました: $e');
      rethrow;
    }
  }

  Future<DocumentSnapshot> getCoupon(String couponId) async {
    return await _firestore.collection('coupons').doc(couponId).get();
  }

  Future<void> updateCouponUsage(String couponId, {required int usage}) async {
    await _firestore.collection('coupons').doc(couponId).update({
      'usage': FieldValue.increment(usage),
    });
  }

  Future<void> applyCoupon(String couponId, String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'appliedCoupons': FieldValue.arrayUnion([couponId]),
    });
  }

  Future<void> removeCoupon(String couponId, String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'appliedCoupons': FieldValue.arrayRemove([couponId]),
    });
  }

  Future<DocumentSnapshot> getCommunityEvent(String eventId) async {
    return await _firestore.collection('community_events').doc(eventId).get();
  }

  Future<void> createCommunityEvent(Map<String, dynamic> eventData) async {
    await _firestore.collection('community_events').add(eventData);
  }

  double calculateDynamicDiscountRate(int participants, double shippingCost) {
    double baseDiscountRate = 0;

    if (participants >= 5) {
      baseDiscountRate = 20;
    } else if (participants >= 3) {
      baseDiscountRate = 10;
    }

    double dynamicDiscount =
        baseDiscountRate + (participants * (1000 / shippingCost));

    if (dynamicDiscount > 50) {
      dynamicDiscount = 50;
    }

    return dynamicDiscount;
  }

  Future<void> applyDynamicCoupon(String couponId, String userId) async {
    DocumentSnapshot coupon = await getCoupon(couponId);

    if (!coupon.exists) {
      print('クーポンが存在しません');
      return;
    }

    double discountRate = coupon['discount_rate'];
    bool isDynamic = coupon['is_dynamic'];

    if (isDynamic) {
      String eventId = coupon['event_id'];
      DocumentSnapshot event = await getCommunityEvent(eventId);
      int participants = event['participants'];
      discountRate =
          calculateDynamicDiscountRate(participants, coupon['shipping_cost']);
    }

    await applyDiscountToUserOrder(userId, discountRate);

    await updateCouponUsage(couponId, usage: -1);

    print('クーポンが適用されました');
  }

  Future<void> cancelCouponApplication(String couponId) async {
    await updateCouponUsage(couponId, usage: 1);
    print('クーポンの適用がキャンセルされました');
  }

  Future<void> applyDiscountToUserOrder(
      String userId, double discountRate) async {
    // 注文情報への割引適用処理を実装
  }

  Future<int> getEventParticipants(String eventId) async {
    DocumentSnapshot event = await getCommunityEvent(eventId);
    return event['participants'] ?? 0;
  }
}
