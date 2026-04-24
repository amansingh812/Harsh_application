import 'package:flutter/material.dart';
import 'package:school_scout/screens/login/login_page.dart';
import 'package:school_scout/screens/login/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginOrRegister> {
  //initially show login page
  bool showLoginPage = true;

  //toggle between login and register
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (showLoginPage) {
      return LoginPage();
    } else {
      return RegisterPage();
    }
  }
}
