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

class User {
  final String? chefid;
  final String? name;
  User({this.chefid, this.name});
}

class _HomeViewState extends State<HomeView> {
  // ignore: prefer_typing_uninitialized_variables
  var response;
  Future<User> gethomeinfo() async {
    response =
        await currSession.get("http://localhost:3001/chef/${session.id}");

    var body = json.decode(response.body);
    User user = User(chefid: body["chefId"], name: body["name"]);
    return user;
  }

  Widget display(data) {
    return Column(
      children: [
        Text('${data.name}'),
        Text('${data.chefid}'),
        FloatingActionButton(
          backgroundColor: Colors.amberAccent,
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const RecipeForm()));
          },
          child: const Icon(
            Icons.add,
            size: 35,
            color: Colors.black,
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
        title: const Text('My Recipies'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
          future: gethomeinfo(),
          builder: (context, snapshot) {
            return snapshot.data != null
                ? display(snapshot.data)
                : const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
