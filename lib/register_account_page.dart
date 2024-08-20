import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'styles.dart';
import 'profile_data.dart';

const double paddingSize = 16.0;
const double spaceSize = 16.0;
const double buttonSpaceSize = 32.0;
const double titleFontSize = 24.0;

class RegisterAccountPage extends StatelessWidget {
  final TextEditingController _nicknameController;
  final TextEditingController _emailController;
  final TextEditingController _passwordController;

  RegisterAccountPage({super.key})
      : _nicknameController = TextEditingController(),
        _emailController = TextEditingController(),
        _passwordController = TextEditingController();

  void _register(BuildContext context) {
    if (_nicknameController.text.isEmpty) {
      _showDialog(context, 'エラー', 'ニックネームを入力してください。');
      return;
    }

    if (_emailController.text.isEmpty) {
      _showDialog(context, 'エラー', 'メールアドレスを入力してください。');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showDialog(context, 'エラー', 'パスワードを入力してください。');
      return;
    }

    // Update the profile data
    Provider.of<ProfileData>(context, listen: false)
        .updateNickName(_nicknameController.text);
    Provider.of<ProfileData>(context, listen: false)
        .updateEmail(_emailController.text);
    Provider.of<ProfileData>(context, listen: false)
        .updatePassword(_passwordController.text);

    GoRouter.of(context).go('/registerCommunity');
  }

  void _goBack(BuildContext context) {
    GoRouter.of(context).go('/registerProfile');
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: zenMaruGothicStyle),
          content: Text(content, style: zenMaruGothicStyle),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる', style: zenMaruGothicStyle),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = zenMaruGothicStyle.copyWith(
        fontSize: titleFontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF4C4C4C));

    return Scaffold(
      appBar: AppBar(
        title: Text('会員登録',
            style: zenMaruGothicStyle.copyWith(
                color: const Color(0xFFFFFFFF), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF6B352),
      ),
      body: Column(
        children: [
          const ProfileRow(),
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 20.0),
            child: RegistrationForm(
                nicknameController: _nicknameController,
                emailController: _emailController,
                passwordController: _passwordController,
                titleStyle: titleStyle,
                register: () => _register(context),
                goBack: () => _goBack(context)),
          ),
        ],
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  const ProfileRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      color: const Color(0xFF4C4C4C),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: ProfileColumn(title: 'プロフィール')),
          Expanded(
              child: ProfileColumn(title: 'アカウント', color: Color(0xFFF68655))),
          Expanded(child: ProfileColumn(title: 'コミュニティ')),
        ],
      ),
    );
  }
}

class RegistrationForm extends StatelessWidget {
  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextStyle titleStyle;
  final VoidCallback register;
  final VoidCallback goBack;

  const RegistrationForm({
    super.key,
    required this.nicknameController,
    required this.emailController,
    required this.passwordController,
    required this.titleStyle,
    required this.register,
    required this.goBack,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: spaceSize),
          Text('アカウント', style: titleStyle),
          const SizedBox(height: spaceSize),
          CustomTextField(
              controller: nicknameController,
              labelText: 'ニックネーム',
              hintText: '(例)あやちゃん'),
          CustomTextField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'example@example.com'),
          CustomTextField(
              controller: passwordController,
              labelText: 'Password',
              hintText: '********'),
          const SizedBox(height: 120),
          Row(
            children: [
              const Spacer(flex: 1), // flexの値を調整してスペースの量を変更
              RegisterButton(register: register, goBack: goBack),
              const Spacer(flex: 9), // flexの値を調整してスペースの量を変更
            ],
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;

  const CustomTextField({
    super.key, // Key パラメータを追加
    required this.controller,
    required this.labelText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        style: zenMaruGothicStyle,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
        ),
      ),
    );
  }
}

class ProfileColumn extends StatelessWidget {
  final String title;
  final Color color;

  const ProfileColumn(
      {super.key, required this.title, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Text(
          title,
          style: zenMaruGothicStyle.copyWith(
              fontSize: 13.0, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class RegisterButton extends StatelessWidget {
  final VoidCallback register;
  final VoidCallback goBack;

  const RegisterButton(
      {super.key, required this.register, required this.goBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 130,
          child: ElevatedButton(
            onPressed: goBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC913A),
              foregroundColor: Colors.white,
              elevation: 5,
              side: BorderSide.none,
            ),
            child: Text(
              '戻る',
              style: zenMaruGothicStyle.copyWith(),
            ),
          ),
        ),
        const SizedBox(width: 70),
        SizedBox(
          width: 130,
          child: ElevatedButton(
            onPressed: register,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC913A),
              foregroundColor: Colors.white,
              elevation: 5,
              side: BorderSide.none,
            ),
            child: Text(
              '次に進む',
              style: zenMaruGothicStyle.copyWith(),
            ),
          ),
        ),
      ],
    );
  }
}
