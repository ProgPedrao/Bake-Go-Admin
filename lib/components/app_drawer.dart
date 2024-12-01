import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bake_and_go_admin/models/auth.dart';
import 'package:bake_and_go_admin/screens/orders_screen.dart';
import 'package:bake_and_go_admin/utils/app_routes.dart';
import 'package:bake_and_go_admin/utils/custom_route.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text("Bem vindo!"),
            automaticallyImplyLeading: false,
          ),
          const SizedBox(height: 10),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Pedidos"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.ORDERS);

              // Navigator.of(context).pushReplacement(CustomRoute(
              //   builder: (context) => OrdersScreen(),
              // ));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.category_rounded),
            title: const Text("Categoria"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.CATEGORY);

              // Navigator.of(context).pushReplacement(CustomRoute(
              //   builder: (context) => OrdersScreen(),
              // ));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Gerenciar Produtos"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.PRODUCTS);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Sair"),
            onTap: () {
              Provider.of<Auth>(context, listen: false).logout();
              Navigator.of(context)
                  .pushReplacementNamed(AppRoutes.AUTH_OR_HOME);
            },
          ),
        ],
      ),
    );
  }
}
