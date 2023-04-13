import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/recipe.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});
  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class Cards {
  int recipeid;
  String title;
  int serves;
  String authorid;
  Cards(
      {required this.recipeid,
      required this.title,
      required this.serves,
      required this.authorid});
}

class _DiscoverPageState extends State<DiscoverPage> {
  late Response response;

  Future<List<Cards>> gethomeinfo() async {
    response = await currSession.get("http://localhost:3001/recipe");

    List<dynamic> jsonData = jsonDecode(response.body);
    List<Cards> cards = jsonData.map((recipeData) {
      return Cards(
          title: recipeData['title'],
          serves: recipeData['serves'],
          authorid: recipeData['authorid'],
          recipeid: recipeData['recipeid']);
    }).toList();
    return cards;
  }

  void _onCardTap(int id) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => RecipePage(recipeid: id)));
  }

  Widget card(String title, int serves, String authorid, BuildContext context) {
    String serve = '$serves';
    return Card(
      color: Colors.yellow[50],
      elevation: 8.0,
      margin: const EdgeInsets.all(4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 38.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            serve,
            style: const TextStyle(
              fontSize: 38.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            authorid,
            style: const TextStyle(
              fontSize: 38.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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
