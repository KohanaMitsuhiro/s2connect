import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイページ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop(); // 前のページに戻る
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'マイページダッシュボード',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'ここにユーザーの登録状況、継続期間、使用金額などの情報を表示します。',
              textAlign: TextAlign.center,
            ),
            // 追加の情報やUI要素をここに配置
          ],
        ),
      ),
    );
  }
}
