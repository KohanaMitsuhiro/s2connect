import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedAllergen;
  final Map<String, int> _selectedQuantities = {};

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    List<Map<String, dynamic>> products = [];
    QuerySnapshot result;

    if (_selectedAllergen != null && _selectedAllergen!.isNotEmpty) {
      result = await _firestore
          .collection('products')
          .where('allergens', arrayContains: _selectedAllergen)
          .get();
    } else {
      result = await _firestore.collection('products').get();
    }

    for (var document in result.docs) {
      final Map<String, dynamic> productData =
          document.data() as Map<String, dynamic>;
      productData['id'] = document.id;
      products.add(productData);
    }

    return products;
  }

  void _clearFilter() {
    setState(() {
      _selectedAllergen = null;
    });
  }

  void _addToCart(
      String productId, String name, int price, String imageUrl, int quantity) {
    Provider.of<CartModel>(context, listen: false)
        .addItem(productId, name, price, imageUrl, quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('商品がカートに追加されました。数量: $quantity')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品一覧'),
        actions: [
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      GoRouter.of(context).go('/cart');
                    },
                  ),
                  if (cart.totalQuantity > 0)
                    Positioned(
                      right: 7,
                      top: 7,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${cart.totalQuantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10, // フォントサイズを小さくする
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Row(
            children: [
              const Text(
                'ログアウト',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await _auth.signOut();
                  GoRouter.of(context).go('/');
                },
              ),
              const SizedBox(width: 8), // アイコンと右端の間にスペースを追加
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アレルギー情報で検索する',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        hint: const Text('アレルギー情報を選択'),
                        value: _selectedAllergen,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedAllergen = newValue;
                          });
                        },
                        items: <String>[
                          '卵',
                          '乳',
                          '小麦',
                          'えび',
                          'かに',
                          '落花生',
                          'そば',
                          'その他'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearFilter,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('エラー: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('商品が見つかりませんでした'));
                } else {
                  final products = snapshot.data!;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75, // カードの縦横比を調整
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final imageUrl = product['imageUrl'] ?? '';
                      final productId = product['id'];
                      final name = product['name'];
                      final price = product['price'];
                      _selectedQuantities[productId] =
                          _selectedQuantities[productId] ?? 1;

                      return Card(
                        child: Column(
                          children: [
                            Expanded(
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                            size: 64,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 64,
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('価格: ¥$price'),
                                  Text(product['description']),
                                  Text(
                                      'アレルギー情報: ${product['allergens'].join(', ')}'),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      DropdownButton<int>(
                                        value: _selectedQuantities[productId],
                                        onChanged: (int? newValue) {
                                          setState(() {
                                            _selectedQuantities[productId] =
                                                newValue!;
                                          });
                                        },
                                        items: <int>[1, 2, 3]
                                            .map<DropdownMenuItem<int>>(
                                                (int value) {
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(value.toString()),
                                          );
                                        }).toList(),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => _addToCart(
                                            productId,
                                            name,
                                            price,
                                            imageUrl,
                                            _selectedQuantities[productId]!),
                                        child: const Text('カートに追加'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
