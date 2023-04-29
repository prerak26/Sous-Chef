import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:souschef_frontend/Steps.dart';
import 'package:souschef_frontend/recipe_form.dart';
import 'package:souschef_frontend/widgets.dart';

import 'main.dart';

class RecipePage extends StatefulWidget {
  final int recipeId;
  final String caller;
  const RecipePage({super.key, required this.recipeId, required this.caller});
  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  Future<Map<String, dynamic>> _fetchrecipe() async {
    final String apiUrl = '/recipe/${widget.recipeId}';
    final response = await currSession.get(apiUrl);

    if (response.statusCode == 200) {
      dynamic t = jsonDecode(response.body);
      return t;
    } else {
      throw Exception('Failed to load recipe/${widget.recipeId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _fetchrecipe(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int totalstep = int.parse(snapshot.data!['stepcount']);

            bool isbookmark = snapshot.data!['isbookmarked'] == "true";
            double rating = (snapshot.data!['averagerating'] == 0)
                ? double.parse(snapshot.data!['averagerating'])
                : 0;
            int new_rating = 0;
            String k = snapshot.data!['lastmodified'];
            return Scaffold(
              appBar: AppBar(
                backgroundColor:
                    widget.caller == "home" ? Colors.lightGreen : Colors.amber,
                actions: <Widget>[
                  snapshot.data!['authorid'] == session.id
                      ? Row(children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => RecipeForm(
                                            recipeId: widget.recipeId,
                                          )))
                                  .then((_) => setState(() {}));
                            },
                            icon: const Icon(Icons.edit),
                            tooltip: "Edit Recipe",
                          ),
                          IconButton(
                            onPressed: () async {
                              bool delete = false;
                              var temp = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'This action will delete this recipe permenantly'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel')),
                                        TextButton(
                                            onPressed: () {
                                              delete = true;
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Delete')),
                                      ],
                                    );
                                  });

                              if (delete) {
                                var response = await currSession
                                    .delete('/recipe/${widget.recipeId}');
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.delete_forever),
                            tooltip: 'Delete recipe permenantly',
                          )
                        ])
                      : isbookmark
                          ? IconButton(
                              icon: const Icon(Icons.bookmark_added),
                              tooltip: 'Remove from bookmarks',
                              onPressed: () async {
                                var response = await currSession
                                    .delete("/bookmark/${widget.recipeId}");
                                if (response.statusCode == 200) {
                                  setState(() {
                                    isbookmark = false;
                                  });
                                }
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.bookmark_add),
                              tooltip: 'Add to Bookmarked',
                              onPressed: () async {
                                var response = await currSession.post(
                                    "/bookmark/${widget.recipeId}",
                                    json.encode({}));
                                if (response.statusCode == 200) {
                                  setState(() {
                                    isbookmark = true;
                                  });
                                }
                              },
                            ),
                ],
                title: Text("${snapshot.data!['title']}"),
              ),
              body: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(children: [
                        Column(children: [
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 12, top: 8),
                              child: Text(
                                'Recipe',
                                style: GoogleFonts.parisienne(
                                  fontSize: 40,
                                  // fontWeight: FontWeight.bold,
                                  color: widget.caller == "home"
                                      ? Colors.lightGreen
                                      : Colors.amber,
                                ),
                              ),
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 8, right: 8),
                                    child: Text(
                                      snapshot.data!['title'].length > 15
                                          ? snapshot.data!['title']
                                                  .substring(0, 15) +
                                              '...'
                                          : snapshot.data!['title'],
                                      style: GoogleFonts.merriweather(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        // color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8, right: 8),
                                    child: Text(
                                      '@${snapshot.data!['authorid']}',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ]),
                          ]),
                        ]),
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: FloatingActionButton.small(
                            backgroundColor: widget.caller == "home"
                                ? Colors.lightGreen
                                : Colors.amber,
                            tooltip: 'Follow Steps',
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => StepsView(
                                          recipeId: widget.recipeId,
                                          maxsteps: totalstep)))
                                  .then((_) {
                                setState(() {});
                              });
                            },
                            child: const Icon(
                              Icons.play_arrow,
                              size: 35,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Serves: ${snapshot.data!['serves']}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Ready in: ${snapshot.data!['duration']['hours'] ?? 0}h ${snapshot.data!['duration']['minute'] ?? 0}m",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Posted on: ${snapshot.data!['lastmodified'].split('T')[0]} ${snapshot.data!['lastmodified'].split('T')[1].split('.')[0]}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // const SizedBox(width: 16),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Tags",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: List.generate(
                                        snapshot.data!['tags'].length,
                                        (index) => Chip(
                                          label: Text(
                                            snapshot.data!['tags'][index]
                                                ['name'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                          backgroundColor:
                                              widget.caller == "home"
                                                  ? Colors.lightGreen
                                                  : Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 30, left: 10, right: 10, bottom: 10),
                          child: Row(children: [
                            Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: widget.caller == "home"
                                    ? Colors.lightGreen
                                    : Colors.amber,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: FloatingActionButton.small(
                                backgroundColor: widget.caller == "home"
                                    ? Colors.lightGreen
                                    : Colors.amber,
                                tooltip: 'Add ingredients to cart',
                                onPressed: () async {
                                  var response = await currSession.post(
                                      "/recipe/shop/${widget.recipeId}",
                                      jsonEncode({}));
                                  if (response.statusCode == 200 &&
                                      context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      duration: Duration(
                                          seconds: 0, milliseconds: 500),
                                      content: Text('Added to shopping list'),
                                    ));
                                  }
                                },
                                child: const Icon(
                                  Icons.add_shopping_cart_sharp,
                                  size: 15,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          ])),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            snapshot.data!['requirements'].length,
                            (index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  children: [
                                    Text(
                                      '• ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: widget.caller == "home"
                                            ? Colors.lightGreen
                                            : Colors.amber,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${snapshot.data!['requirements'][index]['name']} [${snapshot.data!['requirements'][index]['quantity']} ${snapshot.data!['requirements'][index]['kind']}] ',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 10, right: 10, bottom: 20),
                            child: Text(
                              'Ratings',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: widget.caller == "home"
                                    ? Colors.lightGreen
                                    : Colors.amber,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${(double.parse(snapshot.data!['averagerating'] ?? '-1') == -1) ? '-' : double.parse(snapshot.data!['averagerating'])}/5 - ${snapshot.data!['ratingtotal'] ?? 0}(votes)',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    ]),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                backgroundColor:
                    widget.caller == "home" ? Colors.lightGreen : Colors.amber,
                title: const Text("Recipe"),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
