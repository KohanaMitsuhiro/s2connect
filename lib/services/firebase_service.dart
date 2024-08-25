import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserProfile({
    required String name,
    required String nickName,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    String? communityId,
    List<String>? coupons,
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

        // コミュニティIDが指定されていない場合、デフォルトのコミュニティIDを使用
        communityId ??= await _getDefaultCommunityId();

        // Firestoreにユーザープロフィールを保存
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'nickName': nickName,
          'email': email,
          'date_of_birth': dateOfBirth.toIso8601String(),
          'communityId': communityId,
          'appliedCoupons': coupons ?? [],
        });

        // コミュニティのメンバー数を更新
        await _incrementCommunityMemberCount(communityId);

        print('Firestoreにユーザープロフィールが保存されました');
      } else {
        print('ユーザーがnullです');
      }
    } catch (e) {
      print('Firestoreにデータを書き込む際にエラーが発生しました: $e');
      rethrow;
    }
  }

  // 招待コードからコミュニティIDを取得
  Future<String?> getCommunityIdByInviteCode(String inviteCode) async {
    final snapshot = await _firestore
        .collection('communities')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    } else {
      return null;
    }
  }

  // コミュニティのメンバー数をインクリメントまたはデクリメント
  Future<void> updateCommunityMemberCount(String communityId,
      {required int increment}) async {
    try {
      await _firestore.collection('communities').doc(communityId).update({
        'memberCount': FieldValue.increment(increment),
      });
      print('コミュニティのメンバー数が更新されました');
    } catch (e) {
      print('メンバー数の更新中にエラーが発生しました: $e');
      rethrow;
    }
  }

  // コミュニティのメンバー数をインクリメント
  Future<void> _incrementCommunityMemberCount(String communityId) async {
    await updateCommunityMemberCount(communityId, increment: 1);
  }

  // コミュニティのメンバー数をデクリメント
  Future<void> _decrementCommunityMemberCount(String communityId) async {
    await updateCommunityMemberCount(communityId, increment: -1);
  }

  // ユーザーIDからユーザーデータを取得
  Future<DocumentSnapshot> getUserById(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // コミュニティIDからコミュニティデータを取得
  Future<DocumentSnapshot> getCommunityById(String communityId) async {
    return await _firestore.collection('communities').doc(communityId).get();
  }

  // デフォルトのコミュニティIDを取得
  Future<String> _getDefaultCommunityId() async {
    final snapshot = await _firestore
        .collection('communities')
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    } else {
      throw Exception('デフォルトのコミュニティが見つかりません');
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
