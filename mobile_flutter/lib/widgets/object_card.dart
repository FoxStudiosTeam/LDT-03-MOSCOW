import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/object_screen.dart';

class ObjectCard extends StatelessWidget {
  final String title;
  final String content;
  final IDependencyContainer di;

  const ObjectCard({
    super.key,
    required this.title,
    required this.content,
    required this.di
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ObjectScreen(di:di, title: title, content: content,)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(content),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 100,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Text("colored back text"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}