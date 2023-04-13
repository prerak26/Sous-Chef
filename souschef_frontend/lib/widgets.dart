import 'package:flutter/material.dart';
import 'package:souschef_frontend/signup.dart';
import 'package:souschef_frontend/login.dart';

Widget authorisationPage(context) {
  return Scaffold(
    body: Center(
        child: Column(
      children: [
        ElevatedButton(
          onPressed: () => {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginPage()))
          },
          child: const Text('Login'),
        ),
        ElevatedButton(
          onPressed: () => {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SignupPage()))
          },
          child: const Text('Register'),
        ),
      ],
    )),
  );
}
