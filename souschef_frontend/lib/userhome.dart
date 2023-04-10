import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:souschef_frontend/autocomplete.dart';
import 'package:souschef_frontend/main.dart';
import 'package:http/http.dart' as http;
import 'package:souschef_frontend/recepieform.dart';
//import 'package:souschef_frontend/signup.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});
  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class User{
  final String? chefid;
  final String? name;
  //final String? pswd;

  User({this.chefid, this.name});
}

class _UserHomePageState extends State<UserHomePage> {
  // ignore: prefer_typing_uninitialized_variables
  var response;
  //var body;
  Future<User> gethomeinfo() async{
    response = await curr_session.get("http://localhost:3001/chef/${session.id}");
    
    var body = json.decode(response.body);
    User user = User(chefid:body["chefId"],name:body["name"]);
    return user;

  }

  Widget display(data)
  {
    //var body = json.decode(data.body);
    return Container(
      child: 
        Column(
          children: [
            Text('${data.name}'),
            Text('${data.chefid}'),
            FloatingActionButton(
              backgroundColor: Colors.amberAccent,
              onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) => RecipeForm()));},
              child: const Icon(
                Icons.add,
                size: 35,
                color: Colors.black,
                ),
              ),
            ],
          )
        
      
    ); 
  }

  //gethomeinfo();
  @override
  Widget build(BuildContext context) {
    gethomeinfo();
    
    //var chefId = body["chefId"] as String;
    //var name = body["name"] as String;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipies'),
        automaticallyImplyLeading: false,
      ),
      body:FutureBuilder(
        future: gethomeinfo(),
        builder: (context,snapshot){
          return snapshot.data != null 
          ?  display(snapshot.data) 
          : Center(child: CircularProgressIndicator());

        }),
    );
  }
}
