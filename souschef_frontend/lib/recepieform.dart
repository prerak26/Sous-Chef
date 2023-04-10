import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
//import 'package:my_recipe_app/models/recipe.dart';

class Recipe{
  String? name;
  int? serves;
  bool isPublic = false;
  List<String> ingredients = [];
  List<String> instructions = [];
  //Recipe(String? _name,List<String>_ingredients,List<String>_instructions){
  //  name = _name;
  //  ingredients = _ingredients;
  //  instructions = _instructions;
  //}
}

class RecipeForm extends StatefulWidget {
  @override
  _RecipeFormState createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  String? _imageUrl;
  List<String> _ingredients = [];
  List<String> _instructions = [];
  String? temp;
  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final recipe = Recipe(
        //_name!,
        //imageUrl: _imageUrl!,
        //_ingredients,
        //_instructions,
      );
      // Save the recipe data to your app's data store here
      Navigator.pop(context);
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
                decoration: InputDecoration(labelText: 'Recipe Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for the recipe';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL for the recipe';
                  }
                  return null;
                },
                onSaved: (value) {
                  _imageUrl = value!;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == _ingredients.length) {
                    return ListTile(
                      title: Text('Add Ingredient'),
                      leading: Icon(Icons.add),
                      onTap: () async {
                        final ingredient = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: Text('Add Ingredient'),
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: TextFormField(
                                    autofocus: true,
                                    decoration: InputDecoration(
                                        labelText: 'Ingredient'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        
                                        return 'Please enter an ingredient';
                                      }
                                      //else{temp = value;}
                                      return value;
                                    },
                                  ),
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
                                        final form =
                                            _formKey.currentState!;
                                        if (form.validate()) {
                                          form.save();
                                          _ingredients.add("");
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
                      title: Text(_ingredients[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
setState(() {
_ingredients.removeAt(index);
});
},
),
);
}
},
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
horizontal: 16, vertical: 8),
child: TextFormField(
autofocus: true,
decoration: InputDecoration(
labelText: 'Instruction'),
validator: (value) {
if (value == null || value.isEmpty) {
return 'Please enter an instruction';
}
else {temp = value;}
return null;
},
),
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
final form =
_formKey.currentState!;
if (form.validate()) {
form.save();
_instructions.add(temp!);
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
title: Text(_instructions[index]),
trailing: IconButton(
icon: Icon(Icons.delete),
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
