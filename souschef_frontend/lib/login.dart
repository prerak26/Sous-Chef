import 'package:flutter/material.dart';

import 'package:souschef_frontend/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _username = '';
  String _password = '';

  void _login(){
    if(_username == 'username' && _password == 'password'){
      Navigator.pushReplacementNamed(context, '/');
    }
    
  }
  void _signup(){
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  _username = value.trim();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter username',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _password = value.trim();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: _signup,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
