import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/cart_item.dart';
import 'package:shop/models/order_list.dart';

import '../models/cart.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final Cart cart = Provider.of(context);
    final items = cart.items.values.toList();
    bool _isLoading = false;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Cart'),
        ),
        body: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Chip(
                      label: Text(
                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    const Spacer(),
                    _isLoading ? CircularProgressIndicator() : TextButton(
                      onPressed: cart.itemCount == 0
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              await Provider.of<OrderList>(
                                context,
                                listen: false,
                              ).addOrder(cart);
                              cart.clear();
                              setState(() => _isLoading = false);
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text('ORDER NOW'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    CartItemWidget(cartItem: items[index]),
              ),
            )
          ],
        ));
  }
}
