import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/recipe_form.dart';
import 'package:souschef_frontend/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}



class _HomeViewState extends State<HomeView> {
  // ignore: prefer_typing_uninitialized_variables
  var response;
  Future<User> gethomeinfo() async {
    response = await currSession.get("/chef/${session.id}");

    var body = json.decode(response.body);
    User user = User(chefid: body["chefId"], name: body["name"]);
    //print(body["recipes"]);

    return user;
  }

  //TabController _controller = new TabController();

  Widget display(data) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RecipeForm()));
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
                                  top: BorderSide(
                                      color: Colors.grey, width: 0.5))),
                          child: TabBarView(children: <Widget>[
                            Container(
                              child: Center(
                                child: Text('Display Tab 1',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Container(
                              child: Center(
                                child: Text('Display Tab 2',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
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
