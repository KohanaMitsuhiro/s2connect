import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/community_model.dart';
import 'package:go_router/go_router.dart';

class CommunityDetailsPage extends StatefulWidget {
  const CommunityDetailsPage({super.key});

  @override
  _CommunityDetailsPageState createState() => _CommunityDetailsPageState();
}

class _CommunityDetailsPageState extends State<CommunityDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  XFile? _imageFile;
  String? _communityId;

  @override
  void initState() {
    super.initState();
    _fetchCommunityData();
  }

  Future<void> _fetchCommunityData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      _communityId = userDoc['communityId'];
      if (_communityId == null) {
        print('Error: communityId is null');
        return;
      }

      final communityModel =
          Provider.of<CommunityModel>(context, listen: false);
      await communityModel.fetchCommunityDetails(_communityId!);

      setState(() {
        _nameController.text = communityModel.communityName;
        _detailsController.text = communityModel.communityDetails;
      });
    } catch (e) {
      print('Error fetching community details: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コミュニティ詳細'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile == null
                    ? (Provider.of<CommunityModel>(context).imagePath == null
                        ? Image.asset(
                            'assets/images/S2.png',
                            width: 100,
                            height: 100,
                          )
                        : Image.file(
                            File(Provider.of<CommunityModel>(context)
                                .imagePath!),
                            width: 100,
                            height: 100,
                          ))
                    : Image.file(
                        File(_imageFile!.path),
                        width: 100,
                        height: 100,
                      ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'コミュニティ名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _detailsController,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'コミュニティ詳細',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    if (_communityId != null) {
                      Provider.of<CommunityModel>(context, listen: false)
                          .updateCommunity(
                        _communityId!,
                        _nameController.text,
                        _detailsController.text,
                        _imageFile?.path,
                      );
                      context.pop();
                    } else {
                      print(
                          'Error: communityId is null, cannot update community');
                    }
                  },
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
