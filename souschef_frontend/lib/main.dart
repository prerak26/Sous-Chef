import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:souschef_frontend/route_generator.dart';

class Ingredient {
  int id;
  double? quantity;
  String name;
  String? kind = "gram";
  Ingredient({required this.id, this.quantity, required this.name, this.kind});
  Map<String, dynamic> toJson() => {
        'id': id,
        'quantity': quantity,
        'kind': kind,
        'name': name,
      };
}

class Instruction {
  String desc;

  Instruction({required this.desc});
  Map<String, dynamic> toJson() => {
        'desc': desc,
      };
}

class Recipe {
  String title;
  int serves;
  bool isPublic = false;
  List<Instruction> steps = [];
  List<Tag> tags = [];
  List<Ingredient> ingredients = [];
  String duration;

  Recipe({
    required this.title,
    required this.serves,
    required this.isPublic,
    required this.steps,
    required this.tags,
    required this.ingredients,
    required this.duration,
  });
  Map<String, dynamic> toJson() => {
        'title': title,
        'serves': serves,
        'isPublic': isPublic,
        'steps': steps.map((step) => step.toJson()).toList(),
        'tags': tags.map((tag) => tag.toJson()).toList(),
        'ingredients':
            ingredients.map((ingredient) => ingredient.toJson()).toList(),
        'duration': duration,
      };
}

class Tag {
  int tagid;
  String name;
  Tag({required this.tagid, required this.name});
  Map<String, dynamic> toJson() => {
        'id': tagid,
        'name': name,
      };
}

class User {
  final String? chefid;
  final String? name;
  User({this.chefid, this.name});
}

void main() {
  runApp(const MyApp());
}

class Cards {
  int recipeid;
  String title;
  int serves;
  String authorid;
  double? rating;
  String duration;
  Cards({
    required this.recipeid,
    required this.title,
    required this.serves,
    required this.authorid,
    this.rating,
    required this.duration,
  });
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
  // String baseUrl = "https://sous-chef-backend.onrender.com";

  Future<http.Response> get(String path) async {
    headers['userid'] = session.id ?? "";
    headers['pswd'] = session.pswd ?? "";
    http.Response response =
        await http.get(Uri.parse(baseUrl + path), headers: headers);
    updateCookie(response);
    return response;
  }

  Future<http.Response> delete(String path) async {
    headers['userid'] = session.id ?? "";
    headers['pswd'] = session.pswd ?? "";

    http.Response response =
        await http.delete(Uri.parse(baseUrl + path), headers: headers);
    updateCookie(response);
    return response;
  }

  Future<http.Response> post(String path, dynamic data) async {
    headers['Content-Type'] = 'application/json';
    headers['charset'] = 'UTF-8';
    headers['userid'] = session.id ?? "";
    headers['pswd'] = session.pswd ?? "";
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
      debugShowCheckedModeBanner: false,
      title: 'SousChef',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
