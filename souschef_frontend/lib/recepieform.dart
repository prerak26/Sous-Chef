import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:souschef_frontend/main.dart';
import 'package:http/http.dart' as http;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:souschef_frontend/autocomplete.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
//import 'package:my_recipe_app/models/recipe.dart';

class Ingredient{
  int id;
  String quantity;
  String name;
  Ingredient({required this.id,required this.quantity,required this.name});
  Map<String, dynamic> toJson() => {
        'id': id,
        'quantity': quantity,
      };
}

class Step{
  int duration;
  String desc;
  List<Ingredient> ingredients = [];
  Step({required this.duration,required this.desc,required this.ingredients});
   Map<String, dynamic> toJson() => {
        'duration': duration,
        'desc': desc,
        'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
      };
}

class Recipe{
  String title;
  int serves;
  bool isPublic = false;
  //List<String> ingredients = [];
  List<Step> steps = [];
  List<Tag>tags = [];
  Recipe({required this.title, required this.serves, required this.isPublic,required this.steps,required this.tags});
   Map<String, dynamic> toJson() => {
        'title': title,
        'serves': serves,
        'isPublic': isPublic,
        'steps': steps.map((step) => step.toJson()).toList(),
        'tags': tags.map((tag)=>tag.toJson()).toList(),
      };
}

class Tag{
  int tagid;
  String name;
  Tag({required this.tagid,required this.name});
  Map<String, dynamic> toJson() => {
        'tagid': tagid,
        'name': name,
      };
  
}

class RecipeForm extends StatefulWidget {
  @override
  _RecipeFormState createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
 

  final _formKey = GlobalKey<FormState>();
  GlobalKey<AutoCompleteTextFieldState<Tag>> key = GlobalKey();
  //String _name;
  //int _serves;
  //List<String> _ingredients = [];
  List<Step> _instructions = [];
  bool _isPublic = false;
  //String? temp;
  final _nameController = TextEditingController();
  final _servesController = TextEditingController();
  final _instcontroller = TextEditingController();
  final _durationcontroller = TextEditingController();
  
  List<String> _suggestions = [];
  //List<Tag> tagsuggestions = [];

