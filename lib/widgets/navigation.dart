// widgets/navigation.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget buildBottomNavigation(BuildContext context) {
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
