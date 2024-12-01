import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/product_list.dart';
import 'package:shop/utils/app_routes.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({super.key, required this.cartItem});

  final CartItem cartItem;

  @override
  Widget build(BuildContext context) {
    
    final listProducts = Provider.of<ProductList>(context, listen: false).items;

    return Dismissible(
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false)
            .removeItem(cartItem.productId);
      },
      confirmDismiss: (direction) {
        return showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Tem certeza?"),
              content: const Text("Quer remover o item do carrinho?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: const Text("Não"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                  child: const Text("Sim"),
                ),
              ],
            ));
      },
      key: ValueKey(cartItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: FittedBox(
                child: Text("${cartItem.price}"),
              ),
            ),
          ),
          title: Text(cartItem.name),
          subtitle: Text("Total: R\$ ${(cartItem.price * cartItem.quantity).toDouble().toStringAsFixed(2)}"),
          trailing: Text("${cartItem.quantity}x"),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.PRODUCT_DETAIL, 
              arguments: listProducts.firstWhere((element) => element.id == cartItem.productId,)
            );
          },
        ),
      ),
    );
  }
}
