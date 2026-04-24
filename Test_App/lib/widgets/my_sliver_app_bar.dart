import 'package:flutter/material.dart';

class MySliverAppBar extends StatelessWidget{
  final Widget child;
  final Widget title;
  const MySliverAppBar({super.key,
  required this.title,
  required this.child,
  });


    @override
   Widget build(BuildContext context) {
    // TODO: implement build
    return SliverAppBar(
      expandedHeight: 340,
      collapsedHeight: 120,
      floating: false,
      pinned: true,
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart),
        )
      ],
      backgroundColor: Theme.of(context).colorScheme.background,
      title: title,
      flexibleSpace: FlexibleSpaceBar(
        background: child,
      ),

    );
  }}