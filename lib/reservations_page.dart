import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'widgets/navigation.dart';

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  Future<Map<String, String>> _fetchCommunityInfo() async {
    final firebaseService = FirebaseService();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return {'communityName': 'Unknown', 'communityDetails': 'Not available'};
    }

    DocumentSnapshot userDoc = await firebaseService.getUserById(userId);
    String? communityId = userDoc['communityId'];

    if (communityId == null) {
      return {'communityName': 'Unknown', 'communityDetails': 'Not available'};
    }

    DocumentSnapshot communityDoc =
        await firebaseService.getCommunityById(communityId);

    if (!communityDoc.exists) {
      return {'communityName': 'Unknown', 'communityDetails': 'Not available'};
    }

    return {
      'communityName': communityDoc['communityName'],
      'communityDetails': communityDoc['communityDetails'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6B352),
        title: const Text('予約状況'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.grey[800],
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTopNavButton(
                      context, Icons.restaurant_menu, '予約状況', '/reservations'),
                  _buildTopNavButton(context, Icons.list, '掲示板', '/bulletin'),
                  _buildTopNavButton(context, Icons.mail, '招待', '/invites'),
                  _buildTopNavButton(
                      context, Icons.change_circle, '所属変更', '/change'),
                ],
              ),
            ),
            FutureBuilder<Map<String, String>>(
              future: _fetchCommunityInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('エラーが発生しました'));
                } else {
                  final communityName =
                      snapshot.data?['communityName'] ?? 'Unknown';
                  final communityDetails =
                      snapshot.data?['communityDetails'] ?? 'Not available';

                  return Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child:
                              _buildCommunityCard(context, communityName, ''),
                        ),
                        TabBar(
                          labelColor: const Color(0xFFF6B352),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: const Color(0xFFF6B352),
                          tabs: const [
                            Tab(text: "すべて"),
                            Tab(text: "個別配送"),
                            Tab(text: "一括配送"),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildScrollableEventList(context, null),
                              _buildScrollableEventList(context, false),
                              _buildScrollableEventList(context, true),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            communityDetails.replaceAll(r'\n', '\n'),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }

  Widget _buildTopNavButton(
      BuildContext context, IconData icon, String label, String route) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: 30.0),
          onPressed: () {
            GoRouter.of(context).push(route);
          },
        ),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildCommunityCard(
      BuildContext context, String communityName, String communityDetails) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset('assets/images/S2.png'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    communityName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).push('/community_details');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF6B352),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('詳細'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableEventList(BuildContext context, bool? isBulk) {
    final firebaseService = FirebaseService();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('ユーザーが認証されていません'));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: firebaseService.getUserById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('コミュニティ情報を取得できませんでした'));
        }

        String communityId = snapshot.data!['communityId'];

        final Stream<QuerySnapshot> eventsStream = (isBulk == null)
            ? firebaseService.getCommunityEvents(communityId)
            : firebaseService.getCommunityEventsByType(communityId, isBulk!);

        return StreamBuilder<QuerySnapshot>(
          stream: eventsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('エラーが発生しました'));
            }

            final List<DocumentSnapshot> documents = snapshot.data?.docs ?? [];

            if (documents.isEmpty) {
              return const Center(child: Text('現在、表示できるイベントはありません。'));
            }

            return Expanded(
              child: ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  final int participantCount = doc['participantCount'] ?? 0;
                  final int shippingCost = participantCount > 0
                      ? (950 / participantCount).round()
                      : 950; // 参加人数が0またはnullの場合はデフォルトの950円を設定

                  return _buildOrderCard(
                    context,
                    _parseTimestamp(doc['eventDate']),
                    participantCount,
                    doc['location'] ?? '',
                    shippingCost,
                    _parseTimestamp(doc['orderDeadline']),
                    doc.id, // イベントIDを渡す
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    DateTime eventDate,
    int people,
    String location,
    int shippingCost,
    DateTime orderDeadline,
    String eventId, // イベントIDを追加
  ) {
    return Card(
      color: const Color(0xFFF6B352),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          GoRouter.of(context).push('/order', extra: {
            'eventDate': eventDate,
            'eventId': eventId,
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('開催日',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15)),
                  Text(DateFormat('MM/dd').format(eventDate),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 23.0),
                  Text('$people',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.white, size: 23.0),
                  Text(location,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  const Text('送料',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  Text('$shippingCost円',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
              Column(
                children: [
                  Text('締切: ${DateFormat('MM/dd').format(orderDeadline)}',
<<<<<<< HEAD
                      style:
                          const TextStyle(color: Colors.black, fontSize: 12)),
=======
                      style: const TextStyle(color: Colors.black, fontSize: 15)),
>>>>>>> feature/forPresentasion
                  const Icon(Icons.shopping_cart,
                      color: Colors.white, size: 23.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else {
      throw ArgumentError('Unsupported timestamp format: $timestamp');
    }
  }
}
