import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityModel with ChangeNotifier {
  String _communityName = '';
  String _communityDetails = '';
  String? _imagePath;

  String get communityName => _communityName;
  String get communityDetails => _communityDetails;
  String? get imagePath => _imagePath;

  Future<void> fetchCommunityDetails(String communityId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .get();

      if (doc.exists) {
        _communityName = doc['communityName'];
        _communityDetails = doc['communityDetails'];
        _imagePath = doc['imagePath'];
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching community details: $e');
    }
  }

  Future<void> updateCommunity(String communityId, String name, String details,
      String? imagePath) async {
    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .update({
        'communityName': name,
        'communityDetails': details, // フィールド名をFirestoreに合わせます
        'imagePath': imagePath,
      });

      _communityName = name;
      _communityDetails = details;
      _imagePath = imagePath;
      notifyListeners();
    } catch (e) {
      print('Error updating community: $e');
    }
  }
}
