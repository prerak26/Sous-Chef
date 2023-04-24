import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/recipe.dart';

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

  void _onCardTap(int id) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => RecipePage(recipeId: id)));
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
              body: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () =>
                              _onCardTap(snapshot.data![index].recipeid),
                          child: Card(
                            child: ListTile(
                              title: Text(snapshot.data![index].title),
                              subtitle: Text(
                                  'By ${snapshot.data![index].authorid} - Serves ${snapshot.data![index].serves}'),
                            ),
                          )));
                },
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
