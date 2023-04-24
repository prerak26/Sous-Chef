import 'package:flutter/material.dart';

class RecipePage extends StatefulWidget {
  final String recipieId;
  const RecipePage({super.key, required this.recipieId});
  @override
  State<RecipePage> createState() => _RecipePageState();
}



class _RecipePageState extends State<RecipePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'https://www.example.com/${recipe.title.toLowerCase().replaceAll(' ', '_')}.jpg',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipe.steps
                        .expand((step) => step.ingredients)
                        .map((ingredient) => Text(
                              '- ${ingredient.quantity} ${ingredient.kind} ${ingredient.name}',
                              style: TextStyle(fontSize: 16),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Instructions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipe.steps
                        .asMap()
                        .map((index, step) => MapEntry(
                            index,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Step ${index + 1}',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(step.desc, style: TextStyle(fontSize: 16)),
                                SizedBox(height: 10),
                              ],
                            )))
                        .values
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}