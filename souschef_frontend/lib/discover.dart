import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/recipe.dart';
import 'package:souschef_frontend/widgets.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});
  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class Suggestion {
  int? id;
  String name;
  Suggestion({required this.name, this.id});
}

class _DiscoverViewState extends State<DiscoverView> {
  late Response response;
  String? _sort = 'rel';
  Map<String, String> sorts = {
    'rel': "Relevant",
    'top': "Top Rated",
    'hot': "Trending",
    'new': "Newest",
    'con': "Controversial",
    'fas': "Quickest"
  };
  String _author = '';
  List<int?> _tagIds = [];
  List<String> _tagNames = [];
  String _keyword = '';
  final _searchController = TextEditingController();

  Future<List<Cards>> _fetchRecipes() async {
    List<String> queries = [];
    if (_author != "") {
      queries.add("author=$_author");
    }
    if (_tagIds.isNotEmpty) {
      queries.add("tags=${_tagIds.join('+')}");
    }
    if (_keyword != "") {
      queries.add("key=$_keyword");
    }
    queries.add("sort=$_sort");
    response = await currSession.get("/recipe?${queries.join('&')}");
    List<dynamic> body = jsonDecode(response.body);
    print(body);
    List<Cards> cards = body.map((recipeData) {
      return Cards(
          title: recipeData['title'],
          serves: recipeData['serves'],
          authorid: recipeData['authorid'],
          recipeid: recipeData['recipeid'],
          rating: recipeData['averagerating'],
          duration: "${recipeData['duration']['hours']} : ${recipeData['duration']['minutes']}");
    }).toList();
    
    return cards;
  }

  Future<List<Suggestion>> _fetchAuthors(String query) async {
    Response response = await currSession.get("/chef?key=$query");
    List<dynamic> body = json.decode(response.body);
    List<Suggestion> suggestedAuthors =
        body.map((e) => Suggestion(name: "@" + e["chefid"])).toList();
    return suggestedAuthors;
  }

  Future<List<Suggestion>> _fetchTags(String query) async {
    Response response = await currSession.get("/tag?key=$query");
    List<dynamic> body = json.decode(response.body);
    List<Suggestion> suggestedTags = body
        .map((e) => Suggestion(name: "#" + e["name"], id: e["tagid"]))
        .toList();
    return suggestedTags;
  }

  Future<List<Suggestion>> _fetchRecipeNames(String query) async {
    Response response = await currSession.get("/recipes?key=$query");
    List<dynamic> body = json.decode(response.body);
    List<Suggestion> suggestedNames =
        body.map((e) => Suggestion(name: e as String)).toList();
    return suggestedNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover'), actions: [
        _sortDropdown(),
      ]),
      drawer: _queryingDrawer(),
      body: Column(children: [
        _searchBox(),
        FutureBuilder<List<Cards>>(
            future: _fetchRecipes(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Expanded(
                      child: recipeCards(snapshot.data),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            }),
      ]),
    );
  }

  Widget _queryingDrawer() {
    return Drawer(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ListTile(
                title: Text("Search Keyword"),
              ),
              _keyword != ""
                  ? Column(children: [
                      ListTile(
                        title: Wrap(children: [
                          OutlinedButton.icon(
                            label: Text(_keyword),
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _keyword = '';
                              });
                            },
                          ),
                        ]),
                      ),
                      const Divider(),
                    ])
                  : const Divider(),
              const ListTile(
                title: Text("Tags"),
              ),
              _tagIds.isNotEmpty
                  ? Column(children: [
                      ListTile(
                        title: Wrap(
                          children: _tagIds
                              .asMap()
                              .entries
                              .map(
                                (e) => OutlinedButton.icon(
                                  label: Text(_tagNames[e.key]),
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _tagIds.removeAt(e.key);
                                      _tagNames.removeAt(e.key);
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const Divider(),
                    ])
                  : const Divider(),
              const ListTile(
                title: Text("Author"),
              ),
              _author != ""
                  ? Column(children: [
                      ListTile(
                        title: Wrap(children: [
                          OutlinedButton.icon(
                            label: Text(_author),
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _author = '';
                              });
                            },
                          ),
                        ]),
                      ),
                      const Divider(),
                    ])
                  : const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DropdownButton<String>(
        value: _sort,
        icon: const Icon(Icons.sort),
        items: sorts.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _sort = value;
          });
        },
        borderRadius: const BorderRadius.all(Radius.elliptical(8, 4)),
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Type something',
            border: OutlineInputBorder(),
          ),
        ),
        suggestionsCallback: (pattern) async {
          if (pattern.startsWith("@")) {
            return await _fetchAuthors(pattern.substring(1));
          } else if (pattern.startsWith("#")) {
            return await _fetchTags(pattern.substring(1));
          } else {
            return await _fetchRecipeNames(pattern);
          }
        },
        itemBuilder: (context, itemData) {
          return ListTile(
            title: Text(itemData.name),
          );
        },
        onSuggestionSelected: (suggestion) {
          setState(() {
            _searchController.text = '';
            if (suggestion.name.startsWith("#")) {
              _tagIds.add(suggestion.id);
              _tagNames.add(suggestion.name);
            } else if (suggestion.name.startsWith("@")) {
              _author = suggestion.name.substring(1);
            } else {
              _keyword = suggestion.name;
            }
          });
        },
      ),
    );
  }
}
