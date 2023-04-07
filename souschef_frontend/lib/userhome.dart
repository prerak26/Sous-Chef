import 'package:flutter/material.dart';

//import 'package:souschef_frontend/signup.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});
  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipies'),
      ),
      body:const Text(
  'My Recepies',
  textAlign: TextAlign.center,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(fontWeight: FontWeight.bold),
)
    );
  }
}
