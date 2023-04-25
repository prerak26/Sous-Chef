import 'dart:convert';

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _fetchrecipe(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String k = snapshot.data!['lastmodified'];
            return Scaffold(
              appBar: AppBar(
                title: Text("${snapshot.data!['title']}"),
              ),
               body:Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:[
                Padding(padding: EdgeInsets.only(left : 10 , right: 10 , bottom: 10,top: 10),
                child: Text("Recipie : ${snapshot.data!['title']}"),
                ),
                Padding(padding: EdgeInsets.only(left : 10 , right: 10 , bottom: 10),
                child: Text("By chef ${snapshot.data!['authorid']}"),
                ),
                Padding(padding: EdgeInsets.only(left : 10 , right: 10 , bottom: 10),
                child: Text("Serves : ${snapshot.data!['serves']}"),
                ),
                Padding(padding: EdgeInsets.only(left : 10 , right: 10 , bottom: 10),
                child: Text("Ready in ${snapshot.data!['duration']}"),
                ),
                Padding(padding: EdgeInsets.only(left : 10 , right: 10 , bottom: 10),
                child: Text("Posted on ${snapshot.data!['lastmodified'].split('T')[0]} ${snapshot.data!['lastmodified'].split('T')[1].split('.')[0]}"),
                ),
                ]
               )
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
