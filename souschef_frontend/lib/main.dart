import 'package:flutter/material.dart';
import 'package:souschef_frontend/navigation.dart';
import 'package:http/http.dart' as http;

class Ingredient {
  int id;
  String quantity;
  String name;
  Ingredient({required this.id, required this.quantity, required this.name});
  Map<String, dynamic> toJson() => {
        'id': id,
        'quantity': quantity,
      };
}

class Instruction {
  int duration;
  String desc;
  List<Ingredient> ingredients = [];
  Instruction(
      {required this.duration, required this.desc, required this.ingredients});
  Map<String, dynamic> toJson() => {
        'duration': duration,
        'desc': desc,
        'ingredients':
            ingredients.map((ingredient) => ingredient.toJson()).toList(),
      };
}

class Recipe {
  String title;
  int serves;
  bool isPublic = false;
  List<Instruction> steps = [];
  List<Tag> tags = [];
  Recipe(
      {required this.title,
      required this.serves,
      required this.isPublic,
      required this.steps,
      required this.tags});
  Map<String, dynamic> toJson() => {
        'title': title,
        'serves': serves,
        'isPublic': isPublic,
        'steps': steps.map((step) => step.toJson()).toList(),
        'tags': tags.map((tag) => tag.toJson()).toList(),
      };
}

class Tag {
  int tagid;
  String name;
  Tag({required this.tagid, required this.name});
  Map<String, dynamic> toJson() => {
        'tagid': tagid,
        'name': name,
      };
}

void main() {
  runApp(const MyApp());
}

class Globals {
  bool isLogged;
  String? id;
  String? pswd;
  Globals({required this.isLogged, this.id, this.pswd});
}

Globals session = Globals(isLogged: false, id: "", pswd: "");

class Session {
  Map<String, String> headers;
  Session({required this.headers});

  Future<http.Response> get(String url) async {
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    updateCookie(response);
    return response;
  }

  Future<http.Response> delete(String url) async {
    http.Response response =
        await http.delete(Uri.parse(url), headers: headers);
    updateCookie(response);
    return response;
  }

  Future<http.Response> post(String url, dynamic data) async {
    headers['Content-Type'] = 'application/json';
    headers['charset'] = 'UTF-8';
    http.Response response =
        await http.post(Uri.parse(url), body: data, headers: headers);
    updateCookie(response);
    return response;
  }

  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}

Session currSession = Session(headers: {});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SousChef',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const NavigationWidget(),
      },
    );
  }
}
