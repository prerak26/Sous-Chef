import 'package:flutter/material.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/widgets.dart';

class ShoppingListView extends StatefulWidget {
  const ShoppingListView({super.key});
  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  @override
  Widget build(BuildContext context) {
    if (!session.isLogged) {
      return authorisationPage(context, "shopping-list");
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: const Text(
        'shoppping list',
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
