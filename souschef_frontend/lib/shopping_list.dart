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
  bool _latest = false;

  Future<List<Ingredient>> _fetchShoppingList() async {
    Response response = await currSession.get("/shoppinglist");
    List<dynamic> body = json.decode(response.body);
    List<Ingredient> shoppingList = body
        .map((e) => Ingredient(
            id: e["ingredientid"],
            quantity: double.parse(e["quantity"]),
            name: e["name"],
            kind: e["kind"]))
        .toList();
    _latest = true;
    return shoppingList;
  }

  Future<List<Ingredient>> _fetchSuggestions(query) async {
    Response response = await currSession.get("/ingredient?key=$query");
    List<dynamic> body = json.decode(response.body);
    List<Ingredient> suggestedIngredients = body
        .map((e) => Ingredient(
            id: e["ingredientid"],
            quantity: 0.0,
            kind: e["kind"],
            name: e["name"]))
        .toList();
    return suggestedIngredients;
  }

  Future<int> _saveItem(Ingredient item) async {
    Response response = await currSession.post(
        "/shoppinglist/${item.id}", jsonEncode(item.toJson()));
    return response.statusCode;
  }

  Future<int> _removeItem(Ingredient item) async {
    Response response = await currSession.delete("/shoppinglist/${item.id}");
    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    if (!session.isLogged) {
      return authorisationPage(context, "shopping-list");
    }
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              var response = await currSession.get("/logout");
              if (response.statusCode == 200) {
                setState(() {
                  session.isLogged = false;
                  session.id = null;
                  session.pswd = null;
                });
              }
            },
          ),
        ],
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
          return Container(
            color: Colors.amber,
            child: Center(
              child: _shoppingListItem(items[index]),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }

  Widget _shoppingListItem(item) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(
                  text: item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ', ${item.quantity} ${item.kind}')
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            if (await _removeItem(item) == 200) {
              setState(() {
                _latest = false;
              });
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Failed to delete item.'),
              ));
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            setState(() {
              _newItemId = item.id;
              _newItemName.text = item.name;
            });
          },
        ),
      ),
    ]);
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
                hintText: 'Enter ingredient',
                border: OutlineInputBorder(),
              ),
            ),
            suggestionsCallback: (pattern) async {
              return await _fetchSuggestions(pattern);
            },
            itemBuilder: (context, itemData) {
              return ListTile(
                title: Text("${itemData.name} in ${itemData.kind}"),
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
            ],
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
                        quantity: double.parse(_newItemQuantity.text),
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
                    content: Text('Failed to add item.'),
                  ));
                }
              }
            },
            child: const Text("Add/Edit Item"),
          ),
        ),
      ]),
    );
  }
}
