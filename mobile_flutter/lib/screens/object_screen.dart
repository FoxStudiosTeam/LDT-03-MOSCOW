import 'package:flutter/material.dart';

import '../di/dependency_container.dart';

class ObjectScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String title;
  final String content;

  const ObjectScreen({super.key, required this.di, required this.title, required this.content});


  @override
  State<ObjectScreen> createState() => _ObjectScreenScreenState();
}

class _ObjectScreenScreenState extends State<ObjectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Text(widget.title)
          ],
        )
      ),
    );
  }
}