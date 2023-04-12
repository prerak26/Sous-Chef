import 'package:flutter/material.dart';
import 'package:souschef_frontend/autocomplete.dart';
import 'package:souschef_frontend/login.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/recepieform.dart';
import 'package:souschef_frontend/signup.dart';
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
    return Scaffold(
      body: Center(
        child:Column(children: [ElevatedButton(
              onPressed: ()=>{Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage()))},
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: ()=>{Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserRegistrationPage()))},
              child: const Text('Register'),
            ),],) 
      ),
    );
    //return const LoginPage();
    
    
  }
}