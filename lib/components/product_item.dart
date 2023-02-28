import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/product_list.dart';
import '../utils/routes.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key, required this.product}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.PRODUCT_FORM,
                  arguments: product,
                );
              },
              icon: const Icon(Icons.edit),
              color: Theme.of(context).colorScheme.primary,
            ),
            IconButton(
              onPressed: () => onConfirmDelete(context),
              icon: const Icon(Icons.delete),
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }

  onConfirmDelete(BuildContext context) {
    final msg = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    ).then(
      (value) async {
        if (value ?? false) {
          try {
            await Provider.of<ProductList>(
              context,
              listen: false,
            ).removeProduct(product);
          } catch (e) {
            msg.showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          }
        }
      },
    );
  }
}
