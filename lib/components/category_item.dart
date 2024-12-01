import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bake_and_go_admin/errors/http_exception.dart';
import 'package:bake_and_go_admin/models/category.dart';
import 'package:bake_and_go_admin/models/category_list.dart';
import 'package:bake_and_go_admin/utils/app_routes.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.category});

  final ProductCategory category;

  @override
  Widget build(BuildContext context) {
    final msg = ScaffoldMessenger.of(context);
    return ListTile(
      // leading: CircleAvatar(backgroundImage: NetworkImage(product.imageUrl)),
      title: Text(category.name),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(AppRoutes.CATEGORY_FORM, arguments: category);
              },
              color: Theme.of(context).primaryColor,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      icon: const Icon(Icons.warning),
                      title: const Text('Atenção'),
                      content:
                          const Text('Deseja remover essa categoria da loja?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancelar'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: const Text('Excluir'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        )
                      ],
                    );
                  },
                ).then((value) async {
                  if (value ?? false) {
                    try {
                      await Provider.of<CategoryList>(context, listen: false)
                          .removeCategory(category);
                    } on HttpException catch (e) {
                      msg.showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                });
              },
              color: Theme.of(context).colorScheme.error,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
