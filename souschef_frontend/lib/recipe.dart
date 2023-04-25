import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:souschef_frontend/widgets.dart';

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
      print(response.body);
      dynamic t = jsonDecode(response.body);

      return t;
    } else {
      throw Exception('Failed to load recipe/${widget.recipeId}');
    }
  }

  Future<String> _fetchstep(int step) async {
    final String apiUrl = '/step/${widget.recipeId}?step=$step';
    final response = await currSession.get(apiUrl);
    print(response.body);
    if (response.statusCode == 200) {
      print(response.body);
    }

    return "a";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _fetchrecipe(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            double rating = snapshot.data!['averagerating'] ?? 0;
            int new_rating = 0;
            String k = snapshot.data!['lastmodified'];
            return Scaffold(
                appBar: AppBar(
                  title: Text("${snapshot.data!['title']}"),
                ),
                body: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, bottom: 10, top: 10),
                        child: Text("Recipie : ${snapshot.data!['title']}"),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Text("By chef ${snapshot.data!['authorid']}"),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Text("Serves : ${snapshot.data!['serves']}"),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Text("Ready in ${snapshot.data!['duration']}"),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Text(
                            "Posted on ${snapshot.data!['lastmodified'].split('T')[0]} ${snapshot.data!['lastmodified'].split('T')[1].split('.')[0]}"),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Text("Tags"),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Wrap(
                          children: List.generate(snapshot.data!['tags'].length,
                              (index) {
                            return Text(
                                "${snapshot.data!['tags'][index]['name']}");
                          }),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Text("Ingredients"),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Wrap(
                          children: List.generate(
                              snapshot.data!['requirements'].length, (index) {
                            return Text(
                                "${snapshot.data!['requirements'][index]['name']} [${snapshot.data!['requirements'][index]['quantity']} ${snapshot.data!['requirements'][index]['kind']}] ");
                          }),
                        ),
                      ),

                      const Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Text("Ratings"),
                      ),

                      RatingBar.builder(
                        initialRating: 1,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            new_rating = rating.toInt();
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('Follow Steps'),
                        onTap: () async {
                          final t = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return FutureBuilder<String>(
                                    future: _fetchstep(0),
                                    builder: (context, snapshot) {
                                      return snapshot.hasData
                                          ? SimpleDialog(
                                              title: const Text('Steps'),
                                              children: [
                                                Text("step"),
                                              ],
                                            )
                                          : Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                    });
                              });
                        },
                      ),
                    ]));
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
