import 'package:flutter/material.dart';
import 'package:souschef_frontend/apphome.dart';
import 'package:souschef_frontend/signup.dart';




void main() {
  runApp(const MyApp());
}

class Globals{
  bool isLogged = false;
  var id  = "";
  var pswd = "";
  Globals(){
    isLogged = false;
    id = "";
    pswd = "";
  }
}

Globals session = Globals();

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
        '/':(context) => const MyHomePage(),
        //'/recipes':(context) => const MaterialApp(home : RecipeList()),
        //'/signup': (context) => const UserRegistrationPage(),
        
      },
      
    );
  }
}



