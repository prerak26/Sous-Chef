import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:souschef_frontend/main.dart';

class SignupView extends StatefulWidget {
  final String caller;
  const SignupView({super.key, required this.caller});
  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  void _registerUser() async {
    var response = await currSession.post(
        '/signup',
        json.encode({
          'name': _nameController.text,
          'id': _idController.text,
          'pswd': _passwordController.text,
        }));

    void saveCredentials() async {
      //SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("username", _idController.text);
      await prefs.setString("password", _passwordController.text);
      await prefs.setBool("rememberMe", _rememberMe);
    }

    if (context.mounted) {
      if (response.statusCode == 200) {
        session.isLogged = true;
        session.id = _idController.text;
        if (_rememberMe == true) {
          saveCredentials();
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User registration sucessful.'),
        ));
        Navigator.of(context)
            .pushNamed('/', arguments: widget.caller)
            .then((value) => setState(() {}));
      } else if (response.statusCode == 403) {
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User registration failed.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Id',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your Id';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _registerUser();
                    }
                  },
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
