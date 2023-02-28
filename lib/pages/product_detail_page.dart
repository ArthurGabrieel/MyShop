import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Product product =
        ModalRoute.of(context)!.settings.arguments as Product;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(product.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: product.id,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0, 0.5),
                        end: Alignment(0, 0),
                        colors: [
                          Color(0x60000000),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 10),
              Text(
                '\$${product.price}',
                style: const TextStyle(color: Colors.grey, fontSize: 20),
              ),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(product.description),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
