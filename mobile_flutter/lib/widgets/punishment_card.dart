import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/punishment/punishment_storage_provider.dart';
import 'package:mobile_flutter/screens/punishment_items_screen.dart';

class PunishmentCard extends StatelessWidget {
  final Punishment data;
  final Map<int, String> statuses;
  final String addr;
  final IDependencyContainer di;

  const PunishmentCard({
    super.key,
    required this.statuses,
    required this.di,
    required this.data,
    required this.addr
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PunishmentItemsScreen(di:di, punishmentUuid: data.uuid, addr: addr)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Номер: ${data.customNumber??""}",
                style:
                  Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(statuses[data.punishmentStatus]?? "Неизвестный статус"),
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