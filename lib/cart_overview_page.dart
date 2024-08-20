import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';

class CartOverviewPage extends StatelessWidget {
  const CartOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注文を確定する'),
        backgroundColor: const Color(0xFFF6B352), // 上部バーの背景色をFigmaに合わせる
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: const Color(0xFF4C4C4C), // 背景色をFigmaに合わせる
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '注文を確定する',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20, // Figmaのフォントサイズに合わせる
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '注文数量: ${cart.totalQuantity}個',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '商品金額: ¥${cart.totalPrice}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Text(
                      '送料: ¥950',
                      style: TextStyle(color: Colors.white),
                    ),
                    const Divider(color: Colors.white),
                    Text(
                      '合計金額: ¥${cart.totalPrice + 950}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // 商品画像をFirestoreから取得したURLで表示
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                item.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '価格: ¥${item.price} 数量: ${item.quantity}',
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      cart.updateQuantity(
                                          item.productId, item.quantity - 1);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    cart.updateQuantity(
                                        item.productId, item.quantity + 1);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    cart.removeItem(item.productId);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // 購入ボタン押下時の処理
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6B352), // Figmaの色に合わせる
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: const Text('予約を確定する'),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF6B352), // Figmaの色に合わせる
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30.0),
            label: 'マイページ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, size: 30.0),
            label: 'コミュニティ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info, size: 30.0),
            label: 'お役立ち情報',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, size: 30.0),
            label: 'メッセージ',
          ),
        ],
        onTap: (index) {
          // BottomNavigationBar の選択に応じたルーティング処理
        },
      ),
    );
  }
}