  void _getSuggestions(String text) async {
    if (text.contains("@")) {
      // Replace this with your API call to get the suggestions.
      //String apiUrl = "https://example.com/suggestions?query=$text";
      var response = await curr_session.get('https://example.com/suggestions?query=$text');
      List<dynamic> suggestionsJson = json.decode(response.body);
      List<String> suggestions = suggestionsJson.cast<String>().toList();

      setState(() {
        _suggestions = suggestions;
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

Future<List<Tag>> _fetchSuggestions(String query) async {
    final String apiUrl = 'http://localhost:3001/tag?key=$query';
    final response = await curr_session.get(apiUrl);
    if (response.statusCode == 200) {
      
      List<dynamic> t = jsonDecode(response.body);
      print(t);
      List<Tag> l = t.map((tagData) {
        return Tag(
        //recipeid: recipeData['recipeid'],
          tagid: tagData['tagid'],
          name: tagData['name'],
        );
      }).toList();
      
      Tag def = Tag(tagid: -1,name: "ADD NEW TAG");
      l.add(def);
      
      return l;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> _addValue(String value) async {
    final String apiUrl ='http://localhost:3001/tag';
    final response = await curr_session.post(apiUrl, json.encode({'name': value}));
    //print(response);
    if (response.statusCode == 200) {
      

    } else {
      throw Exception('Failed to add new value');
    }
  }

  Future<List<Ingredient>> fetchingredient(String query)async{
    final String apiUrl = 'http://localhost:3001//ingredient?key=$query';
    final response = await curr_session.get(apiUrl);
    if (response.statusCode == 200) {
      
      List<dynamic> t = jsonDecode(response.body);
      print(t);
      // List<Ingredient> l = t.map((tagData) {
      //   return Ingredient(
      //   //recipeid: recipeData['recipeid'],
      //     id: tagData['tagid'],
      //     quantity: tagData['name'],
      //   );
      // }).toList();
      
      // Tag def = Tag(tagid: -1,name: "ADD NEW TAG");
      // l.add(def);
      
      return [];
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> _addIngredient(String value,String _kind) async {
    final String apiUrl ='http://localhost:3001//ingredient';
    final response = await curr_session.post(apiUrl, json.encode({'name': value,'kind':_kind}));
    //print(response);
    if (response.statusCode == 200) {
      

    } else {
      throw Exception('Failed to add new value');
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchController.addListener(() {
      onChange();
    });
  }

void onChange(){
  _fetchSuggestions(_searchController.text);
}

List<Tag> tagsub = [];

Widget tagcomp(BuildContext){
    List<String> k;
    return  Column(
        children: [
          TypeAheadField(
            
            textFieldConfiguration: TextFieldConfiguration(
            controller: _searchController,
            autofocus: true,
            style: DefaultTextStyle.of(context).style.copyWith(
            fontStyle: FontStyle.italic
          ),
          decoration: InputDecoration(
            
            border: OutlineInputBorder()
          )
          ),

            suggestionsCallback: (pattern) async{
               k = pattern.split(',');
               //print("k : ");
               //print(k.last);
              
              
              return await _fetchSuggestions(k.last);
            },
            itemBuilder: (context,sugesstion){
              return ListTile(
                title: Text(sugesstion.name),
              );
            }, 
            onSuggestionSelected: (sugesstion) {
              //_searchController.text = sugesstion.name;
              if (sugesstion.tagid != -1) {
                          setState(() {
                           
                            k = _searchController.text.split(',');
                            
                            k.removeLast();
                           
                            _searchController.text = k.join(',')+','+sugesstion.name + ',';
                          });
                        } else {
                          k = _searchController.text.split(',');
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Add new value?'),
                              content: Text('Do you want to add the new value: ${k.last}?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: Text('Add'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    
                                    _addValue(k.last);
                                    //k = _searchController.text.split(',');
                                    //k.removeLast();
                                    _searchController.text = k.join(',') + ',';
                                  },
                                ),
                              ],
                            ),
                          );
                        }
            }
            ),

        ]
      );
  }

  final TextEditingController _searchController = TextEditingController();
  String selectedtag = "";
  Recipe recipe = Recipe(title:"",serves: 0,isPublic: true, steps: [],tags: []);
  void _saveRecipe() async {

    if (_formKey.currentState!.validate()) {
        List<Tag> _tags = [];
        List<String> tagsstr = _searchController.text.split(',');
        for (String str in tagsstr){
          if(str!=""){
            var resp = await _fetchSuggestions(str);
            _tags.add(resp[0]);
          }
        }
        print(_tags);
        recipe.isPublic = _isPublic;
        recipe.title = _nameController.text;
        recipe.serves = int.parse(_servesController.text);
        recipe.steps = _instructions;
        recipe.tags = _tags;

      //print(jsonEncode(recipe.toJson()));
      var response = await curr_session.post('http://localhost:3001/recipe', jsonEncode(recipe.toJson()));
      //rprint(jsonEncode(recipe.toJson()));
      if(response.statusCode == 200){
         //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //content: Text('Recipie Created'),
          //));
       Navigator.pop(context);
      }
      // Save the recipe data to your app's data store here
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
      ),
      body:Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Recipe Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for the recipe';
                  }
                  return null;
                },
                onSaved: (value) {
                  //_name = _nameController.text;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _servesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Serves'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of people the dish serves';
                  }
                  return null;
                },
                onSaved: (value) {
                  //_serves = int.parse(_servesController.text);
                },
              ),

              SizedBox(height: 16),
               Container(
                  width: 1000, height: 200,
                  child:tagcomp(BuildContext),
               ),
              Row(
              children: [
                Checkbox(
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value!;
                    });
                  },
                ),
                const Text("Make public"),
              ],
            ),
            SizedBox(height: 16),
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 8),
              ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _instructions.length + 1,
              itemBuilder: (BuildContext context, int index) {
              if (index == _instructions.length) {
              return ListTile(
                title: Text('Add Instruction'),
                leading: Icon(Icons.add),
                onTap: () async {
                  final instruction = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text('Add Instruction'),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8
                          ),
                          child:Column( 
                            children: [
                              Column(
                                children:[
                                  TextFormField(
                                    controller: _instcontroller,
                                    onChanged: (text) => _getSuggestions(text),
                                    autofocus: true,
                                    decoration: InputDecoration(
                                    labelText: 'Instruction'
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an instruction';
                                    }
                                  
                                    return null;
                                  },
                                ),
                                _suggestions.isNotEmpty
                                ? Container(
                                    height: 200,
                                    child: ListView.builder(
                                      itemCount: _suggestions.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return ListTile(
                                          title: Text(_suggestions[index]),
                                          onTap: () {
                                            setState(() {
                                              _instcontroller.text += _suggestions[index];
                                              _suggestions = [];
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  )
                                : Container(),
                                ]
                                ),
                            TextFormField(
                              controller: _durationcontroller,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              autofocus: true,
                              decoration: InputDecoration(
                                labelText: 'Duration'
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter duration';
                                }
                              //else {temp = value;}
                                return null;
                              },
                            ),    
                          ])
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text('Add'),
                              onPressed: () {
                                final form =_formKey.currentState!;
                                if (form.validate()) {
                                  form.save();
                                  Step S = Step(duration: int.parse(_durationcontroller.text),desc: _instcontroller.text,ingredients: []);
                                  _instructions.add(S);
                                  _instcontroller.text = "";
                                  Navigator.pop(context);
                                }
                              },  
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            );
          } 
          else {
            return ListTile(
              title: Text(_instructions[index].desc),
              trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _instructions.removeAt(index);
                }
              );},
              ),
            );
          }
        },
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: _saveRecipe,
        child: Text('Save Recipe'),
      ),
    ],
  ),
),
),
);
}
}
