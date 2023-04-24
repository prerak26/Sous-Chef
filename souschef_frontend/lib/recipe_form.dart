import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:souschef_frontend/main.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class RecipeForm extends StatefulWidget {
  const RecipeForm({super.key});

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _formKey = GlobalKey<FormState>();
  final List<Instruction> _instructions = [];
  bool _isPublic = false;
  final _nameController = TextEditingController();
  final _servesController = TextEditingController();
  final _instcontroller = TextEditingController();
  final _durationcontroller = TextEditingController();
  

  List<String> _suggestions = [];

  void _getSuggestions(String text) async {
    if (text.contains("@")) {
      // Replace this with your API call to get the suggestions.
      // String apiUrl = "https://example.com/suggestions?query=$text";
      var response =
          await currSession.get('https://example.com/suggestions?query=$text');
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
    final response = await currSession.get(apiUrl);
    if (response.statusCode == 200) {
      List<dynamic> t = jsonDecode(response.body);
      print(t);
      List<Tag> l = t.map((tagData) {
        return Tag(
          tagid: tagData['tagid'],
          name: tagData['name'],
        );
      }).toList();

      Tag def = Tag(tagid: -1, name: "ADD NEW TAG");
      l.add(def);

      return l;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }



  Future<void> _addTag(String value) async {
    const String apiUrl = 'http://localhost:3001/tag';
    final response =
        await currSession.post(apiUrl, json.encode({'name': value}));
    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to add new value');
    }
  }

      Future<List<Ingredient>> _fetchIngredients(String query) async {
    final String apiUrl = 'http://localhost:3001/ingredient?key=$query';

    final response = await currSession.get(apiUrl);
    
    if (response.statusCode == 200) {
      List<dynamic> t = jsonDecode(response.body);
      print(t);
      List<Ingredient> l = t.map((ingredientData) {
        return Ingredient(
          id : ingredientData['ingredientid'],
          name: ingredientData['name'],
          kind: ingredientData['kind'],
        );
      }).toList();

      Ingredient def = Ingredient(id: -1, name: "Add New Ingredient");
      l.add(def);

      return l;
    } 
    else {
      throw Exception('Failed to load suggestions');
    }
  }
 
  Future<void> _addIngredient(String value , String value1) async {
    const String apiUrl = 'http://localhost:3001/ingredient';
    final response = await currSession.post(
        apiUrl, json.encode({'name': value, 'kind': value1}));
    //print(response);
    if (response.statusCode == 200) {

    } 
    else {
      throw Exception('Failed to add new value');
    }
  }

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _qunatitycontroller = TextEditingController();
  final TextEditingController _ingredientNameController= TextEditingController();
  final TextEditingController _ingredientKindController= TextEditingController();
  String selectedIngredient = "";
  String selectedtag = "";

  // void onChange() {
  //   _fetchSuggestions(_searchController.text);
  // }

  //final list of tags and ingredients to be posted
  List<Tag> tagsub = [];
  List<Ingredient> ingredientsub = [];
  
  // tag auto complete widget
  Widget tagcomp(BuildContext context) {
    List<String> k;
    return Column(children: [
      TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: _searchController,
              autofocus: true,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontStyle: FontStyle.italic),
              decoration: const InputDecoration(
                labelText: 'Tags',
                
                border: OutlineInputBorder())
                ),
          suggestionsCallback: (pattern) async {
            k = pattern.split(',');

            return await _fetchSuggestions(k.last);
          },
          itemBuilder: (context, sugesstion) {
            return ListTile(
              title: Text(sugesstion.name),
            );
          },
          onSuggestionSelected: (sugesstion) {
            if (sugesstion.tagid != -1) {
              setState(() {



                k = _searchController.text.split(',');

                k.removeLast();

                _searchController.text = '${k.join(',')},${sugesstion.name},';
              });
            } else {
              k = _searchController.text.split(',');
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add new value?'),
                  content: Text('Do you want to add the new value: ${k.last}?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('Add'),
                      onPressed: () {
                        Navigator.of(context).pop();

                        _addTag(k.last);
                        _searchController.text = '${k.join(',')},';
                      },
                    ),
                  ],
                ),
              );
            }
          }),
    ]);
  }

  Widget ingredientsComp(BuildContext context) {
    List<String> k;
    return Column(children: [
      TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: _ingredientController,
              autofocus: true,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontStyle: FontStyle.italic),
              decoration: const InputDecoration(
                labelText: 'Ingredients',
                
                border: OutlineInputBorder())
                ),
          suggestionsCallback: (pattern) async {
            k = pattern.split(',');

            return await _fetchIngredients(k.last);
          },
          itemBuilder: (context, sugesstion) {
            return ListTile(
              title: Text(sugesstion.name),
            );
          },
          onSuggestionSelected: (sugesstion) async {
            if (sugesstion.id != -1) {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add new value?'),
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _qunatitycontroller,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        autofocus: true,
                        decoration: InputDecoration(
                            labelText: 'Quantity in ${sugesstion.kind}'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a quantity';
                          }
                          return null;
                        },
                        
                    ),
                  ]),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('Add'),
                      onPressed: () {
                        Navigator.of(context).pop();

                        setState(() {
                        k = _ingredientController.text.split(',');
                        k.removeLast();
                        _ingredientController.text = '${k.join(',')},${sugesstion.name},';
                        Ingredient sub = sugesstion;
                        sub.quantity = int.parse(_qunatitycontroller.text);
                        ingredientsub.add(sub);
                    });
                      },
                    ),
                  ],
                ),
              );

              
            
            } 
            else {
              k = _ingredientController.text.split(',');
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add new value?'),
                  content:Column(
                    children: [
                      
                        TextFormField(
                        controller: _ingredientNameController,
                        
                        autofocus: true,
                        decoration: const InputDecoration(
                            labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name of the ingredient';
                          }
                          return null;
                        },
                        
                    ),  

                      TextFormField(
                        controller: _ingredientKindController,
                        
                        
                        autofocus: true,
                        decoration: const InputDecoration(
                            labelText: 'Kind of ingredient'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter kind for the ingredient';
                          }
                          return null;
                        },
                        
                    ),

                  ]),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('Add'),
                      onPressed: () {
                        Navigator.of(context).pop();

                        _addIngredient(_ingredientNameController.text,_ingredientKindController.text);
                        _ingredientNameController.text = "";
                        _ingredientKindController.text = "";
                        //_ingredientController.text = '${k.join(',')},';

                      },
                    ),
                  ],
                ),
              );
            }
          }),
    ]);
  }
  Recipe recipe =
      Recipe(title: "", serves: 0, isPublic: true, steps: [], tags: []);
  
  void _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      List<Tag> tags = [];
      List<String> tagsstr = _searchController.text.split(',');
      for (String str in tagsstr) {
        if (str != "") {
          var resp = await _fetchSuggestions(str);
          tags.add(resp[0]);
        }
      }
      recipe.isPublic = _isPublic;
      recipe.title = _nameController.text;
      recipe.serves = int.parse(_servesController.text);
      recipe.steps = _instructions;
      recipe.tags = tags;

      var response = await currSession.post(
          'http://localhost:3001/recipe', jsonEncode(recipe.toJson()));
      if (response.statusCode == 200) {
        Navigator.pop(context);
      }
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
                decoration: const InputDecoration(labelText: 'Recipe Name'),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _servesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Serves'),
                inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                ],
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
              const SizedBox(height: 16),
              // tag autocomplete commponent

              tagcomp(context),
              const SizedBox(height: 16),
              ingredientsComp(context),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              
              
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),


              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _instructions.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == _instructions.length) {
                    return ListTile(
                      title: const Text('Add Instruction'),
                      leading: const Icon(Icons.add),
                      onTap: () async {
                        final instruction = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Text('Add Instruction'),
                              children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Column(children: [
                                      Column(children: [
                                        TextFormField(
                                          controller: _instcontroller,
                                          onChanged: (text) =>
                                              _getSuggestions(text),
                                          autofocus: true,
                                          decoration: const InputDecoration(
                                              labelText: 'Instruction'),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter an instruction';
                                            }

                                            return null;
                                          },
                                        ),
                                        _suggestions.isNotEmpty
                                            ? SizedBox(
                                                height: 200,
                                                child: ListView.builder(
                                                  itemCount:
                                                      _suggestions.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return ListTile(
                                                      title: Text(
                                                          _suggestions[index]),
                                                      onTap: () {
                                                        setState(() {
                                                          _instcontroller
                                                                  .text +=
                                                              _suggestions[
                                                                  index];
                                                          _suggestions = [];
                                                        });
                                                      },
                                                    );
                                                  },
                                                ),
                                              )
                                            : Container(),
                                      ]),
                                      TextFormField(
                                        controller: _durationcontroller,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        autofocus: true,
                                        decoration: const InputDecoration(
                                            labelText: 'Duration'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter duration';
                                          }
                                          return null;
                                        },
                                      ),
                                    ])),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Add'),
                                      onPressed: () {
                                        final form = _formKey.currentState!;
                                        if (form.validate()) {
                                          form.save();
                                          Instruction S = Instruction(
                                              duration: int.parse(
                                                  _durationcontroller.text),
                                              desc: _instcontroller.text,
                                              ingredients: []);
                                          setState(() {
                                            _instructions.add(S);
                                          });    
                                          
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
                    print(_instructions);
                    return ListTile(
                      title: Text(_instructions[index].desc),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _instructions.removeAt(index);
                          });
                        },
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: const Text('Save Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
