import 'package:flutter/material.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/widgets.dart';

class AuthShopPage extends StatefulWidget {
  const AuthShopPage({super.key});
  @override
  State<AuthShopPage> createState() => _AuthShopPageState();
}

class _AuthShopPageState extends State<AuthShopPage> {
  @override
  Widget build(BuildContext context) {
    if (session.isLogged) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AuthShop List'),
        ),
        body: const Text(
          'shoppping list',
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }
    return authorisationPage(context, "shopping-list");
  }
}
