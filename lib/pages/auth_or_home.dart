import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/pages/products_overview_page.dart';

import '../models/auth.dart';
import 'auth_page.dart';

class AuthOrHomePage extends StatelessWidget {
  const AuthOrHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of(context);
    // return auth.isAuth ? ProductsOverviewPage() : const AuthPage();
    return FutureBuilder(
      future: auth.tryAutoLogin(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.error != null) {
            return const Scaffold(
              body: Center(
                child: Text('An error occurred!'),
              ),
            );
          } else {
            return auth.isAuth ? ProductsOverviewPage() : const AuthPage();
          }
        }
      },
    );
  }
}
