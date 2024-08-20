import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  List<DocumentSnapshot> _products = [];
  final List<String> allergens = ['卵', '乳', '小麦', 'えび', 'かに', '落花生', 'そば', 'その他'];
  Map<String, bool> allergenSelection = {};

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    for (var allergen in allergens) {
      allergenSelection[allergen] = false;
    }
  }

  Future<void> _fetchProducts() async {
    final QuerySnapshot result = await _firestore.collection('products').get();
    setState(() {
      _products = result.docs;
    });
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _imageUrlController.text.isNotEmpty) {
      List<String> selectedAllergens = allergens.where((allergen) => allergenSelection[allergen]!).toList();
      try {
        await _firestore.collection('products').add({
          'name': _nameController.text,
          'price': int.parse(_priceController.text),
          'description': _descriptionController.text,
          'imageUrl': _imageUrlController.text,
          'allergens': selectedAllergens,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('商品が正常に追加されました')),
        );
        _fetchProducts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('商品を追加できませんでした: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('すべてのフィールドに入力してください')),
      );
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('商品が正常に削除されました')),
      );
      _fetchProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('商品を削除できませんでした: $e')),
      );
    }
  }

  Widget buildAllergenCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('アレルギー情報', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...allergens.map((allergen) {
          return CheckboxListTile(
            title: Text(allergen),
            value: allergenSelection[allergen],
            onChanged: (bool? newValue) {
              setState(() {
                allergenSelection[allergen] = newValue!;
              });
            },
          );
        }),
        Center(
          child: ElevatedButton(
            onPressed: _addProduct,
            child: const Text('商品を追加'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品登録ページ'),
        actions: [
          Row(
            children: [
              const Text('戻る'),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await _auth.signOut();
                  GoRouter.of(context).go('/');
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '商品名'),
                  ),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: '価格'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: '説明'),
                  ),
                  TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: '商品画像URL'),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: _addProduct,
                      child: const Text('商品を追加'),
                    ),
                  ),
                  buildAllergenCheckboxes(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '現在登録されている商品',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 300, // 商品リストのための適切な高さを設定
            child: _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final product = _products.removeAt(oldIndex);
          _products.insert(newIndex, product);
        });
      },
      children: _products.map((product) {
        final productId = product.id;
        final productData = product.data() as Map<String, dynamic>;

        return ListTile(
          key: ValueKey(productId),
          leading: ReorderableDragStartListener(
            index: _products.indexOf(product),
            child: const Icon(Icons.drag_handle),
          ),
          title: Text(productData['name']),
          subtitle: Text('価格: ¥${productData['price']}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteProduct(productId),
          ),
        );
      }).toList(),
    );
  }
}
