import 'dart:convert';

import 'package:flutter/material.dart';

import 'main.dart';

class RecipeView extends StatefulWidget {
  final String recipeId;
  const RecipeView({super.key, required this.recipeId});
  @override
  State<RecipeView> createState() => _RecipeViewState();
}



class _RecipeViewState extends State<RecipeView> {
  
  Future<dynamic> _fetchrecipe() async {
    
    final String apiUrl = '/recipe/:id?id=${widget.recipeId}';
    final response = await currSession.get(apiUrl);
    if (response.statusCode == 200) {
      List<dynamic> t = jsonDecode(response.body);
      
      print(t);
      return t;
      
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: _fetchrecipe(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Recipe ${widget.recipeId}"),
              ),
              
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

}