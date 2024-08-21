import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderPage extends StatefulWidget {
  final String date;

  const OrderPage({super.key, required this.date});

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
        title: Text('${widget.date} 商品選択'),
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
                    backgroundColor: Colors.orange,
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
                        'date': widget.date,
                        'allergens': selectedAllergens,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.white, // テキストの色を白に
                    fixedSize: const Size(140, 40), // ボタンのサイズを調整
                  ),
                  child: const Text('フィルター'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.orange,
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
          switch (index) {
            case 0:
              GoRouter.of(context).push('/mypage');
              break;
            case 1:
              GoRouter.of(context).push('/community');
              break;
            case 2:
              GoRouter.of(context).push('/info');
              break;
            case 3:
              GoRouter.of(context).push('/messages');
              break;
          }
        },
      ),
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
          color: isSelected ? Colors.orange : Colors.white,
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
