import 'package:flutter/material.dart';

import '../widgets/my_drawer.dart';
import '../widgets/my_sliver_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: MyDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxisScrolled) => [
          MySliverAppBar(
            child: Text("Hello"),
            title: Text("Title"),
          )
        ],
        body: Container(
          color: Colors.blue,
        ),
      ),
    );
  }
}
