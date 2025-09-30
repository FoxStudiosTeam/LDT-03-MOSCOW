import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/screens/punishment_item_screen.dart';

class PunishmentItemCard extends StatelessWidget {
  final PunishmentItem data;
  final List<Attachment> atts;
  final Map<int, String> statuses;
  final IDependencyContainer di;
  final Map<String, String> docs;

  const PunishmentItemCard({
    super.key,
    required this.di,
    required this.atts,
    required this.data,
    required this.statuses,
    required this.docs
  });
  
  String boolToString(bool is_suspend) {
    if (is_suspend) {
      return "Да";
    } else {
      return "Нет";
    }
  }

  String dateToString(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  String nullableDateToString(DateTime? date, String nullString) {
    if (date == null) {
      return nullString;
    }
    else {
      return dateToString(date);
    }
  }

  String dateTimeToString(DateTime date) {
    return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PunishmentItemScreen(di:di, addr: data.title, atts: atts)));
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Наименование нарушения:\n${data.title}",
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Нормативный документ: \n"
                      "${docs[data.regulation_doc ?? ''] ?? 'Нормативный документ не указан'}",
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Дата выдачи: \n${dateTimeToString(data.punish_datetime)}",
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Местоположение: \n${data.place}",
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Приостановка работ: \n${boolToString(data.is_suspend)}",
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Плановая дата устранения: \n${dateToString(data.correction_date_plan)}",
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Дата устранения фактическая: \n${nullableDateToString(data.correction_date_fact, "Нарушение еще не устранено")}",
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Сведения о переносе срока: \n${data.correction_date_info ?? "Сведений нет"}",
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Примечание: \n${data.comment ?? ""}",
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Статус: ${statuses[data.punish_item_status]?? "Неизвестный статус"}",
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}