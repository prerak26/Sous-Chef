import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/recipe.dart';
import 'package:souschef_frontend/recipe_form.dart';
import 'package:souschef_frontend/widgets.dart';
import 'package:souschef_frontend/discover.dart';
import 'package:souschef_frontend/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Cards> cards = [];
  List<Cards> bookmarkcards = [];
  // ignore: prefer_typing_uninitialized_variables
  var response;
  Future<User> gethomeinfo() async {
    response = await currSession.get("/chef/${session.id}");

    var body = json.decode(response.body);
    User user = User(chefid: body["chefId"], name: body["name"]);
    List<dynamic> recipe = body['recipes'];

    cards = recipe.map((recipeData) {
      return Cards(
          title: recipeData['title'],
          serves: recipeData['serves'],
          authorid: recipeData['authorid'],
          recipeid: recipeData['recipeid'],
          rating: (recipeData['averagerating'] == null)
              ? recipeData['averagerating']
              : 0,
          duration:
              "${recipeData['duration']['hours']} : ${recipeData['duration']['minutes']}");
    }).toList();

    List<dynamic> bookmark = body['bookmarks'];

    bookmarkcards = bookmark.map((recipeData) {
      return Cards(
          title: recipeData['title'],
          serves: recipeData['serves'],
          authorid: recipeData['authorid'],
          recipeid: recipeData['recipeid'],
          rating: (recipeData['averagerating'] == null)
              ? recipeData['averagerating']
              : 0,
          duration:
              "${recipeData['duration']['hours']} : ${recipeData['duration']['minutes']}");
    }).toList();

    return user;
  }

  //TabController _controller = new TabController();

  Widget display(data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 20.0),
        Wrap(children: [
          Column(children: [
            Row(children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 12, top: 8),
                child: Text(
                  'Chef',
                  style: GoogleFonts.parisienne(
                    fontSize: 55,
                    // fontWeight: FontWeight.bold,
                    color: Colors.lightGreen,
                  ),
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Text(
                    data.name,
                    style: GoogleFonts.merriweather(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      // color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, right: 8),
                  child: Text(
                    '@${data.chefid}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ]),
            ]),
          ]),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: FloatingActionButton.small(
              backgroundColor: Colors.lightGreen,
              tooltip: 'Create new recipe',
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (context) => const RecipeForm(
                        recipeId: -1,
                      ),
                    ))
                    .then((_) => setState(() {}));
              },
              child: const Icon(
                Icons.add,
                size: 35,
                color: Colors.black,
              ),
            ),
          )
        ]),
        DefaultTabController(
          length: 2, // length of tabs
          initialIndex: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TabBar(
                onTap: (value) {
                  setState(() {});
                },
                labelColor: Colors.lightGreen,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'My Recipes'),
                  Tab(text: 'Bookmarks'),
                ],
                indicatorColor: Colors.lightGreen,
              ),
              Container(
                height: 400, //height of TabBarView
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: TabBarView(
                  children: <Widget>[
                    Container(
                      child: recipeCards(cards, this, "home"),
                    ),
                    Container(
                      child: recipeCards(bookmarkcards, this, "home"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!session.isLogged) {
      return authorisationPage(context, "home");
    }
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              var response = await currSession.get("/logout");
              if (response.statusCode == 200) {
                setState(() {
                  session.isLogged = false;
                  session.id = null;
                  session.pswd = null;
                });
              }
            },
          ),
        ],
        backgroundColor: Colors.lightGreen,
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
          future: gethomeinfo(),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? display(snapshot.data)
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.lightGreen,
                    ),
                  );
          }),
    );
  }
}
