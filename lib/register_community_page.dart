import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'styles.dart';
import 'constants.dart';
import 'profile_data.dart';
import 'services/firebase_service.dart';

// 定数の定義
const double paddingSize = 16.0;
const double spaceSize = 16.0;
const double buttonSpaceSize = 32.0;
const double titleFontSize = 24.0;
const Color appBarColor = Color(0xFFF6B352);
const Color whiteColor = Color(0xFFFFFFFF);
const Color blackColor = Color(0xFF4C4C4C);
const Color profileColumnColor = Color(0xFFF68655);

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ProfileData(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RegisterCommunityPage(),
    );
  }
}

class RegisterCommunityPage extends StatelessWidget {
  const RegisterCommunityPage({super.key});

  static const String reservationsRoute = '/reservations';
  static const String registerAccountRoute = '/registerAccount';

  // ルーティングメソッド
  void _register(BuildContext context) async {
    final profileData = Provider.of<ProfileData>(context, listen: false);
    final firebaseService = FirebaseService();

    print('名前: ${profileData.name}');
    print('ニックネーム: ${profileData.nickName}'); // ニックネームを表示
    print('メールアドレス: ${profileData.email}');
    print('パスワード: ${profileData.password}');
    print('生年月日: ${profileData.dateOfBirth}');

    try {
      if (profileData.name == null ||
          profileData.nickName == null || // ニックネームの確認を追加
          profileData.email == null ||
          profileData.password == null ||
          profileData.dateOfBirth == null) {
        _showErrorDialog(context, 'すべての必須情報を入力してください。');
        return;
      }

      // FirebaseServiceを使ってFirebase AuthenticationとFirestoreへの書き込みを行う
      await firebaseService.createUserProfile(
        name: profileData.name!,
        nickName: profileData.nickName!, // ニックネームを渡す
        email: profileData.email!,
        password: profileData.password!,
        dateOfBirth: profileData.dateOfBirth!,
        communityId: null, // デフォルトでコミュニティIDをnullに設定
        coupons: [], // クーポンリストは空リストで初期化
      );

      // 次の画面に遷移
      GoRouter.of(context).go(reservationsRoute);
    } catch (e) {
      print('エラーが発生しました: $e');
      _showErrorDialog(context, 'ユーザー登録中にエラーが発生しました: ${e.toString()}');
    }
  }

  void _goBack(BuildContext context) {
    GoRouter.of(context).go(registerAccountRoute);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('エラー'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
    final titleStyle = zenMaruGothicStyle.copyWith(
        fontSize: titleFontSize,
        fontWeight: FontWeight.bold,
        color: blackColor);

    return Scaffold(
      appBar: AppBar(
        title: Text('会員登録',
            style: zenMaruGothicStyle.copyWith(
                color: whiteColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarColor,
      ),
      body: Column(
        children: [
          const ProfileRow(),
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 20.0),
            child: RegistrationForm(
                titleStyle: titleStyle,
                register: () => _register(context),
                goBack: () => _goBack(context)),
          ),
        ],
      ),
    );
  }
}

// プロフィールの行を表示するウィジェット
class ProfileRow extends StatelessWidget {
  const ProfileRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      color: blackColor,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: ProfileColumn(title: 'プロフィール')),
          Expanded(
              child: ProfileColumn(title: 'アカウント', color: profileColumnColor)),
          Expanded(child: ProfileColumn(title: 'コミュニティ')),
        ],
      ),
    );
  }
}

// 登録フォームを表示するウィジェット
class RegistrationForm extends StatelessWidget {
  final TextStyle titleStyle;
  final VoidCallback register;
  final VoidCallback goBack;

  const RegistrationForm({
    super.key,
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
          const SizedBox(height: 32),
          Text(
            '本アプリはユーザー同士でコミュニティを形成し、お得に商品をご利用いただくアプリです。',
            style: zenMaruGothicStyle.copyWith(
              fontSize: descriptionFontSize,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '初回利用時は新規登録者コミュニティに自動加入頂きます。',
            style: zenMaruGothicStyle.copyWith(fontSize: descriptionFontSize),
          ),
          const SizedBox(height: 16),
          Text(
            'ご自身でコミュニティを作る場合、探す場合は、コミュニティ画面より所属変更を行ってください。',
            style: zenMaruGothicStyle.copyWith(fontSize: descriptionFontSize),
          ),
          const SizedBox(height: 120),
          Row(
            children: [
              const Spacer(flex: 1),
              RegisterButton(register: register, goBack: goBack),
              const Spacer(flex: 9),
            ],
          ),
        ],
      ),
    );
  }
}

// プロフィールの列を表示するウィジェット
class ProfileColumn extends StatelessWidget {
  final String title;
  final Color color;

  const ProfileColumn(
      {super.key, required this.title, this.color = whiteColor});

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

// 登録ボタンを表示するウィジェット
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
              foregroundColor: whiteColor,
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
              foregroundColor: whiteColor,
              elevation: 5,
              side: BorderSide.none,
            ),
            child: Text(
              '登録する',
              style: zenMaruGothicStyle.copyWith(),
            ),
          ),
        ),
      ],
    );
  }
}
