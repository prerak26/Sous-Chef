import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/recipe_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class User {
  final String? chefid;
  final String? name;
  User({this.chefid, this.name});
}

class _HomePageState extends State<HomePage> {
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
