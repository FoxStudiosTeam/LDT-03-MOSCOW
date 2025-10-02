import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
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

    return Scaffold(
      appBar: BaseHeader(
        title: "Отложенная синхронизация",
        subtitle: "История отправленных запросов",
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.grey[50],
      body: historyList.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(historyList),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "История пуста",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Здесь будут отображаться отправленные запросы",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<QueuedStatus> historyList) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyList.length,
      itemBuilder: (context, index) {
        final item = historyList[index];
        return _buildHistoryCard(item, index == historyList.length - 1);
      },
    );
  }

  Widget _buildHistoryCard(QueuedStatus item, bool isLast) {
    final sentTime = DateTime.fromMillisecondsSinceEpoch(item.sentAt);
    final sentStr = DateFormat('HH:mm • dd.MM.yyyy').format(sentTime);

    final synced = item.syncedStatus;
    final (statusText, statusColor, statusIcon) = _getStatusInfo(synced);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и статус
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // UUID
              _buildInfoRow("ID запроса", item.uuid, Icons.fingerprint),

              const SizedBox(height: 8),

              // Время отправки
              _buildInfoRow("Отправлен", sentStr, Icons.access_time),

              // Время синхронизации (если есть)
              if (synced != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  "Синхронизирован",
                  DateFormat('HH:mm • dd.MM.yyyy').format(DateTime.fromMillisecondsSinceEpoch(synced.syncAt)),
                  Icons.sync,
                ),
              ],

              // Дополнительная информация о статусе
              if (synced != null && synced.statusCode != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  "Код ответа",
                  synced.statusCode.toString(),
                  Icons.code,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  (String, Color, IconData) _getStatusInfo(SyncedQueuedStatus? synced) {
    if (synced == null) {
      return (
      "В ожидании",
      Colors.orange,
      Icons.schedule,
      );
    } else if (synced.isOk) {
      return (
      synced.statusCode == null ? "Успешно" : "Успешно",
      Colors.green,
      Icons.check_circle,
      );
    } else {
      return (
      synced.statusCode == null ? "Ошибка" : "Ошибка",
      Colors.red,
      Icons.error,
      );
    }
  }
}