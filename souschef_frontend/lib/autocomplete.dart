
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class AutocompleteDropdown extends StatefulWidget {
  const AutocompleteDropdown({super.key});
  @override
  State<AutocompleteDropdown> createState() => _AutocompleteDropdownState();
}

class _AutocompleteDropdownState extends State<AutocompleteDropdown> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedItem;
  bool _isLoading = false;
  List<String> _suggestedItems = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          onChanged: (text) {
            setState(() {
              if (text.endsWith(";")) {
                String query = text.substring(text.lastIndexOf(";") + 1).trim();
                _isLoading = true;
                _suggestedItems = [];
                _fetchSuggestions(query);
              } else {
                _isLoading = false;
                _suggestedItems = [];
              }
            });
          },
        ),
        
        if (_isLoading)
          CircularProgressIndicator()
        else if (_suggestedItems.isNotEmpty)
          DropdownButtonFormField<String>(
            value: _selectedItem,
            items: _suggestedItems
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedItem = value;
                _controller.text = _controller.text.substring(0, _controller.text.lastIndexOf(";") + 1) + value!;
              });
            },
          )
      else const Text("error")
      ],
    );
  }

  Future<void> _fetchSuggestions(String query) async {
    // make an API call to fetch suggestions based on the query
    // replace the API URL and headers with your own
    final response = await http.get(
      
      Uri.parse("https://example.com/suggestions?q=$query"),
      headers: {"Authorization": "Bearer <YOUR_AUTH_TOKEN>"},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _suggestedItems = List<String>.from(data["suggestions"]);
        _isLoading = false;
      });
    }
  }
}
