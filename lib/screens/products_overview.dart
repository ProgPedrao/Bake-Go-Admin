// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bake_and_go_admin/components/app_drawer.dart';
import 'package:bake_and_go_admin/components/badge_cart.dart';
import 'package:bake_and_go_admin/components/product_grid.dart';
import 'package:bake_and_go_admin/models/cart.dart';
import 'package:bake_and_go_admin/models/category_list.dart';
import 'package:bake_and_go_admin/models/product_list.dart';
import 'package:bake_and_go_admin/utils/app_routes.dart';

enum FilterOptions {
  Favorite,
  All,
  Category,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  String selectedCategory = "";
  FilterOptions _showFavoriteOnly = FilterOptions.All;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _isLoading = true;
    });

    Provider.of<CategoryList>(context, listen: false).loadCategories();

    Provider.of<ProductList>(context, listen: false)
        .loadProducts()
        .then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<ProductList>(context);
    final categories = Provider.of<CategoryList>(context).items;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Minha Loja"),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: FilterOptions.Favorite,
                child: Text(
                  'Somente Favoritos',
                ),
              ),
              const PopupMenuItem(
                value: FilterOptions.All,
                child: Text(
                  'Todos',
                ),
              ),
              ...categories.map(
                (category) => PopupMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
            onSelected: (value) {
              setState(() {
                // if (value == FilterOptions.All) {
                //   _showFavoriteOnly = true;
                // } else if(value == FilterOptions.Favorite) {
                //   _showFavoriteOnly = false;
                // }
                // } else {
                //   _showFavoriteOnly = false;
                // }
                if (!(value == FilterOptions.All || value == FilterOptions.Favorite)) {
                  selectedCategory = value.toString();
                  value = FilterOptions.Category;
                }

                _showFavoriteOnly = value as FilterOptions;

              });
              // if (value == FilterOptions.All) {
              //   provider.showAllOnly();
              // } else {
              //   provider.showFavoriteOnly();
              // }
            },
          ),
          Consumer<Cart>(
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.CART);
              },
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
            ),
            builder: (context, value, child) => BadgeCart(
              value: value.itemsCount.toString(),
              child: child!,
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(
              showFavoriteOnly: _showFavoriteOnly,
              selectedCategory: selectedCategory,
            ),
      drawer: const AppDrawer(),
    );
  }
}
