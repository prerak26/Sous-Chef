import 'dart:convert';
import 'dart:math';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:souschef_frontend/main.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class RecipeForm extends StatefulWidget {
  final int recipeId;
  const RecipeForm({super.key, required this.recipeId});

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

  Future<String> _fetchstep(step) async {
    final String apiUrl = '/step/${widget.recipeId}/$step';
    final response = await currSession.get(apiUrl);

    String k = "ERROR";

    if (response.statusCode == 200) {
      k = jsonDecode(response.body)["description"];
    }

    return k;
  }

  Future<Map<String, dynamic>> _fetchrecipe() async {
    if (widget.recipeId != -1) {
      final String apiUrl = '/recipe/${widget.recipeId}';
      final response = await currSession.get(apiUrl);

      if (response.statusCode == 200) {
        dynamic t = jsonDecode(response.body);

        if (widget.recipeId != -1) {
          _nameController.text = t!['title'];
          _servesController.text = '${t!['serves']}';

          //print(t!['serves']);
          t!['tags'].forEach((item) {
            _searchController.text += '${item['name']},';
          });

          t!['requirements'].forEach((item) {
            _ingredientController.text += '${item['name']},';
            Ingredient i = Ingredient(
                id: item['ingredientid'],
                name: item['name'],
                kind: item['kind'],
                quantity: double.tryParse(item['quantity']));
            ingredientsub.add(i);
          });
        }

        for (var i = 0; i < int.parse(t!['stepcount']); i++) {
          var res = await _fetchstep(i + 1);
          Instruction k = Instruction(desc: res);
          _instructions.add(k);
        }
        _durationcontroller.text =
            '${t!['duration']['hours'] ?? 00}:${t!['duration']['minutes'] ?? 00}';
        return t;
      } else {
        throw Exception('Failed to load recipe/${widget.recipeId}');
      }
    } else {
      return {"": ""};
    }
  }

  Future<List<Tag>> _fetchSuggestions(String query) async {
    final String apiUrl = '/tag?key=$query';
    final response = await currSession.get(apiUrl);
    if (response.statusCode == 200) {
      List<dynamic> t = jsonDecode(response.body);

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
    const String apiUrl = '/tag';
    final response =
        await currSession.post(apiUrl, json.encode({'name': value}));
    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to add new value');
    }
  }

  Future<List<Ingredient>> _fetchIngredients(String query) async {
    final String apiUrl = '/ingredient?key=$query';
    final response = await currSession.get(apiUrl);

    if (response.statusCode == 200) {
      List<dynamic> t = jsonDecode(response.body);

      List<Ingredient> l = t.map((ingredientData) {
        return Ingredient(
          id: ingredientData['ingredientid'],
          name: ingredientData['name'],
          kind: ingredientData['kind'],
        );
      }).toList();

      Ingredient def = Ingredient(id: -1, name: "Add New Ingredient");
      l.add(def);

      return l;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> _addIngredient(String value, String kind) async {
    const String apiUrl = '/ingredient';

    final response = await currSession.post(
        apiUrl, json.encode({'name': value, 'kind': kind}));

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to add new value');
    }
  }

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _ingredientNameController =
      TextEditingController();
  final TextEditingController _ingredientKindController =
      TextEditingController();
  String selectedIngredient = "";
  String selectedtag = "";

  // void onChange() {
  //   _fetchSuggestions(_searchController.text);
  // }

  //final list of tags and ingredients to be posted
  List<Tag> tagsub = [];
  List<Ingredient> ingredientsub = [];

  @override
  initState() {
    super.initState();
    _fetchrecipe().then((value) {setState(() {
      
    });});
  }

  // tag auto complete widget
  Widget tagcomp(BuildContext context) {
    List<String> k;
    return Column(children: [
      TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: _searchController,
              autofocus: false,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontStyle: FontStyle.italic),
              decoration: const InputDecoration(
                  labelText: 'Tags', border: OutlineInputBorder())),
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
              autofocus: false,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontStyle: FontStyle.italic),
              decoration: const InputDecoration(
                  labelText: 'Ingredients', border: OutlineInputBorder())),
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
                  content: Column(children: [
                    TextFormField(
                      controller: _quantityController,
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
                          _ingredientController.text =
                              '${k.join(',')},${sugesstion.name},';
                          Ingredient sub = sugesstion;
                          sub.quantity = double.parse(_quantityController.text);
                          ingredientsub.add(sub);
                        });
                      },
                    ),
                  ],
                ),
              );
            } else {
              k = _ingredientController.text.split(',');
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add new value?'),
                  content: Column(children: [
                    TextFormField(
                      controller: _ingredientNameController,
                      autofocus: false,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name of the ingredient';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _ingredientKindController,
                      autofocus: false,
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

                        _addIngredient(_ingredientNameController.text,
                            _ingredientKindController.text);
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

  String ptDuration = "";
  Recipe recipe = Recipe(
      title: "",
      serves: 0,
      isPublic: true,
      steps: [],
      tags: [],
      ingredients: [],
      duration: "");

  void _saveRecipe() async {
    //if(widget.recipeId==-1){
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
      recipe.ingredients = ingredientsub;
      recipe.duration = ptDuration;

      print(jsonEncode(recipe.toJson()));

      var response = (widget.recipeId == -1)
          ? await currSession.post('/recipe', jsonEncode(recipe.toJson()))
          : await currSession.post(
              '/recipe/${widget.recipeId}', jsonEncode(recipe.toJson()));
      if (response.statusCode == 200) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //print(widget.recipeId);
    return Scaffold(
      appBar: AppBar(
        title: (widget.recipeId == -1)
            ? const Text('Add Recipe')
            : const Text("Update Recipe"),
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

              LimitedBox(
                  maxHeight: 200,
                  child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: ingredientsub.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                              '${ingredientsub[index].name} ${ingredientsub[index].quantity} ${ingredientsub[index].kind}'),
                          trailing:
                              //SizedBox(width: 0, child:
                              Wrap(
                            spacing: 10,
                            //mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      ingredientsub.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.delete)),
                              IconButton(
                                  onPressed: () async {
                                    _quantityController.text =
                                        '${ingredientsub[index].quantity}';
                                    await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Quantity'),
                                        content: Column(children: [
                                          TextFormField(
                                            controller: _quantityController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            autofocus: true,
                                            decoration: InputDecoration(
                                                labelText:
                                                    'Quantity in ${ingredientsub[index].kind}'),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter a quantity';
                                              }
                                              return null;
                                            },
                                          ),
                                        ]),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                          TextButton(
                                            child: const Text('Add'),
                                            onPressed: () {
                                              Navigator.of(context).pop();

                                              setState(() {
                                                ingredientsub[index].quantity =
                                                    double.parse(
                                                        _quantityController
                                                            .text);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit))
                            ],
                            //)
                          ),
                        );
                      })),
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
                                          autofocus: false,
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
                                        //_suggestions.isNotEmpty

                                        Container(),
                                      ]),
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
                                            desc: _instcontroller.text,
                                          );
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
                  } else {
                    return ListTile(
                      onTap: () async {
                        {
                          final instruction = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              _instcontroller.text = _instructions[index].desc;
                              return SimpleDialog(
                                title: const Text('Edit Instruction'),
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Column(children: [
                                        Column(children: [
                                          TextFormField(
                                            controller: _instcontroller,
                                            autofocus: false,
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
                                          //_suggestions.isNotEmpty

                                          Container(),
                                        ]),
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

                                            setState(() {
                                              _instructions[index].desc =
                                                  _instcontroller.text;
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
                        }
                        ;
                      },
                      title: Text(_instructions[index].desc),
                      trailing: Wrap(children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _instructions.removeAt(index);
                            });
                          },
                        ),
                      ]),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              TextField(
                  controller:
                      _durationcontroller, //editing controller of this TextField
                  decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today), //icon of text field
                      labelText: "Enter Duration" //label text of field
                      ),
                  readOnly:
                      true, //set it true, so that user will not able to edit text
                  onTap: () {
                    Picker(
                      adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
                        const NumberPickerColumn(
                            begin: 0, end: 999, suffix: Text(' hours')),
                        const NumberPickerColumn(
                            columnFlex: 1,
                            begin: 0,
                            end: 60,
                            suffix: Text(' min'),
                            jump: 15),
                      ]),
                      delimiter: <PickerDelimiter>[
                        PickerDelimiter(
                          child: Container(
                            width: 50.0,
                            alignment: Alignment.center,
                            child: Icon(Icons.more_vert),
                          ),
                        )
                      ],
                      hideHeader: true,
                      confirmText: 'OK',
                      confirmTextStyle: TextStyle(
                          inherit: false, color: Colors.red, fontSize: 15),
                      title: const Text('Select duration'),
                      selectedTextStyle: TextStyle(color: Colors.blue),
                      onConfirm: (Picker picker, List<int> value) {
                        // You get your duration here
                        Duration _duration = Duration(
                            hours: picker.getSelectedValues()[0],
                            minutes: picker.getSelectedValues()[1]);
                        _durationcontroller.text =
                            "${picker.getSelectedValues()[0]}:${picker.getSelectedValues()[1]}";
                        setState(() {
                          ptDuration =
                              "PT${picker.getSelectedValues()[0]}H${picker.getSelectedValues()[1]}M";
                        });
                      },
                    ).showDialog(context);
                  }),

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
