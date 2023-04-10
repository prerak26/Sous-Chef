import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/myrecipieholder.dart';
import 'package:souschef_frontend/signup.dart';
import 'package:souschef_frontend/userhome.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _username = '';
  String _password = '';

  void _login() async{
    
    var response = await curr_session.post('http://localhost:3001/login', {
      'id':_username,
      'pswd':_password,
    });
    if(response.statusCode == 200){

      session.isLogged = true;
      session.id = _username;
      session.pswd = _password;
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
