import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'styles.dart';
import 'constants.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showDialog(context, 'エラー', 'メールアドレスとパスワードを入力してください。');
      return;
    }

    UserCredential? userCredential;
    String? errorMessage;

    try {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'このメールアドレスに対応するユーザーが見つかりません。';
          break;
        case 'wrong-password':
          errorMessage = 'パスワードが間違っています。';
          break;
        case 'invalid-email':
          errorMessage = 'メールアドレスの形式が正しくありません。';
          break;
        case 'user-disabled':
          errorMessage = 'このユーザーアカウントは無効になっています。';
          break;
        case 'invalid-credential':
          errorMessage = '提供された認証情報が無効です。';
          break;
        default:
          errorMessage = '不明なエラーが発生しました: ${e.message}';
      }
    } catch (e) {
      errorMessage = 'エラーが発生しました: ${e.toString()}';
    }

    if (errorMessage != null) {
      _showDialog(context, 'エラー', errorMessage);
    } else if (userCredential != null) {
      GoRouter.of(context).go('/reservations');
    }
  }

  void _showDialog(BuildContext context, String title, String? content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: zenMaruGothicStyle),
          content: Text(content ?? '', style: zenMaruGothicStyle), // nullの場合は空文字列を使用
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('閉じる', style: zenMaruGothicStyle),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {bool obscureText = false}) {
    return SizedBox(
      width: 280,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        obscureText: obscureText,
        style: zenMaruGothicStyle,
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed,
      {bool outlined = false}) {
    return SizedBox(
      width: 200,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFC913A),
              ),
              child: Text(text, style: zenMaruGothicStyle),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC913A),
                foregroundColor: Colors.white,
              ),
              child: Text(text, style: zenMaruGothicStyle),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(paddingSize),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rowウィジェットで画像とテキストを横並びにし、Paddingで調整
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end, // 底辺を揃える
                children: [
                  // ロゴ画像
                  Image.asset(
                    'assets/images/S3.png',
                    width: imageSize * 1.5, // 画像を少し大きくする
                    height: imageSize * 1.5,
                  ),
                  const SizedBox(width: 8), // 画像とテキストの間のスペース
                  // "connect" テキストをPaddingで少し下に移動
                  Padding(
                    padding: const EdgeInsets.only(bottom: 38), // 微調整するためのpadding
                    child: Text(
                      'connect',
                      style: zenMaruGothicStyle.copyWith(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold,),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: spaceSize),
              Text(
                '100%国産素材 x 食品添加物82種不使用',
                style: zenMaruGothicStyle.copyWith(
                    fontSize: descriptionFontSize, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: spaceSize),
              _buildTextField(
                  _emailController, 'メールアドレス', 'example@example.com'),
              _buildTextField(_passwordController, 'パスワード', 'パスワードを入力',
                  obscureText: true),
              const SizedBox(height: buttonSpaceSize),
              _buildButton('ログイン', () => _login(context)),
              const SizedBox(height: spaceSize),
              _buildButton('会員登録', () {
                GoRouter.of(context).go('/registerProfile');
              }, outlined: true),
            ],
          ),
        ),
      ),
    );
  }
}
