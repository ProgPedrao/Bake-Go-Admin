import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/auth.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/category_list.dart';
import 'package:shop/models/order_list.dart';
import 'package:shop/models/product_list.dart';
import 'package:shop/screens/auth_or_home_screen.dart';
import 'package:shop/screens/cart_screen.dart';
import 'package:shop/screens/category_form_screen.dart';
import 'package:shop/screens/category_screen.dart';
import 'package:shop/screens/checkout_screen.dart';
import 'package:shop/screens/orders_screen.dart';
import 'package:shop/screens/product_detail_screen.dart';
import 'package:shop/screens/product_form_screen.dart';
import 'package:shop/screens/product_screen.dart';
import 'package:shop/utils/app_routes.dart';
import 'package:shop/utils/custom_route.dart';

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
