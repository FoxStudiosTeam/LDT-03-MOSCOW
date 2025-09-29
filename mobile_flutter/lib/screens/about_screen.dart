import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';

class AboutScreen extends StatefulWidget {
  final IDependencyContainer di;
  const AboutScreen({super.key, required this.di});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Экран о нас"),
    );
  }

}