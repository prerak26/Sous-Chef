import 'package:flutter/material.dart';

Widget authorisationPage(BuildContext context, String caller) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Authorisation'),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          ElevatedButton(
            onPressed: () =>
                {Navigator.of(context).pushNamed('/login', arguments: caller)},
            child: const Text('Login'),
          ),
          ElevatedButton(
            onPressed: () =>
                {Navigator.of(context).pushNamed('/signup', arguments: caller)},
            child: const Text('Register'),
          ),
        ]),
      ),
    ),
  );
}

Widget card(String title, int serves, String authorid, BuildContext context) {
  String serve = '$serves';
  return Card(
    color: Colors.yellow[50],
    elevation: 8.0,
    margin: const EdgeInsets.all(4.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 38.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          serve,
          style: const TextStyle(
            fontSize: 38.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          authorid,
          style: const TextStyle(
            fontSize: 38.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
