import 'package:flutter/material.dart';

class CommunityModel with ChangeNotifier {
  String _communityName = '新規ユーザーコミュニティ1';
  String _communityDetails = '''
毎週日曜24:00に定期注文
4品から注文可能
同時購入する人数に応じてポイント付与
5ポイントで1品交換チケット入手
一括配送なら送料お得 ※プライベートコミュニティ限定
''';
  String? _imagePath;

  String get communityName => _communityName;
  String get communityDetails => _communityDetails;
  String? get imagePath => _imagePath;

  void updateCommunity(String name, String details, String? imagePath) {
    _communityName = name;
    _communityDetails = details;
    _imagePath = imagePath;
    notifyListeners();
  }
}
