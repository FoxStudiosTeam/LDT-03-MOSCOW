import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';

class PunishmentItemCard extends StatelessWidget {
  final DateTime punish_datetime;
  final String punishment_status;
  final String? custom_number;
  final IDependencyContainer di;

  const PunishmentItemCard({
    super.key,
    required this.di,
    required this.punish_datetime,
    required this.punishment_status,
    this.custom_number
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        // onTap: () {
        //   Navigator.push(context, MaterialPageRoute(builder: (_) => ObjectScreen(di:di, title: custom_number, content: punishment_status,)));
        // },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(custom_number??"", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(punishment_status),
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