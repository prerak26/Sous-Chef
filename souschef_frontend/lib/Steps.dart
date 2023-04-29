import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:souschef_frontend/main.dart';

class StepsView extends StatefulWidget {
  final int recipeId;
  final int maxsteps;
  const StepsView({super.key, required this.recipeId, required this.maxsteps});
  @override
  State<StepsView> createState() => _StepsViewState();
}

class _StepsViewState extends State<StepsView> {
  int index = 1;
  int new_rating = 0;
  Future<String> _fetchstep() async {
    final String apiUrl = '/step/${widget.recipeId}/$index';
    final response = await currSession.get(apiUrl);

    String k = "ERROR";

    if (response.statusCode == 200) {
      k = jsonDecode(response.body)["description"];
    }

    return k;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _fetchstep(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Scaffold(
  appBar: AppBar(
    title: (index == widget.maxsteps + 1) 
      ? const Text("Rate Recipe")
      : Text("Step $index"),
  ),
  body: (index == widget.maxsteps + 1)
    ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Center(
          child: RatingBar.builder(
            initialRating: 1,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) async {
              new_rating = rating.toInt();
            },
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () async {
              var response = await currSession.post(
                '/rating/${widget.recipeId}',
                json.encode({'rating': new_rating})
              );
              if (response.statusCode == 200) {
                Navigator.pop(context);  
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.amber,
              primary: Colors.white,
            ),
            child: const Text("Rate Recipe", style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    )
    : Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Text(snapshot.data!, style: TextStyle(fontSize: 30)),
        ),
        Padding(padding: const EdgeInsets.all(20),
              child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            
            (index != 1)
              ? TextButton(
                child: const Text('Prev Step', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  setState(() {
                    index -= 1;
                  });
                },
              )
              : TextButton(
                child: const Text('Back to Recipe Page', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            (index != widget.maxsteps)
              ? TextButton(
                child: const Text('Next Step', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  setState(() {
                    index += 1;
                  });
                },
              )
              : TextButton(
                child: const Text('Rate Recipe', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  setState(() {
                    index += 1;
                  });
                },
              ),
          ]
        ),
            ),
        
      ],
    ),
)


              : const Center(child: CircularProgressIndicator());
        });
  }
}
