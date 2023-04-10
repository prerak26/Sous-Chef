import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:souschef_frontend/apphome.dart';
import 'package:souschef_frontend/myrecipieholder.dart';
import 'package:souschef_frontend/signup.dart';
import 'package:http/http.dart' as http;



void main() {
  runApp(const MyApp());
}

class Globals{
  bool isLogged;
  String? id;
  String? pswd;
  Globals({required this.isLogged,this.id,this.pswd});
}

Globals session = Globals(isLogged:false,id:"",pswd:"");

class Session {
  Map<String, String> headers;
  Session({required this.headers});
  Future<http.Response> get(String url) async {
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    
    updateCookie(response);
    return response;
  }

  Future<http.Response> post(String url, dynamic data) async {
    
    
    http.Response response =
        await http.post(Uri.parse(url), body: data, headers: headers);
    updateCookie(response);
    print(data);
    //print()
    
    return response;
  }

  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
    headers['Content-Type'] =  'application/json'; 
    headers['charset']='UTF-8';
  }
  
}

Session curr_session = Session(headers: {});
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



