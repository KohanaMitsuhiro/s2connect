import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/community_model.dart';
import 'package:go_router/go_router.dart';
import 'services/firebase_service.dart';
import 'package:intl/intl.dart'; // この行を追加

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

  void _showEventCreationForm(BuildContext context) {
    final TextEditingController eventNameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    DateTime? eventDate;
    DateTime? orderDeadline;
    DateTime? shippingDate; // 配送日用変数
    bool isBulk = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('イベント生成'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: eventNameController,
                      decoration: const InputDecoration(
                        labelText: 'イベント名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: '配送場所',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('開催日を選択'),
                      subtitle: Text(eventDate == null
                          ? '未選択'
                          : DateFormat('yyyy-MM-dd').format(eventDate!)),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            eventDate = pickedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('注文締切日を選択'),
                      subtitle: Text(orderDeadline == null
                          ? '未選択'
                          : DateFormat('yyyy-MM-dd').format(orderDeadline!)),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            orderDeadline = pickedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('配送日を選択'),
                      subtitle: Text(shippingDate == null
                          ? '未選択'
                          : DateFormat('yyyy-MM-dd').format(shippingDate!)),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            shippingDate = pickedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("一括配送"),
                      value: isBulk,
                      onChanged: (bool value) {
                        setState(() {
                          isBulk = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_communityId != null) {
                      await Provider.of<FirebaseService>(context, listen: false)
                          .createCommunityEvent({
                        'eventName': eventNameController.text,
                        'communityId': _communityId,
                        'eventDate': eventDate?.toIso8601String(),
                        'location': locationController.text,
                        'isBulk': isBulk,
                        'participantCount': 0,
                        'shippingCost': 950, // 送料の初期値
                        'orderDeadline': orderDeadline?.toIso8601String(),
                        'shippingDate': shippingDate?.toIso8601String(), // 配送日
                      });

                      Navigator.of(context).pop(); // フォームを閉じる
                    } else {
                      print('Error: communityId is null, cannot create event');
                    }
                  },
                  child: const Text('生成'),
                ),
              ],
            );
          },
        );
      },
    );
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
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => _showEventCreationForm(context),
                  child: const Text('イベント生成'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
