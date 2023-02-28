import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/routes.dart';

import '../models/auth.dart';
import '../models/cart.dart';

class ProductGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final auth = Provider.of<Auth>(context, listen: false);

    return Consumer<Product>(
      builder: (ctx, product, _) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: IconButton(
              icon: product.isFavorite
                  ? const Icon(Icons.favorite)
                  : const Icon(Icons.favorite_border),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                product.toggleFavoriteStatus(auth.token ?? '', auth.uid ?? '');
              },
            ),
            title: Text(product.name),
            trailing: IconButton(
              icon: const Icon(Icons.shopping_cart),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                cart.addItem(product);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Added item to cart!'),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.PRODUCT_DETAIL,
                arguments: product,
              );
            },
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder: const AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
