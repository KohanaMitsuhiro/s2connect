import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'welcome_page.dart';
import 'register_profile_page.dart';
import 'register_account_page.dart';
import 'register_community_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'product_list_page.dart';
import 'admin_page.dart';
import 'profile_data.dart';
import 'cart_page.dart';
import 'cart_model.dart';
import 'reservations_page.dart';
import 'order_page.dart';
import 'filtered_products_page.dart';
import 'models/community_model.dart';
import 'community_details_page.dart';
import 'cart_overview_page.dart';
import 'services/firebase_service.dart';
import 'mypage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebaseの初期化中にエラーが発生しました: $e');
    return;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => WelcomePage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterPage()),
        GoRoute(
            path: '/registerProfile',
            builder: (context, state) => RegisterProfilePage()),
        GoRoute(
            path: '/registerAccount',
            builder: (context, state) => RegisterAccountPage()),
        GoRoute(
            path: '/registerCommunity',
            builder: (context, state) => const RegisterCommunityPage()),
        GoRoute(
            path: '/products',
            builder: (context, state) => const ProductListPage()),
        GoRoute(path: '/admin', builder: (context, state) => const AdminPage()),
        GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
        GoRoute(
            path: '/reservations',
            builder: (context, state) => const ReservationsPage()),
        GoRoute(
          path: '/order',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;

            if (extra != null) {
              final parsedDate =
                  DateTime.tryParse(extra['date']?.toString() ?? '');
              final eventId = extra['eventId'] as String?;
              if (parsedDate != null && eventId != null) {
                return OrderPage(date: parsedDate, eventId: eventId);
              } else {
                return OrderPage(
                    date: DateTime.now(),
                    eventId: eventId ?? ''); // デフォルト日付と空のイベントID
              }
            } else {
              throw ArgumentError('Invalid extra data passed to OrderPage');
            }
          },
        ),
        GoRoute(
          path: '/filtered_products',
          builder: (context, state) {
            final Map<String, dynamic> extra =
                state.extra as Map<String, dynamic>;
            return FilteredProductsPage(
              date: extra['date'] as String,
              allergens: extra['allergens'] as List<String>,
              eventId: extra['eventId'] as String, // eventIdを追加
            );
          },
        ),
        GoRoute(
            path: '/community_details',
            builder: (context, state) => const CommunityDetailsPage()),
        GoRoute(
            path: '/cart_overview',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;

              if (extra != null && extra.containsKey('eventId')) {
                final eventId = extra['eventId'] as String;
                return CartOverviewPage(eventId: eventId);
              } else {
                return const CartOverviewPage(eventId: '');
              }
            }),
        GoRoute(
            path: '/mypage',
            builder: (context, state) => MyPage()), // マイページのルートを追加
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => CommunityModel()),
        ChangeNotifierProvider(create: (_) => ProfileData()),
        Provider<FirebaseService>(
            create: (_) => FirebaseService()), // FirebaseServiceを追加
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }
}
