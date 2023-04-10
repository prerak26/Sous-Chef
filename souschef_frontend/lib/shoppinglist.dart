import 'package:flutter/material.dart';
import 'package:souschef_frontend/login.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/signup.dart';



//import 'package:souschef_frontend/signup.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});
  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  
  @override
  Widget build(BuildContext context) {
    if(!session.isLogged){
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
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body:const Text(
  'shoppping list',
  textAlign: TextAlign.center,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(fontWeight: FontWeight.bold),
),
    );
  }
}
