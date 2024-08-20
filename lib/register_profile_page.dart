import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'styles.dart';
import 'profile_data.dart';

class RegisterProfilePage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  RegisterProfilePage({super.key});

  void _register(BuildContext context) {
    if (_emailController.text.isEmpty) {
      _showDialog(context, 'エラー', '名前を入力してください。');
      return;
    }

    Provider.of<ProfileData>(context, listen: false)
        .updateName(_emailController.text);

    GoRouter.of(context).go('/registerAccount');
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
        fontSize: 24.0,
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
                emailController: _emailController,
                titleStyle: titleStyle,
                register: () => _register(context)),
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
          Expanded(
              child: ProfileColumn(title: 'プロフィール', color: Color(0xFFF68655))),
          Expanded(child: ProfileColumn(title: 'アカウント')),
          Expanded(child: ProfileColumn(title: 'コミュニティ')),
        ],
      ),
    );
  }
}

class RegistrationForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextStyle titleStyle;
  final VoidCallback register;

  const RegistrationForm({
    super.key,
    required this.emailController,
    required this.titleStyle,
    required this.register,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Text('プロフィール', style: titleStyle),
          const SizedBox(height: 16.0),
          CustomTextField(
              controller: emailController, labelText: 'Name', hintText: '横山 彩'),
          CustomDateOfBirthPicker(
            onDateSelected: (selectedDate) {
              Provider.of<ProfileData>(context, listen: false)
                  .updateDateOfBirth(selectedDate);
            },
          ),
          const SizedBox(height: 162),
          Row(
            children: [
              const Spacer(flex: 6),
              RegisterButton(register: register),
              const Spacer(flex: 1),
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
    super.key,
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

  const RegisterButton({super.key, required this.register});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}

class CustomDateOfBirthPicker extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;

  const CustomDateOfBirthPicker({super.key, required this.onDateSelected});

  @override
  CustomDateOfBirthPickerState createState() => CustomDateOfBirthPickerState();
}

class CustomDateOfBirthPickerState extends State<CustomDateOfBirthPicker> {
  DateTime selectedDate = DateTime.now();

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDateSelected(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: CustomTextField(
          controller: TextEditingController(
              text: "${selectedDate.toLocal()}".split(' ')[0]),
          labelText: '生年月日',
          hintText: 'YYYY/MM/DD',
        ),
      ),
    );
  }
}
