import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:souschef_frontend/recepieform.dart';
import 'dart:convert';

import 'main.dart';

class AutocompleteForm extends StatefulWidget {
  const AutocompleteForm({super.key});
  @override
  State<AutocompleteForm> createState() => _AutocompleteFormState();
}

class _AutocompleteFormState extends State<AutocompleteForm> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedValue = '';

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
    print(response);
    if (response.statusCode == 200) {
      setState(() {
        _selectedValue = value;
      });
    } else {
      throw Exception('Failed to add new value');
    }
  }

  Widget tagcomp(BuildContext){
    return  Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter a value',
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Tag>>(
              future: _fetchSuggestions(_searchController.text),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final suggestions = snapshot.data!;

                  return ListView.builder(
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(suggestions[index].name),
                      onTap: () {
                        if (suggestions.contains("ADD NEW TAG")) {
                          setState(() {
                            _selectedValue = suggestions[index].name;
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
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          if (_selectedValue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Selected value: $_selectedValue'),
            ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Autocomplete Form'),
      ),
      body: tagcomp(BuildContext),
    );
  }
}
