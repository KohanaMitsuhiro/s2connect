import 'package:flutter/foundation.dart';

class ProfileData extends ChangeNotifier {
  String? name;
  String? nickName;
  String? email;
  String? password;
  DateTime? dateOfBirth;

  void updateName(String newName) {
    name = newName;
    notifyListeners();
  }

  void updateNickName(String newName) {
    nickName = newName;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }

  void updatePassword(String newPassword) {
    password = newPassword;
    notifyListeners();
  }

  void updateDateOfBirth(DateTime newDateOfBirth) {
    dateOfBirth = newDateOfBirth;
    notifyListeners();
  }
}
