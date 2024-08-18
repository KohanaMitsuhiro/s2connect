import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'product_list_page.dart';
import 'admin_page.dart';
import 'cart_page.dart';
import 'cart_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => LoginPage()),
        GoRoute(path: '/products', builder: (context, state) => ProductListPage()),
        GoRoute(path: '/admin', builder: (context, state) => AdminPage()),
        GoRoute(path: '/cart', builder: (context, state) => CartPage()),
      ],
    );

    return ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: MaterialApp.router(
        routerConfig: _router,
      ),
    );
  }
}
