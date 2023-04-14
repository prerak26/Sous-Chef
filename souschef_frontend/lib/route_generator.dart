import 'package:flutter/material.dart';
import 'package:souschef_frontend/login.dart';
import 'package:souschef_frontend/navigation.dart';
import 'package:souschef_frontend/signup.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    if (args is String) {
      switch (settings.name) {
        case '/':
          return MaterialPageRoute(
            builder: (_) => NavigationView(
              initalView: args,
            ),
          );
        case '/login':
          return MaterialPageRoute(
            builder: (_) => LoginView(
              caller: args,
            ),
          );
        case '/signup':
          return MaterialPageRoute(
            builder: (_) => SignupView(
              caller: args,
            ),
          );
        default:
          return _defaultPage();
      }
    } else {
      return _defaultPage();
    }
  }

  static Route<dynamic> _defaultPage() {
    return MaterialPageRoute(
      builder: (_) => const NavigationView(
        initalView: "discover",
      ),
    );
  }
}
