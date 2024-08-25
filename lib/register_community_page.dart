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

class RegisterCommunityPage extends StatefulWidget {
  const RegisterCommunityPage({super.key});

  static const String reservationsRoute = '/reservations';
  static const String registerAccountRoute = '/registerAccount';

  @override
  _RegisterCommunityPageState createState() => _RegisterCommunityPageState();
}

class _RegisterCommunityPageState extends State<RegisterCommunityPage> {
  final TextEditingController _inviteCodeController = TextEditingController();

  void _register(BuildContext context) async {
    final profileData = Provider.of<ProfileData>(context, listen: false);
    final firebaseService = FirebaseService();

    print('名前: ${profileData.name}');
    print('ニックネーム: ${profileData.nickName}');
    print('メールアドレス: ${profileData.email}');
    print('パスワード: ${profileData.password}');
    print('生年月日: ${profileData.dateOfBirth}');
    print('招待コード: ${_inviteCodeController.text}');

    try {
      if (profileData.name == null ||
          profileData.nickName == null ||
          profileData.email == null ||
          profileData.password == null ||
          profileData.dateOfBirth == null) {
        _showErrorDialog(context, 'すべての必須情報を入力してください。');
        return;
      }

      // コミュニティIDを決定
      String communityId = 'community1'; // デフォルトのコミュニティID
      if (_inviteCodeController.text.isNotEmpty) {
        // 招待コードからコミュニティIDを取得
        String? foundCommunityId = await firebaseService
            .getCommunityIdByInviteCode(_inviteCodeController.text);

        if (foundCommunityId == null) {
          _showErrorDialog(context, '招待コードが無効です。');
          return;
        }

        communityId = foundCommunityId; // 有効な招待コードがあればそのコミュニティIDを使用
      }

      // FirebaseServiceを使ってFirebase AuthenticationとFirestoreへの書き込みを行う
      await firebaseService.createUserProfile(
        name: profileData.name!,
        nickName: profileData.nickName!,
        email: profileData.email!,
        password: profileData.password!,
        dateOfBirth: profileData.dateOfBirth!,
        communityId: communityId, // コミュニティIDを渡す
        coupons: [], // クーポンリストは空リストで初期化
      );

      // コミュニティのメンバー数を増やす
      await firebaseService.updateCommunityMemberCount(communityId,
          increment: 1);

      // 次の画面に遷移
      GoRouter.of(context).go(RegisterCommunityPage.reservationsRoute);
    } catch (e) {
      print('エラーが発生しました: $e');
      _showErrorDialog(context, 'ユーザー登録中にエラーが発生しました: ${e.toString()}');
    }
  }

  void _goBack(BuildContext context) {
    GoRouter.of(context).go(RegisterCommunityPage.registerAccountRoute);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('コミュニティ', style: titleStyle),
                const SizedBox(height: 16.0),
                Text(
                  '本アプリは旬をすぐにお得にご利用するため、ユーザー同士でコミュニティを形成して頂きます。'
                  '\n\n招待コードをお持ちの場合はご入力お願い致します。入力無い場合は新規ユーザー用コミュニティに自動招待致します。',
                  style: zenMaruGothicStyle.copyWith(fontSize: 14.0),
                ),
                const SizedBox(height: 32.0),
                TextField(
                  controller: _inviteCodeController,
                  decoration: const InputDecoration(
                    labelText: '招待コード',
                    hintText: '※お持ちの場合のみ',
                  ),
                ),
                const SizedBox(height: 120),
                Row(
                  children: [
                    const Spacer(flex: 1),
                    RegisterButton(
                        register: () => _register(context),
                        goBack: () => _goBack(context)),
                    const Spacer(flex: 9),
                  ],
                ),
              ],
            ),
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
          Expanded(child: ProfileColumn(title: 'アカウント')),
          Expanded(
            child: ProfileColumn(
                title: 'コミュニティ', color: profileColumnColor), // コミュニティが赤になるように設定
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
              '次へ',
              style: zenMaruGothicStyle.copyWith(),
            ),
          ),
        ),
      ],
    );
  }
}
