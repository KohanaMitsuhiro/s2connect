import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart'; // カートモデルをインポート
import 'package:go_router/go_router.dart';

class FilteredProductsPage extends StatelessWidget {
  final String date;
  final List<String> allergens;

  const FilteredProductsPage(
      {super.key, required this.date, required this.allergens});

  Future<List<Map<String, dynamic>>> _fetchFilteredProducts() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot result = await firestore.collection('products').get();
      List<Map<String, dynamic>> products = result.docs.map((doc) {
        // FirestoreのドキュメントIDをproductIdとして追加
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['productId'] = doc.id;
        return data;
      }).toList();

      print('Fetched ${products.length} products from Firestore');
      if (allergens.isNotEmpty) {
        print('Selected allergens: $allergens');
        products = products.where((product) {
          List<dynamic> productAllergens = product['allergens'] ?? [];
          return !productAllergens
              .any((allergen) => allergens.contains(allergen));
        }).toList();
      }
      print('Filtered down to ${products.length} products');
      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$date 商品選択'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFilteredProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('商品が見つかりませんでした'));
          } else {
            List<Map<String, dynamic>> products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final productId = product['productId']; // ドキュメントIDを使用
                final name = product['name'] ?? 'Unknown Product';
                final price = product['price'] ?? 0;
                final imageUrl = product['imageUrl'] ??
                    'https://via.placeholder.com/150'; // imageUrlを取得

                return ListTile(
                  leading: Image.network(
                    imageUrl,
                    width: 80, // 幅を統一
                    height: 80, // 高さを統一
                    fit: BoxFit.cover, // 画像が枠に収まるようにする
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  ),
                  title: Text(name),
                  subtitle: Text('価格: ¥$price'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // 商品の詳細を取得し、カートに追加
                      Provider.of<CartModel>(context, listen: false).addItem(
                          productId, name, price, imageUrl, 1); // imageUrlを渡す
                    },
                    child: const Text('カートに追加'),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            // カートの中を見るページに遷移
            GoRouter.of(context).push('/cart_overview');
          },
          child: const Text('カートの中を見る'),
        ),
      ),
    );
  }
}
