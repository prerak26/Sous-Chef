import 'package:flutter/material.dart';
import 'package:souschef_frontend/login.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/userhome.dart';

//import 'package:souschef_frontend/signup.dart';

class placePage extends StatefulWidget {
  const placePage({super.key});
  @override
  State<placePage> createState() => _placePageState();
}

class _placePageState extends State<placePage> {
  
  @override
  Widget build(BuildContext context) {
    if(session.isLogged){
      return const UserHomePage();
    }
    
    return const LoginPage();
    
    
  }
}