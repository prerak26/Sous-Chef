import 'package:flutter/material.dart';
import 'package:souschef_frontend/recipe.dart';

Widget authorisationPage(BuildContext context, String caller) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Authorisation'),
      backgroundColor: caller == "home" ? Colors.lightGreen : Colors.deepOrange,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () => {
                Navigator.of(context).pushNamed('/login', arguments: caller)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    caller == "home" ? Colors.lightGreen : Colors.deepOrange,
              ),
              child: const Text('Login'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () => {
                Navigator.of(context).pushNamed('/signup', arguments: caller)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    caller == "home" ? Colors.lightGreen : Colors.deepOrange,
              ),
              child: const Text('Register'),
            ),
          ),
        ]),
      ),
    ),
  );
}

void _onCardTap(int id, BuildContext context, obj, caller) {
  Navigator.of(context)
      .push(MaterialPageRoute(
          builder: (context) => RecipePage(
                recipeId: id,
                caller: caller,
              )))
      .then((_) {
    obj.setState(() {});
  });
}

Widget recipeCards(data, obj, caller) {
  return ListView.builder(
    itemCount: data.length,
    itemBuilder: (context, index) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _onCardTap(data[index].recipeid, context, obj, caller),
          child: Card(
            child: ListTile(
              title: Text(data[index].title),
              subtitle: Text(
                  'By ${data[index].authorid} - Serves ${data[index].serves}'),
            ),
          ),
        ),
      );
    },
  );
}
