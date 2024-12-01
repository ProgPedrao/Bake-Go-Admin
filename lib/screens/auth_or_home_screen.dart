import 'package:bake_and_go_admin/screens/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bake_and_go_admin/models/auth.dart';
import 'package:bake_and_go_admin/screens/auth_screen.dart';
import 'package:bake_and_go_admin/screens/products_overview.dart';

class AuthOrHomeScreen extends StatelessWidget {
  const AuthOrHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of(context);
    // return auth.isAuth ? const ProductsOverviewScreen() : const AuthScreen();
    return FutureBuilder(
      future: auth.tryAutoLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.error != null) {
          return const Center(
            child: Text('Ocorreu um erro!'),
          );
        } else {
          return auth.isAuth
              ? const OrdersScreen()
              : const AuthScreen();
        }
      },
    );
  }
}
