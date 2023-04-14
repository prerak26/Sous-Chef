import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:souschef_frontend/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  final String caller;
  const LoginView({super.key, required this.caller});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  void _loadCredentials() async {
    //SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString("username") ?? "";
      _passwordController.text = prefs.getString("password") ?? "";
      _rememberMe = prefs.getBool("rememberMe") ?? false;
    });
  }

  void _saveCredentials() async {
    //SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", _usernameController.text);
    await prefs.setString("password", _passwordController.text);
    await prefs.setBool("rememberMe", _rememberMe);
  }

  void _login() async {
    var response = await currSession.post(
        'http://localhost:3001/login',
        json.encode({
          'id': _usernameController.text,
          'pswd': _passwordController.text,
        }));
    if (context.mounted) {
      if (response.statusCode == 200) {
        session.isLogged = true;
        session.id = _usernameController.text;
        session.pswd = _passwordController.text;
        if (_rememberMe == true) {
          _saveCredentials();
        }
        Navigator.of(context).pushNamed('/', arguments: widget.caller);
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid username or password.'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Somthing went wrong.'),
        ));
      }
    }
  }

  void _signup() {
    Navigator.of(context)
        .pushReplacementNamed('/signup', arguments: widget.caller);
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
              controller: _usernameController,
              onChanged: (value) {
                setState(() {
                  //_username = value.trim();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter username',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  //_password = value.trim();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter password',
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value!;
                    });
                  },
                ),
                const Text("Remember me"),
              ],
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
