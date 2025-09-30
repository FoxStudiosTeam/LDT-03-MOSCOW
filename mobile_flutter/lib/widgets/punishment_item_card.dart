import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';

class PunishmentItemCard extends StatelessWidget {
  final PunishmentItem data;
  final Map<int, String> statuses;
  final IDependencyContainer di;

  const PunishmentItemCard({
    super.key,
    required this.di,
    required this.data,
    required this.statuses,
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
              Text('Нарушение: ${data.title}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Статус: ${statuses[data.punish_item_status]}'),
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