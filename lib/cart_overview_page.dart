import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'widgets/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firebase_service.dart';
import 'package:go_router/go_router.dart';

class CartOverviewPage extends StatelessWidget {
  final String eventId;

  const CartOverviewPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return FutureBuilder<DocumentSnapshot>(
      future: firebaseService.getCommunityEvent(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('エラー'),
              backgroundColor: const Color(0xFFF6B352),
            ),
            body: const Center(
              child: Text('イベント情報を取得できませんでした。'),
            ),
          );
        }

        final eventData = snapshot.data!.data() as Map<String, dynamic>;
        final shippingCost = eventData['shippingCost'] ?? 950; // 送料を動的に取得

        return Scaffold(
          appBar: AppBar(
            title: const Text('注文を確定する'),
            backgroundColor: const Color(0xFFF6B352),
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
                    color: const Color(0xFF4C4C4C),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '注文を確定する',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
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
                        Text(
                          '送料: ¥$shippingCost', // 動的な送料を表示
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Divider(color: Colors.white),
                        Text(
                          '合計金額: ¥${cart.totalPrice + shippingCost}',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          cart.updateQuantity(item.productId,
                                              item.quantity - 1);
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
                      onPressed: () async {
                        final firebaseService = FirebaseService();
                        final userId = FirebaseAuth.instance.currentUser?.uid;

                        if (userId != null) {
                          await firebaseService
                              .incrementParticipantCount(eventId);

                          final updatedEvent =
                              await firebaseService.getCommunityEvent(eventId);
                          final updatedParticipants =
                              updatedEvent['participantCount'] ?? 1;
                          final updatedShippingCost = 950 / updatedParticipants;

                          await firebaseService.addCouponToUser(
                              userId, eventId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '送料は ¥${updatedShippingCost.round()} です')),
                          );

                          // 予約を確定する処理を追加
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF6B352),
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
          bottomNavigationBar: buildBottomNavigation(context),
        );
      },
    );
  }
}
