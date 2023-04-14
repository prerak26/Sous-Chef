import 'package:flutter/material.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/home.dart';

class RecipePage extends StatefulWidget {
  final int recipeid;
  const RecipePage({required this.recipeid, super.key});
  @override
  State<RecipePage> createState() => _RecipePageState(recipeid: recipeid);
}

class _RecipePageState extends State<RecipePage> {
  final int recipeid;
  _RecipePageState({required this.recipeid});
  @override
  Widget build(BuildContext context) {
    if (session.isLogged) {
      return const HomeView();
    }
    return Scaffold(
        appBar: AppBar(title: Text('$recipeid')), body: Text('$recipeid'));
  }
}
