import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/auth.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/order_list.dart';
import 'package:shop/pages/auth_or_home.dart';
import 'package:shop/pages/cart_page.dart';
import 'package:shop/pages/orders_page.dart';
import 'package:shop/pages/product_detail_page.dart';
import 'package:shop/pages/product_form_page.dart';
import 'package:shop/pages/products_page.dart';
import 'package:shop/utils/custom_routes.dart';
import 'package:shop/utils/routes.dart';

import 'models/product_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductList>(
          create: (_) => ProductList(),
          update: (context, auth, previous) {
            return ProductList(
              auth.token ?? '',
              auth.uid ?? '',
              previous?.items ?? [],
            );
          },
        ),
        ChangeNotifierProxyProvider<Auth, OrderList>(
          create: (_) => OrderList(),
          update: (context, auth, previous) {
            return OrderList(
              auth.token ?? '',
              auth.uid ?? '',
              previous?.items ?? [],
            );
          },
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
      ],
      child: MaterialApp(
        theme: _theme(),
        routes: {
          AppRoutes.AUTH_OR_HOME: (_) => AuthOrHomePage(),
          AppRoutes.PRODUCT_DETAIL: (_) => ProductDetailPage(),
          AppRoutes.CART: (_) => CartPage(),
          AppRoutes.ORDERS: (_) => OrdersPage(),
          AppRoutes.PRODUCTS: (_) => ProductsPage(),
          AppRoutes.PRODUCT_FORM: (_) => ProductFormPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

ThemeData _theme() {
  return ThemeData(
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
    fontFamily: 'Lato',
    colorScheme: const ColorScheme.light(
      primary: Colors.purple,
      secondary: Colors.deepOrange,
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CustomPageTransitionsBuilder(),
        TargetPlatform.iOS: CustomPageTransitionsBuilder(),
      },
    ),
  );
}
