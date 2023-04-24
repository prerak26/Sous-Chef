import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/widgets.dart';

class ShoppingListView extends StatefulWidget {
  const ShoppingListView({super.key});
  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class IngredientSuggestion {
  int id;
  String kind;
  String name;
  IngredientSuggestion(
      {required this.id, required this.kind, required this.name});
  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
      };
}

class _ShoppingListViewState extends State<ShoppingListView> {
  final _newItemName = TextEditingController();
  final _newItemQuantity = TextEditingController();
  int _newItemId = -1;

  Future<List<Ingredient>> _fetchShoppingList() async {
    Response response =
        await currSession.get("http://localhost:3001/shoppinglist");
    List<dynamic> body = json.decode(response.body);
    List<Ingredient> shoppingList = body
        .map((e) => Ingredient(
            id: e["ingredientid"],
            quantity: e["quantity"],
            name: e["name"],
            kind: e["kind"]))
        .toList();
    return shoppingList;
  }

  Future<List<Ingredient>> _fetchIngredientList(query) async {
    Response response =
        await currSession.get("http://localhost:3001/ingredient?key=$query");
    List<dynamic> body = json.decode(response.body);
    List<Ingredient> suggestedIngredients = body
        .map((e) => Ingredient(
            id: e["ingredientid"],
            quantity: 0,
            kind: e["kind"],
            name: e["name"]))
        .toList();
    return suggestedIngredients;
  }

  Future<int> _saveItem(Ingredient item) async {
    Response response = await currSession.post(
        "http://localhost:3001/shoppinglist/${item.id}",
        jsonEncode(item.toJson()));
    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    if (!session.isLogged) {
      return authorisationPage(context, "shopping-list");
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Shopping List'),
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder(
            future: _fetchShoppingList(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          _newItemWidget(),
                          _shoppingList(snapshot.data)
                        ])
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            }));
  }

  Widget _shoppingList(items) {
    return Flexible(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          Ingredient item = items[index];
          return Container(
            height: 50,
            color: Colors.amber,
            child: Center(
                child: item.kind == "whole"
                    ? Text('${item.quantity} ${item.name}')
                    : Text('${item.quantity} ${item.kind} of ${item.name}')),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }

  Widget _newItemWidget() {
    return Center(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _newItemName,
              decoration: const InputDecoration(
                hintText: 'Add new ingredient',
                border: OutlineInputBorder(),
              ),
            ),
            suggestionsCallback: (pattern) async {
              return await _fetchIngredientList(pattern);
            },
            itemBuilder: (context, itemData) {
              return ListTile(
                title: itemData.kind == "whole"
                    ? Text("${itemData.name} as ${itemData.kind}")
                    : Text("${itemData.name} in ${itemData.kind}"),
              );
            },
            onSuggestionSelected: (suggestion) {
              _newItemName.text = suggestion.name;
              _newItemId = suggestion.id;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _newItemQuantity,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: 'Enter quantity',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              if (_newItemId != -1 && _newItemQuantity.text != "") {
                if ((await _saveItem(Ingredient(
                        id: _newItemId,
                        quantity: int.parse(_newItemQuantity.text),
                        kind: "",
                        name: _newItemName.text))) ==
                    200) {
                  setState(() {
                    _newItemId = -1;
                    _newItemName.clear();
                    _newItemQuantity.clear();
                  });
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Failed to add item'),
                  ));
                }
              }
            },
            child: const Text("Add Item"),
          ),
        ),
      ]),
    );
  }
}
