import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bake_and_go_admin/components/app_drawer.dart';
import 'package:bake_and_go_admin/components/category_item.dart';
import 'package:bake_and_go_admin/models/category_list.dart';
import 'package:bake_and_go_admin/utils/app_routes.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Future<void> _refreshCategories(BuildContext context){
    return Provider.of<CategoryList>(context, listen: false).loadCategories();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _refreshCategories(context);
  }

  @override
  Widget build(BuildContext context) {
    final CategoryList categories = Provider.of<CategoryList>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Categorias"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.CATEGORY_FORM);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshCategories(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Column(
                children: [
                  CategoryItem(
                    category: categories.items[index],
                  ),
                  const Divider(),
                ],
              );
            },
            itemCount: categories.itemsCount,
          ),
        ),
      ),
    );
  }
}
