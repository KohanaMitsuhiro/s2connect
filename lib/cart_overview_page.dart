import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'widgets/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firebase_service.dart';

class CartOverviewPage extends StatefulWidget {
  final String eventId;

  const CartOverviewPage({super.key, required this.eventId});

  @override
  _CartOverviewPageState createState() => _CartOverviewPageState();
}

class _CartOverviewPageState extends State<CartOverviewPage> {
  bool _isReservationConfirmed = false;

  @override
  Widget build(BuildContext context) {
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
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      '商品金額: ¥${cart.totalPrice}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('community_events')
                          .doc(widget.eventId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final eventData = snapshot.data!.data() as Map<String, dynamic>?;
                          if (eventData != null) {
                            final participantCount = eventData['participantCount'] ?? 1;
                            final shippingCost = eventData['shippingCost'] ?? 950;
                            // participantCountが0の場合は1として処理
                            final safeParticipantCount = participantCount > 0 ? participantCount : 1;
                            final updatedShippingCost = (shippingCost / safeParticipantCount).round();
                            return Text(
                              '送料: ¥$updatedShippingCost',
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            );
                          }
                        }
                        return const Text(
                          '送料: 計算中...',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        );
                      },
                    ),
                    const Divider(color: Colors.white),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('community_events')
                          .doc(widget.eventId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final eventData = snapshot.data!.data() as Map<String, dynamic>?;
                          if (eventData != null) {
                            final participantCount = eventData['participantCount'] ?? 1;
                            final shippingCost = eventData['shippingCost'] ?? 950;
                            // participantCountが0の場合は1として処理
                            final safeParticipantCount = participantCount > 0 ? participantCount : 1;
                            final updatedShippingCost = (shippingCost / safeParticipantCount).round();
                            return Text(
                              '合計金額: ¥${cart.totalPrice + updatedShippingCost}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            );
                          }
                        }
                        return const Text(
                          '合計金額: 計算中...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        );
                      },
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
                    final userId = FirebaseAuth.instance.currentUser?.uid;

                    if (userId != null) {
                      final firebaseService = FirebaseService();
                      // incrementParticipantCountを呼び出して、クーポンIDを取得
                      String? couponId = await firebaseService
                          .incrementParticipantCount(widget.eventId, userId);

                      // 取得したクーポンIDを使って、ユーザーにクーポンを追加
                      if (couponId != null) {
                        await firebaseService.addCouponToUser(userId, couponId);

                        // 送料を再計算して表示
                        final updatedEvent = await firebaseService
                            .getCommunityEvent(widget.eventId);
                        final updatedEventData = updatedEvent.data() as Map<String, dynamic>?;
                        if (updatedEventData != null) {
                          final updatedParticipants =
                              updatedEventData['participantCount'] ?? 1;
                          final updatedShippingCost =
                              (updatedEventData['shippingCost'] ?? 950) / (updatedParticipants > 0 ? updatedParticipants : 1);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('送料は ¥${updatedShippingCost.round()} です'),
                              backgroundColor: Colors.black.withOpacity(0.4), // 背景色を黒にして透けさせる
                            ),
                          );
                        }
                      }

                      // 予約を確定する処理を追加
                      setState(() {
                        _isReservationConfirmed = true;
                      });
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
              if (_isReservationConfirmed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil(ModalRoute.withName('/reservations'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    child: const Text('予約状況に戻る'),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }
}
