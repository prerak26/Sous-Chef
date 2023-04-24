import 'dart:convert';

import 'package:flutter/material.dart';

import 'main.dart';

class RecipePage extends StatefulWidget {
  final int recipeId;
  const RecipePage({super.key, required this.recipeId});
  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  Future<Map<String, dynamic>> _fetchrecipe() async {
    final String apiUrl = '/recipe/${widget.recipeId}';
    final response = await currSession.get(apiUrl);
    if (response.statusCode == 200) {
      dynamic t = jsonDecode(response.body);

      print(t);
      return t;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _fetchrecipe(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text("${snapshot.data!['title']}"),
              ),
               
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
