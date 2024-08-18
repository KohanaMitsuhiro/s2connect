import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
      );
      GoRouter.of(context).go('/products');
    } catch (e) {
      print(e); // Error handling
      _showErrorDialog(e);
    }
  }

  Future<void> _register() async {
    if (!_isValidEmail(_registerEmailController.text)) {
      _showInvalidEmailDialog();
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _registerEmailController.text,
        password: _registerPasswordController.text,
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
          title: Text('登録完了'),
          content: Text('登録完了しました！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // ダイアログを閉じる
                GoRouter.of(context).go('/products');  // product_list_pageに遷移
              },
              child: Text('ログインする'),
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
          title: Text('エラー'),
          content: Text('メールアドレスの形式ではありません'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // ダイアログを閉じる
              },
              child: Text('閉じる'),
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
          title: Text('エラー'),
          content: Text('エラーが発生しました: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // ダイアログを閉じる
              },
              child: Text('閉じる'),
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
        title: Text('ログイン/新規登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ログイン', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(
                controller: _loginEmailController,
                decoration: InputDecoration(labelText: 'メールアドレス'),
              ),
              TextField(
                controller: _loginPasswordController,
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _login,
                  child: Text('ログイン'),
                ),
              ),
              SizedBox(height: 20),
              Text('新規登録', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(
                controller: _registerEmailController,
                decoration: InputDecoration(labelText: 'メールアドレス'),
              ),
              TextField(
                controller: _registerPasswordController,
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _register,
                  child: Text('新規登録'),
                ),
              ),
              SizedBox(height: 20),
              Text('商品登録ページ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Center(
                child: ElevatedButton(
                  onPressed: () => GoRouter.of(context).go('/admin'),
                  child: Text('商品登録ページへ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
