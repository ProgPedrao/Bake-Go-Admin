import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bake_and_go_admin/components/app_drawer.dart';
import 'package:bake_and_go_admin/components/product_item.dart';
import 'package:bake_and_go_admin/models/product_list.dart';
import 'package:bake_and_go_admin/utils/app_routes.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Future<void> _refreshProducts(BuildContext context){
    return Provider.of<ProductList>(context, listen: false).loadProducts();
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _refreshProducts(context);
  }

  @override
  Widget build(BuildContext context) {
    final ProductList products = Provider.of<ProductList>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Produtos"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.PRODUCT_FORM);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ProductItem(
                    product: products.items[index],
                  ),
                  const Divider(),
                ],
              );
            },
            itemCount: products.itemsCount,
          ),
        ),
      ),
    );
  }
}
