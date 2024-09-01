import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ユーザープロフィールを作成するメソッド
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

  // 招待コードからコミュニティIDを取得するメソッド
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

  // コミュニティのメンバー数を更新するメソッド
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

  Future<void> _incrementCommunityMemberCount(String communityId) async {
    await updateCommunityMemberCount(communityId, increment: 1);
  }

  Future<void> _decrementCommunityMemberCount(String communityId) async {
    await updateCommunityMemberCount(communityId, increment: -1);
  }

  // ユーザーIDからユーザーデータを取得するメソッド
  Future<DocumentSnapshot> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('ユーザーが存在しません');
      }
      return userDoc;
    } catch (e) {
      print('ユーザーデータ取得中にエラーが発生しました: $e');
      rethrow;
    }
  }

  // コミュニティIDからコミュニティデータを取得するメソッド
  Future<DocumentSnapshot> getCommunityById(String communityId) async {
    return await _firestore.collection('communities').doc(communityId).get();
  }

  // デフォルトのコミュニティIDを取得するメソッド
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

  // クーポンをユーザーに追加するメソッド
  Future<void> addCouponToUser(String userId, String couponId) async {
    try {
      DocumentSnapshot userDoc = await getUserById(userId);
      List<dynamic> appliedCoupons = userDoc['appliedCoupons'];

      if (!appliedCoupons.contains(couponId)) {
        print('クーポンをユーザーに追加: $couponId');
        await _firestore.collection('users').doc(userId).update({
          'appliedCoupons': FieldValue.arrayUnion([couponId]),
        });
        print('クーポンが追加されました');
      } else {
        print('クーポンは既に適用されています: $couponId');
      }
    } catch (e) {
      print('クーポン情報の追加中にエラーが発生しました: $e');
      rethrow;
    }
  }

  // クーポンをユーザーから削除するメソッド
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

  // クーポンIDからクーポンデータを取得するメソッド
  Future<DocumentSnapshot> getCoupon(String couponId) async {
    return await _firestore.collection('coupons').doc(couponId).get();
  }

  // クーポンの使用回数を更新するメソッド
  Future<void> updateCouponUsage(String couponId, {required int usage}) async {
    await _firestore.collection('coupons').doc(couponId).update({
      'usage': FieldValue.increment(usage),
    });
  }

  // コミュニティイベントを取得するメソッド
  Future<DocumentSnapshot> getCommunityEvent(String eventId) async {
    return await _firestore.collection('community_events').doc(eventId).get();
  }

  // コミュニティイベントを作成するメソッド
  Future<String> createCommunityEvent(Map<String, dynamic> eventData) async {
    // イベントIDを先に生成
    DocumentReference docRef = _firestore.collection('community_events').doc();
    String eventId = docRef.id;

    // クーポンを生成し、coupon_idを取得する
    String couponId = _firestore.collection('coupons').doc().id;

    // クーポンデータを作成
    Map<String, dynamic> couponData = {
      'coupon_id': couponId,
      'event_id': eventId, // イベントIDを使用
      'coupon_name': 'Event Discount',
      'created_at': Timestamp.now(),
      'discount_rate': 0,
      'expires_at': eventData['orderDeadline'], // 適切な期限に設定
      'is_dynamic': true,
      'shipping_cost': eventData['shippingCost'],
      'total_issued': 1
    };

    // イベントとクーポンを一緒に作成
    await docRef.set({
      ...eventData,
      'event_id': eventId,
      'coupon_id': couponId, // coupon_idをイベントデータに追加
    });

    await createEventCoupon(couponData); // クーポンをFirestoreに保存

    return eventId;
  }

  // イベントクーポンを保存するメソッド
  Future<void> createEventCoupon(Map<String, dynamic> couponData) async {
    await _firestore.collection('coupons').add(couponData);
  }

  // イベントの参加人数をインクリメントするメソッド
  Future<String?> incrementParticipantCount(
      String eventId, String userId) async {
    try {
      DocumentReference eventRef =
          _firestore.collection('community_events').doc(eventId);
      DocumentReference userRef = _firestore.collection('users').doc(userId);

      // トランザクション内で参加者数とクーポンを更新
      String? couponId;
      await _firestore.runTransaction((transaction) async {
        // すべての読み取りを最初に行う
        DocumentSnapshot eventSnapshot = await transaction.get(eventRef);
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (!eventSnapshot.exists) {
          throw Exception("Event does not exist!");
        }

        int currentCount = eventSnapshot['participantCount'] ?? 0;
        couponId = eventSnapshot['coupon_id'];

        if (couponId != null) {
          List<dynamic> appliedCoupons = userSnapshot['appliedCoupons'] ?? [];

          // 既にクーポンが適用されていないか確認
          if (!appliedCoupons.contains(couponId)) {
            // すべての書き込みを読み取りの後に行う
            transaction.update(eventRef, {
              'participantCount': currentCount + 1,
            });
            transaction.update(userRef, {
              'appliedCoupons': FieldValue.arrayUnion([couponId]),
            });

            print('クーポンIDを追加: $couponId');
          } else {
            print('クーポンIDは既に追加済み: $couponId');
          }
        } else {
          print('クーポンIDがnullです。');
        }
      });

      print('参加人数とクーポンの更新が完了しました');
      return couponId;
    } catch (e) {
      print('参加人数のインクリメント中にエラーが発生しました: $e');
      rethrow;
    }
  }

  // イベントの参加人数をデクリメントするメソッド
  Future<void> decrementParticipantCount(String eventId, String userId) async {
    try {
      DocumentReference eventRef =
          _firestore.collection('community_events').doc(eventId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot eventSnapshot = await transaction.get(eventRef);
        if (!eventSnapshot.exists) {
          throw Exception("Event does not exist!");
        }

        int currentCount = eventSnapshot['participantCount'] ?? 0;

        if (currentCount > 0) {
          transaction.update(eventRef, {
            'participantCount': currentCount - 1,
          });

          transaction.update(
            _firestore.collection('users').doc(userId),
            {
              'appliedCoupons': FieldValue.arrayRemove([eventId]),
            },
          );
        }
      });

      print('参加人数の減少とクーポンの削除が完了しました');
    } catch (e) {
      print('参加人数のデクリメント中にエラーが発生しました: $e');
      rethrow;
    }
  }

  // コミュニティイベントを取得するメソッド
  Stream<QuerySnapshot> getCommunityEvents(String communityId) {
    return _firestore
        .collection('community_events')
        .where('communityId', isEqualTo: communityId)
        .snapshots();
  }

  // イベントタイプ別にコミュニティイベントを取得するメソッド
  Stream<QuerySnapshot> getCommunityEventsByType(
      String communityId, bool isBulk) {
    return _firestore
        .collection('community_events')
        .where('communityId', isEqualTo: communityId)
        .where('isBulk', isEqualTo: isBulk)
        .snapshots();
  }

  // 動的な割引率を計算するメソッド
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

  // 動的なクーポンを適用するメソッド
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
      int participants = event['participantCount'];
      discountRate =
          calculateDynamicDiscountRate(participants, coupon['shipping_cost']);
    }

    await applyDiscountToUserOrder(userId, discountRate);

    await updateCouponUsage(couponId, usage: -1);

    print('クーポンが適用されました');
  }

  // クーポンの適用をキャンセルするメソッド
  Future<void> cancelCouponApplication(String couponId) async {
    await updateCouponUsage(couponId, usage: 1);
    print('クーポンの適用がキャンセルされました');
  }

  // 注文に割引を適用するメソッド
  Future<void> applyDiscountToUserOrder(
      String userId, double discountRate) async {
    // 注文情報への割引適用処理を実装
  }

  // イベントの参加者数を取得するメソッド
  Future<int> getEventParticipants(String eventId) async {
    DocumentSnapshot event = await getCommunityEvent(eventId);
    return event['participantCount'] ?? 0;
  }

  // ユーザーが参加しているイベントを取得するメソッド
  Stream<QuerySnapshot> getUserEvents(String userId) {
    return _firestore
        .collection('community_events')
        .where('participants', arrayContains: userId)
        .snapshots();
  }

  // ユーザーが持っているクーポンを取得するメソッド
  Future<List<DocumentSnapshot>> getUserCoupons(String userId) async {
    try {
      DocumentSnapshot userDoc = await getUserById(userId);
      List<dynamic> couponIds = userDoc['appliedCoupons'] ?? [];

      List<DocumentSnapshot> coupons = [];
      for (String couponId in couponIds) {
        DocumentSnapshot couponDoc = await getCoupon(couponId);
        if (couponDoc.exists) {
          coupons.add(couponDoc);
        }
      }
      return coupons;
    } catch (e) {
      print('クーポン情報の取得中にエラーが発生しました: $e');
      rethrow;
    }
  }
}
