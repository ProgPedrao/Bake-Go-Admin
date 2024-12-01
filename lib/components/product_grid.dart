import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bake_and_go_admin/components/product_grid_item.dart';
import 'package:bake_and_go_admin/screens/products_overview.dart';

import '../models/product.dart';
import '../models/product_list.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.showFavoriteOnly,
    required this.selectedCategory,
  });

  final FilterOptions showFavoriteOnly;
  final String selectedCategory;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductList>(context);
    
    late final List<Product> loadedProducts;
    late final String messageNotFound;
    
    if (showFavoriteOnly == FilterOptions.All) {
      loadedProducts = provider.items;
      messageNotFound = 'Nenhum produto disponível no momento!';
    } else if (showFavoriteOnly == FilterOptions.Favorite) {
      loadedProducts = provider.favoriteItems;
      messageNotFound = 'Nenhum produto favorito encontrado!';
    } else {
      loadedProducts = provider.categoryItems(selectedCategory);
      messageNotFound = 'Nenhum produto com essa categoria disponível!';
    }
    


    if (loadedProducts.isEmpty) {
      return Center(
        child: Text(
          messageNotFound,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: loadedProducts.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: loadedProducts[index],
        child: const ProductGridItem(),
      ),
    );
  }
}
