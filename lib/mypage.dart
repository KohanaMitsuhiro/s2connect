import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firebase_service.dart';
import 'widgets/navigation.dart';

class MyPage extends StatelessWidget {
  final FirebaseService firebaseService = FirebaseService();

  MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイページ'),
        backgroundColor: const Color(0xFFF6B352),
      ),
      body: userId == null
          ? const Center(child: Text('ログインしてください'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('参加中のイベント'),
                    const SizedBox(height: 8),
                    _buildEventList(context, userId),
                    const SizedBox(height: 24),
                    _buildSectionTitle('保有クーポン'),
                    const SizedBox(height: 8),
                    _buildCouponList(context, userId),
                    const SizedBox(height: 24),
                    _buildSectionTitle('所属コミュニティ'),
                    const SizedBox(height: 8),
                    _buildCommunityInfo(context, userId),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCommunityInfo(BuildContext context, String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('エラーが発生しました'));
        }

        String communityId = snapshot.data!['communityId'] ?? '未所属';
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('communities')
              .doc(communityId)
              .get(),
          builder: (context, communitySnapshot) {
            if (communitySnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (communitySnapshot.hasError ||
                !communitySnapshot.hasData ||
                !communitySnapshot.data!.exists) {
              return const Center(child: Text('コミュニティ情報を取得できませんでした'));
            }

            final communityData =
                communitySnapshot.data!.data() as Map<String, dynamic>;
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                title: Text('コミュニティ名: ${communityData['communityName']}'),
                subtitle: Text('メンバー数: ${communityData['memberCount']}人'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventList(BuildContext context, String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('エラーが発生しました'));
        }

        List<dynamic> appliedCoupons = snapshot.data!['appliedCoupons'] ?? [];

        // Debug: Log the appliedCoupons to check if they're retrieved correctly
        print('appliedCoupons: $appliedCoupons');

        if (appliedCoupons.isEmpty) {
          return const Center(child: Text('現在、参加中のイベントはありません'));
        }

        return FutureBuilder<List<DocumentSnapshot>>(
          future: _getEventsForCoupons(appliedCoupons),
          builder: (context, eventSnapshot) {
            if (eventSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (eventSnapshot.hasError ||
                !eventSnapshot.hasData ||
                eventSnapshot.data!.isEmpty) {
              return const Center(child: Text('現在、参加中のイベントはありません'));
            }

            final events = eventSnapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    title: Text(event['eventName']),
                    subtitle: Text('日時: ${event['eventDate']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // イベント編集ページに遷移する処理
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _cancelEvent(context, event.id, userId);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> _getEventsForCoupons(
      List<dynamic> couponIds) async {
    List<DocumentSnapshot> events = [];

    for (String couponId in couponIds) {
      // ドキュメントIDでクーポンを取得する
      QuerySnapshot couponSnapshot = await FirebaseFirestore.instance
          .collection('coupons')
          .where('coupon_id', isEqualTo: couponId)
          .limit(1)
          .get();

      if (couponSnapshot.docs.isNotEmpty) {
        DocumentSnapshot couponDoc = couponSnapshot.docs.first;

        // Debug: Log coupon retrieval
        print(
            'Retrieved couponDoc for couponId $couponId: ${couponDoc.exists}');

        if (couponDoc.exists) {
          String eventId = couponDoc['event_id'];
          DocumentSnapshot eventDoc = await FirebaseFirestore.instance
              .collection('community_events')
              .doc(eventId)
              .get();

          // Debug: Log event retrieval
          print('Retrieved eventDoc for eventId $eventId: ${eventDoc.exists}');

          if (eventDoc.exists) {
            events.add(eventDoc);
          }
        }
      } else {
        print('No coupon found with ID: $couponId');
      }
    }

    return events;
  }

  void _cancelEvent(BuildContext context, String eventId, String userId) async {
    try {
      await firebaseService.removeCouponFromUser(userId, eventId);
      await firebaseService.decrementParticipantCount(eventId, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベントがキャンセルされました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: ${e.toString()}')),
      );
    }
  }

  Widget _buildCouponList(BuildContext context, String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('エラーが発生しました'));
        }

        List<dynamic> appliedCoupons = snapshot.data!['appliedCoupons'] ?? [];

        // Debug: Log the appliedCoupons to check if they're retrieved correctly
        print('appliedCoupons: $appliedCoupons');

        if (appliedCoupons.isEmpty) {
          return const Center(child: Text('現在、保有しているクーポンはありません'));
        }

        return FutureBuilder<List<DocumentSnapshot>>(
          future: _getCouponsForUser(appliedCoupons),
          builder: (context, couponSnapshot) {
            if (couponSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (couponSnapshot.hasError ||
                !couponSnapshot.hasData ||
                couponSnapshot.data!.isEmpty) {
              return const Center(child: Text('現在、保有しているクーポンはありません'));
            }

            final coupons = couponSnapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    title: Text(coupon['coupon_name']),
                    subtitle: Text('有効期限: ${coupon['expires_at']}'),
                    trailing: Text(
                      '割引率: ${coupon['discount_rate']}%',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> _getCouponsForUser(
      List<dynamic> couponIds) async {
    List<DocumentSnapshot> coupons = [];

    for (String couponId in couponIds) {
      try {
        QuerySnapshot couponSnapshot = await FirebaseFirestore.instance
            .collection('coupons')
            .where('coupon_id', isEqualTo: couponId)
            .limit(1)
            .get();

        if (couponSnapshot.docs.isNotEmpty) {
          DocumentSnapshot couponDoc = couponSnapshot.docs.first;

          // Debug: Log coupon retrieval
          print(
              'Retrieved couponDoc for couponId $couponId: ${couponDoc.exists}');

          if (couponDoc.exists) {
            coupons.add(couponDoc);
          }
        } else {
          print('No coupon found with ID: $couponId');
        }
      } catch (e) {
        print('Error retrieving coupon with ID $couponId: $e');
      }
    }

    return coupons;
  }
}
