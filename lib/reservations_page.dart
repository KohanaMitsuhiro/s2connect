import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/community_model.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

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
      body: Column(
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              physics: const ClampingScrollPhysics(),
              children: [
                _buildCommunityCard(context),
                const SizedBox(height: 16),
                _buildOrderSummary(context),
              ],
            ),
          ),
          _buildBottomNavigation(context),
        ],
      ),
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

  Widget _buildCommunityCard(BuildContext context) {
    final community = Provider.of<CommunityModel>(context);
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
              child: community.imagePath == null
                  ? Image.asset('assets/images/S2.png')
                  : Image.file(File(community.imagePath!)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.communityName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(community.communityDetails),
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
        _buildOrderCard(context, '7/17', 5, 22, 4, 5),
        _buildOrderCard(context, '7/24', 2, 8, 1, 12),
        _buildOrderCard(context, '7/31', 0, 0, 0, 19),
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
