import 'package:flutter/material.dart';

Widget authorisationPage(BuildContext context, String caller) {
  return Scaffold(
    body: Center(
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
  );
}
