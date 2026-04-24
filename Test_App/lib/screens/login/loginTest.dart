import 'package:flutter/material.dart';


class Logintest extends StatefulWidget {
  const Logintest({super.key});

  @override
  State<Logintest> createState() => _LogintestState();
}

class _LogintestState extends State<Logintest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Text("Welcome",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize:30,
          ),)
        ],
      ),
    );
  }
}
