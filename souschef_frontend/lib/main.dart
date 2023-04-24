import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:souschef_frontend/route_generator.dart';

class Ingredient {
  int id;
  int? quantity = 0;
  String name;
  String? kind = "gram";
  Ingredient(
      {required this.id,
      this.quantity,
      required this.name,
      this.kind}
    );
  Map<String, dynamic> toJson() => {
        'id': id,
        'quantity': quantity,
        'kind' : kind,
        'name' : name,
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
  String baseUrl = "http://localhost:3001";

  Future<http.Response> get(String path) async {
    http.Response response =
        await http.get(Uri.parse(baseUrl + path), headers: headers);
    updateCookie(response);
    return response;
  }

  Future<http.Response> delete(String path) async {
    http.Response response =
        await http.delete(Uri.parse(baseUrl + path), headers: headers);
    updateCookie(response);
    return response;
  }

  Future<http.Response> post(String path, dynamic data) async {
    headers['Content-Type'] = 'application/json';
    headers['charset'] = 'UTF-8';
    http.Response response = await http.post(Uri.parse(baseUrl + path),
        body: data, headers: headers);
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
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
