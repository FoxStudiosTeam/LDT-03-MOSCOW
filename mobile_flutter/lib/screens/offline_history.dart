
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/widgets/base_header.dart';


class QueueHistoryScreen extends StatelessWidget {
  final IDependencyContainer di;
  const QueueHistoryScreen({super.key, required this.di});

  @override
  Widget build(BuildContext context) {
    var _queued = di.getDependency<IQueuedRequests>(IQueuedRequestsDIToken);
    var history = _queued.getHistory();
    final historyList = history
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    // historyList.add(
    //   QueuedStatus(
    //     DateTime.now().millisecondsSinceEpoch,
    //     _queued.dbg(),
    //     "",
    //     null
    //   )
    // );
    return Scaffold(
      appBar: BaseHeader(
        title: "Отложенная синхронизация",
        subtitle: "История отправленных запросов",
        onBack: () => Navigator.pop(context),
      ),
      body: ListView.builder(
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          final item = historyList[index];
          final sentTime = DateTime.fromMillisecondsSinceEpoch(item.sentAt);
          final sentStr = DateFormat('HH:mm:ss dd-MM-yyyy').format(sentTime);

          final synced = item.syncedStatus;
          String statusText;
          Color statusColor;

          if (synced == null) {
            statusText = "Pending";
            statusColor = Colors.orange;
          } else if (synced.isOk) {
            statusText = synced.statusCode == null ? "Success" : "Success (${synced.statusCode})";
            statusColor = Colors.green;
          } else {
            statusText = synced.statusCode == null ? "Failed" : "Failed (${synced.statusCode})";
            statusColor = Colors.red;
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(item.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("UUID: ${item.uuid}"),
                  Text("Sent: $sentStr"),
                  if (synced != null) Text("Synced at: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(synced.syncAt))}"),
                ],
              ),
              trailing: Text(
                statusText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          );
        },
      ),




    );
  }
}
