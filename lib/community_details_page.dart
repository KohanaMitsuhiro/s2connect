import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // 追加
import 'package:provider/provider.dart';
import 'models/community_model.dart'; // 追加
import 'package:go_router/go_router.dart'; // 追加

class CommunityDetailsPage extends StatefulWidget {
  const CommunityDetailsPage({super.key});

  @override
  _CommunityDetailsPageState createState() => _CommunityDetailsPageState();
}

class _CommunityDetailsPageState extends State<CommunityDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    final community = Provider.of<CommunityModel>(context, listen: false);
    _nameController.text = community.communityName;
    _detailsController.text = community.communityDetails;
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
            context.pop(); // GoRouterのpopメソッドを使用
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
                    Provider.of<CommunityModel>(context, listen: false)
                        .updateCommunity(
                      _nameController.text,
                      _detailsController.text,
                      _imageFile?.path,
                    );
                    context.pop(); // GoRouterのpopメソッドを使用
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
