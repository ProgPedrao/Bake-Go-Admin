import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bake_and_go_admin/models/auth.dart';
import 'package:bake_and_go_admin/models/cart.dart';
import 'package:bake_and_go_admin/models/category_list.dart';
import 'package:bake_and_go_admin/models/order_list.dart';
import 'package:bake_and_go_admin/models/product_list.dart';
import 'package:bake_and_go_admin/screens/auth_or_home_screen.dart';
import 'package:bake_and_go_admin/screens/cart_screen.dart';
import 'package:bake_and_go_admin/screens/category_form_screen.dart';
import 'package:bake_and_go_admin/screens/category_screen.dart';
import 'package:bake_and_go_admin/screens/checkout_screen.dart';
import 'package:bake_and_go_admin/screens/orders_screen.dart';
import 'package:bake_and_go_admin/screens/product_detail_screen.dart';
import 'package:bake_and_go_admin/screens/product_form_screen.dart';
import 'package:bake_and_go_admin/screens/product_screen.dart';
import 'package:bake_and_go_admin/utils/app_routes.dart';
import 'package:bake_and_go_admin/utils/custom_route.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductList>(
          create: (context) => ProductList(),
          update: (context, auth, previous) {
            return (ProductList(
              auth.token ?? '',
              auth.userId ?? '',
              previous?.items ?? [],
            ));
          },
        ),
        ChangeNotifierProxyProvider<Auth, CategoryList>(
          create: (context) => CategoryList(),
          update: (context, auth, previous) {
            return (CategoryList(
              auth.token ?? '',
              previous?.items ?? [],
            ));
          },
        ),
        ChangeNotifierProxyProvider<Auth, OrderList>(
          create: (context) => OrderList(),
          update: (context, auth, previous) {
            return OrderList(
              auth.token ?? '',
              auth.userId ?? '',
              previous?.items ?? [],
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
        // CounterProvider(
        // child:
        MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
        fontFamily: 'Lato',
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: CustomTransitionBuilder(),
            TargetPlatform.android: CustomTransitionBuilder(),
          }
        )
      ),
      // home: const ProductsOverviewScreen(),
      routes: {
        AppRoutes.AUTH_OR_HOME: (context) => const AuthOrHomeScreen(),
        AppRoutes.PRODUCT_DETAIL: (context) => const ProductDetailScreen(),
        AppRoutes.CART: (context) => const CartScreen(),
        AppRoutes.ORDERS: (context) => const OrdersScreen(),
        AppRoutes.PRODUCTS: (context) => const ProductScreen(),
        AppRoutes.PRODUCT_FORM: (context) => const ProductFormScreen(),
        // AppRoutes.PRODUCT_DETAIL: (context) => CounterScreen()
        AppRoutes.CHECKOUT: (context) => const CheckoutScreen(),
        AppRoutes.CATEGORY: (context) => const CategoryScreen(),
        AppRoutes.CATEGORY_FORM: (context) => const CategoryFormScreen(),
      },
      debugShowCheckedModeBanner: false,
      // ),
    );
  }
}
