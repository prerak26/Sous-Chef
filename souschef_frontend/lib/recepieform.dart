import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:souschef_frontend/main.dart';
import 'package:http/http.dart' as http;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:souschef_frontend/autocomplete.dart';
//import 'package:my_recipe_app/models/recipe.dart';

class Ingredient{
  String id;
  String quantity;
  Ingredient({required this.id,required this.quantity});
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
  List<int>tags = [];
  Recipe({required this.title, required this.serves, required this.isPublic,required this.steps});
   Map<String, dynamic> toJson() => {
        'title': title,
        'serves': serves,
        'isPublic': isPublic,
        'steps': steps.map((step) => step.toJson()).toList(),

      };
}

class Tag{
  int tagid;
  String name;
  Tag({required this.tagid,required this.name});
}

class RecipeForm extends StatefulWidget {
  @override
  _RecipeFormState createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
 

  final _formKey = GlobalKey<FormState>();

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
  List<Tag> tagsuggestions = [];

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

void _fetchSuggestions(String query) async {
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
      setState(() {
        tagsuggestions = l;
      });
      //return l;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> _addValue(String value) async {
    final String apiUrl ='http://localhost:3001/tag';
    final response = await curr_session.post(apiUrl, json.encode({'name': value}));
    print(response);
    if (response.statusCode == 200) {
      setState(() {
        _selectedValue = value;
      });
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

Widget tagcomp(BuildContext){
    return  Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged : (value) async{
                //tagsuggestions = await _fetchSuggestions(_searchController.text);
                
              },
              decoration: InputDecoration(
                hintText: 'Enter a value',
              ),
            ),
          ),
          Expanded(
           child:Container(
                  
                  width: 100, height: 250,
                  child:ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: tagsuggestions.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        tagsuggestions[index].name,
                        style: TextStyle(fontSize: 10),),
                      onTap: () {
                        if (index != tagsuggestions.length-1) {
                          setState(() {
                            _selectedValue = tagsuggestions[index].name;
                            tagsuggestions.clear();
                          });
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Add new value?'),
                              content: Text('Do you want to add the new value: ${_searchController.text}?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: Text('Add'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _addValue(_searchController.text);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ))
                ),
          
            
        ],
      );
  }

  final TextEditingController _searchController = TextEditingController();
  String _selectedValue = '';

  

  GlobalKey<AutoCompleteTextFieldState<Tag>> key = GlobalKey();
  String selectedtag = "";
  Recipe recipe = Recipe(title:"",serves: 0,isPublic: true, steps: []);
  void _saveRecipe() async {

    if (_formKey.currentState!.validate()) {
      
        recipe.isPublic = _isPublic;
        recipe.title = _nameController.text;
        recipe.serves = int.parse(_servesController.text);
        recipe.steps = _instructions;
    

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
      body: Padding(
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
                  width: 100, height: 300,
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
