import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/navigation.dart'; // 共通ナビゲーションのインポート

class OrderPage extends StatefulWidget {
  final DateTime date;
  final String eventId; // イベントIDを追加

  const OrderPage(
      {super.key, required this.date, required this.eventId}); // eventIdを追加

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<String> selectedAllergens = [];

  void _toggleAllergen(String allergen) {
    setState(() {
      if (selectedAllergens.contains(allergen)) {
        selectedAllergens.remove(allergen);
      } else {
        selectedAllergens.add(allergen);
      }
    });
  }

  void _clearAllergens() {
    setState(() {
      selectedAllergens.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.date.toLocal().toString().split(' ')[0]} 商品選択'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  _buildAllergenButton('卵'),
                  _buildAllergenButton('小麦'),
                  _buildAllergenButton('乳'),
                  _buildAllergenButton('そば'),
                  _buildAllergenButton('えび'),
                  _buildAllergenButton('かに'),
                  _buildAllergenButton('落花生'),
                  _buildAllergenButton('魚'),
                  _buildAllergenButton('牛肉'),
                  _buildAllergenButton('豚肉'),
                  _buildAllergenButton('鶏肉'),
                  _buildAllergenButton('ごま'),
                  _buildAllergenButton('カシューナッツ'),
                  _buildAllergenButton('いか'),
                  _buildAllergenButton('やまいも'),
                  _buildAllergenButton('オレンジ'),
                  _buildAllergenButton('あわび'),
                  _buildAllergenButton('バナナ'),
                  _buildAllergenButton('りんご'),
                  _buildAllergenButton('くるみ'),
                  _buildAllergenButton('まつたけ'),
                  _buildAllergenButton('ゼラチン'),
                  _buildAllergenButton('アーモンド'),
                  _buildAllergenButton('はちみつ'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _clearAllergens,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6B352),
                    disabledBackgroundColor: Colors.white, // テキストの色を白に
                    fixedSize: const Size(140, 40), // ボタンのサイズを調整
                  ),
                  child: const Text('すべてクリア'),
                ),
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).push(
                      '/filtered_products',
                      extra: {
                        'date': widget.date.toIso8601String(),
                        'allergens': selectedAllergens,
                        'eventId': widget.eventId, // イベントIDも一緒に渡す
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6B352),
                    disabledBackgroundColor: Colors.white,
                    fixedSize: const Size(140, 40),
                  ),
                  child: const Text('フィルター'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigation(context), // ここで使用
    );
  }

  Widget _buildAllergenButton(String allergen) {
    final isSelected = selectedAllergens.contains(allergen);
    return GestureDetector(
      onTap: () => _toggleAllergen(allergen),
      child: Container(
        width: 90, // ボタンの幅を少し小さく調整
        height: 50, // ボタンの高さを少し小さく調整
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF6B352) : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  allergen,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 12, // フォントサイズを小さく調整
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16, // アイコンサイズを小さく調整
                ),
            ],
          ),
        ),
      ),
    );
  }
}
