import 'dart:convert';
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
  
  void _onCardTap(int id) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => RecipePage(recipeId: id)));
  }

  List<Cards> cards = [];
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
          rating: recipeData['averagerating'],
          duration: recipeData['duration']);
    }).toList();

    return user;
  }

  //TabController _controller = new TabController();

  Widget display(data) {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
          Widget>[
        SizedBox(height: 20.0),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(children: [
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 20),
              child: Text("Id : ${data.chefid}"),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 20),
              child: Text("Name : ${data.name}"),
            )
          ]),
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: FloatingActionButton(
              backgroundColor: Colors.amberAccent,
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => const RecipeForm()))
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
                  Container(
                    child: TabBar(
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.black,
                      tabs: [
                        Tab(text: 'My Recipes'),
                        Tab(text: 'Bookmarks'),
                      ],
                    ),
                  ),
                  Container(
                      height: 400, //height of TabBarView
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.grey, width: 0.5))),
                      child: TabBarView(children: <Widget>[
                        Container(
                          child: ListView.builder(
                            itemCount: cards.length,
                            itemBuilder: (context, index) {
                              return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                      onTap: () => _onCardTap(
                                          cards[index].recipeid),
                                      child: Card(
                                        child: ListTile(
                                          title:
                                              Text(cards[index].title),
                                          subtitle: Text(
                                              'By ${cards[index].authorid} - Serves ${cards[index].serves}'),
                                        ),
                                      )));
                            },
                          ),
                        ),
                        Container(
                          child: Center(
                            child: Text('Display Tab 2',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ]))
                ])),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!session.isLogged) {
      return authorisationPage(context, "home");
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipies'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
          future: gethomeinfo(),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? display(snapshot.data)
                : const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
