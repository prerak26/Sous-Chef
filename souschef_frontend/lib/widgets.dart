import 'package:flutter/material.dart';
import 'package:souschef_frontend/recipe.dart';

Widget authorisationPage(BuildContext context, String caller) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Authorisation'),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          ElevatedButton(
            onPressed: () =>
                {Navigator.of(context).pushNamed('/login', arguments: caller)},
            child: const Text('Login'),
          ),
          ElevatedButton(
            onPressed: () =>
                {Navigator.of(context).pushNamed('/signup', arguments: caller)},
            child: const Text('Register'),
          ),
        ]),
      ),
    ),
  );
}

void _onCardTap(int id, BuildContext context,obj) {
 Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => RecipePage(recipeId: id)))
        .then((_){obj.setState(() {});});
}

Widget recipeCards(data,obj) {
  return ListView.builder(
    itemCount: data.length,
    itemBuilder: (context, index) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _onCardTap(data[index].recipeid, context,obj),
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
