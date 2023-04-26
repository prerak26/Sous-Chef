import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:souschef_frontend/Steps.dart';
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
      dynamic t = jsonDecode(response.body);
      print(t);
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
                  
                  actions: <Widget>[
                  snapshot.data!['authorid'] == session.id ? 
                  IconButton(
                    onPressed: () async{
                      bool delete = false;
                      var temp = await showDialog(
                        context: context, 
                        builder: (context){
                          return AlertDialog(
                            title: Text ('This action will delete this recipe permenantly'),
                            actions: [
                              TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
                              TextButton(onPressed: (){delete = true;Navigator.pop(context);}, child: const Text('Delete')),
                            ],
                          );
                        });
                        
                       if(delete) {
                        var response = await currSession.delete('/recipe/${widget.recipeId}');
                        Navigator.pop(context);  
                       }
                    }, 
                    icon: const Icon(Icons.delete_forever),
                    tooltip: 'Delete recipe permenantly',
                  ):  
                  isbookmark
                  ? IconButton(
                      icon: const Icon(Icons.bookmark_added),
                      tooltip: 'Remove from bookmarks',
                      onPressed: () async {
                        var response = await currSession.delete("/bookmark/${widget.recipeId}");
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
                        var response = await currSession.post("/bookmark/${widget.recipeId}",json.encode({}));
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
                        child: Text("Ready in ${snapshot.data!['duration']['hours']?? 0} : ${snapshot.data!['duration']['minute'] ?? 0}"),
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
                      
                      ListTile(
                        title: const Text('Follow Steps'),
                        onTap: () {
                          Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => StepsView(recipeId:widget.recipeId,maxsteps:totalstep)));
                        
                        }
                      ),
                    ]));
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
