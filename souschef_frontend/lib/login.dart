import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/myrecipieholder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:requests/requests.dart';
//import 'package:shared_preferences_web/shared_preferences_web.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //String _username = '';
  //String _password = '';

  //final _formKey = GlobalKey<FormState>();
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


  void _login() async{
    
    var response = await curr_session.post('http://localhost:3001/login', json.encode({
      'id':_usernameController.text,
      'pswd':_passwordController.text,
    }));

    

    if(response.statusCode == 200){

      session.isLogged = true;
      session.id = _usernameController.text;
      session.pswd = _passwordController.text;
      if(_rememberMe == true){
        
        _saveCredentials();
      }
      
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const placePage()));
    }
    else if(response.statusCode == 403){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid username or password.'),
      ));
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Somthing went wrong.'),
      ));
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
