import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/community_model.dart';
import 'package:go_router/go_router.dart';
import 'services/firebase_service.dart';

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  Future<Map<String, String>> _fetchCommunityInfo() async {
    final firebaseService = FirebaseService();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return {'communityName': 'Unknown', 'communityDetails': 'Not available'};
    }

    // ユーザーのcommunityIdを取得
    DocumentSnapshot userDoc = await firebaseService.getUserById(userId);
    String? communityId = userDoc['communityId'];

    if (communityId == null) {
      return {'communityName': 'Unknown', 'communityDetails': 'Not available'};
    }

    // communityIdを元にコミュニティ情報を取得
    DocumentSnapshot communityDoc =
        await firebaseService.getCommunityById(communityId);

    if (!communityDoc.exists) {
      return {'communityName': 'Unknown', 'communityDetails': 'Not available'};
    }

    return {
      'communityName': communityDoc['communityName'],
      'communityDetails': communityDoc['communityDetails'], // 修正済み
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('予約状況'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: DefaultTabController(
        length: 3, // Tabの数を設定
        child: Column(
          children: [
            // トップバーの情報を追加
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
                          child: _buildCommunityCard(
                              context, communityName, ''), // コミュニティ詳細を非表示
                        ),
                        TabBar(
                          labelColor: Colors.orange,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.orange,
                          tabs: const [
                            Tab(text: "すべて"),
                            Tab(text: "個別配送"),
                            Tab(text: "一括配送"),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildOrderSummary(context),
                              _buildOrderSummary(context), // 個別配送用の内容
                              _buildOrderSummary(context), // 一括配送用の内容
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            communityDetails.replaceAll(r'\n', '\n'), // 改行の処理
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
      bottomNavigationBar: _buildBottomNavigation(context),
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
                backgroundColor: Colors.orange,
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

  Widget _buildOrderSummary(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              _buildOrderCard(context, '7/17', 5, 22, 4, 5),
              _buildOrderCard(context, '7/24', 2, 8, 1, 12),
              _buildOrderCard(context, '7/31', 0, 0, 0, 19),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, String date, int people,
      int dishes, int points, int daysLeft) {
    return Card(
      color: Colors.orange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          GoRouter.of(context).push('/order', extra: date);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('注文日',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12)),
                  Text(date,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 20.0),
                  Text('$people',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.restaurant, color: Colors.white, size: 20.0),
                  Text('$dishes',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  const Text('P',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  Text('$points',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  Text('あと$daysLeft日',
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                  const Icon(Icons.shopping_cart,
                      color: Colors.white, size: 20.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.orange,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 30.0),
          label: 'マイページ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group, size: 30.0),
          label: 'コミュニティ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info, size: 30.0),
          label: 'お役立ち情報',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message, size: 30.0),
          label: 'メッセージ',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            GoRouter.of(context).push('/mypage');
            break;
          case 1:
            GoRouter.of(context).push('/community');
            break;
          case 2:
            GoRouter.of(context).push('/info');
            break;
          case 3:
            GoRouter.of(context).push('/messages');
            break;
        }
      },
    );
  }
}
