import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/recipe.dart';
import 'package:souschef_frontend/widgets.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});
  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  late Response response;

  Future<List<Cards>> gethomeinfo() async {
    response = await currSession.get("/recipe");

    List<dynamic> jsonData = jsonDecode(response.body);
    
    List<Cards> cards = jsonData.map((recipeData) {
      return Cards(
          title: recipeData['title'],
          serves: recipeData['serves'],
          authorid: recipeData['authorid'],
          recipeid: recipeData['recipeid'],
          rating: recipeData['averagerating'],
          duration: recipeData['duration']);
    }).toList();
    // print(jsonData[0]);
    return cards;
  }

  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Cards>>(
        future: gethomeinfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Discover'),
              ),
              body: RecipeCards(snapshot.data),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
