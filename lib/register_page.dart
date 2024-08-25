import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'profile_data.dart'; // プロフィールデータを取得
import 'services/firebase_service.dart'; // FirebaseServiceをインポート

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();

  Future<void> _register() async {
    if (!_isValidEmail(_registerEmailController.text)) {
      _showInvalidEmailDialog();
      return;
    }

    try {
      // Firebase Authにユーザーを作成
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _registerEmailController.text,
        password: _registerPasswordController.text,
      );

      // Firestoreに追加情報を保存
      FirebaseService firebaseService = FirebaseService();
      await firebaseService.createUserProfile(
        name: Provider.of<ProfileData>(context, listen: false).name!,
        nickName: Provider.of<ProfileData>(context, listen: false)
            .nickName!, // ここでニックネームを追加
        email: _registerEmailController.text,
        password: _registerPasswordController.text,
        dateOfBirth:
            Provider.of<ProfileData>(context, listen: false).dateOfBirth!,
      );

      _showRegistrationDialog();
    } catch (e) {
      print(e); // Error handling
      _showErrorDialog(e);
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('登録完了'),
          content: const Text('登録完了しました！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
                GoRouter.of(context).push('/products'); // product_list_pageに遷移
              },
              child: const Text('ログインする'),
            ),
          ],
        );
      },
    );
  }

  void _showInvalidEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('エラー'),
          content: const Text('メールアドレスの形式ではありません'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(dynamic e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('エラー'),
          content: Text('エラーが発生しました: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('新規登録',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(
                controller: _registerEmailController,
                decoration: const InputDecoration(labelText: 'メールアドレス'),
              ),
              TextField(
                controller: _registerPasswordController,
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _register,
                  child: const Text('新規登録'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
