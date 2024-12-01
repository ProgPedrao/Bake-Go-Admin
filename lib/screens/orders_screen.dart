import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/order_widget.dart';
import 'package:shop/models/order_list.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Carrinho"),
      ),
      body: FutureBuilder(
        future: Provider.of<OrderList>(context, listen: false).loadOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return Center(
              child: Text("Ocorreu um erro ao processar a requisição"),
            );
          } else {
            return Consumer<OrderList>(
              builder: (context, orders, child) => ListView.builder(
                  itemCount: orders.itemsCount,
                  itemBuilder: (context, index) =>
                      OrderWidget(order: orders.items[index])),
            );
          }
        },
      ),
      drawer: const AppDrawer(),
    );
  }
}
