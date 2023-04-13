import 'package:flutter/material.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/widgets.dart';
import 'package:souschef_frontend/home.dart';

class AuthHomePage extends StatefulWidget {
  const AuthHomePage({super.key});
  @override
  State<AuthHomePage> createState() => _AuthHomePageState();
}

class _AuthHomePageState extends State<AuthHomePage> {
  @override
  Widget build(BuildContext context) {
    if (session.isLogged) {
      return const HomePage();
    }
    return authorisationPage(context);
  }
}
