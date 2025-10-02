import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/materials/materials_provider.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/widgets/funny_things.dart';

import 'blur_menu.dart';

class MaterialCard extends StatelessWidget {
  final MaterialsAndAttachments data;
  final IDependencyContainer di;
  final Role? role;
  final Map<int, String> measurements;

  const MaterialCard({
    super.key,
    required this.data,
    required this.di,
    required this.role,
    required this.measurements,
  });

  void _openMaterialMenu(BuildContext context) {
    showBlurBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          (data.attachments.isEmpty)
          ? const Text("Вложений не обнаружено")
          : ConstrainedBox (
            constraints: const BoxConstraints(
              maxHeight: 300
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.attachments.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final att = data.attachments[index];
                return ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const Icon(Icons.download),
                  title: Text('Скачать ${att.originalFilename}'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleDownload(att.uuid);
                  },
                );
              },
            )
          ),
          if (role == Role.INSPECTOR || role == Role.ADMIN)
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: const Icon(Icons.science),
              title: const Text('Запросить исследование'),
              onTap: () async {
                final req = di.getDependency<IQueuedRequests>(IQueuedRequestsDIToken);
                var toSend = queuedMaterialResearch(data.material.uuid, "${data.material.title} - исследование");
                final token = await di.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken).getAccessToken();
                var res = await req.queuedSend(toSend, token);
                if (res.isDelayed) {
                  Navigator.pop(context);
                  showWarnSnackbar(context, "Запрос будет выполнен после выхода в интернет");
                } else if (res.isOk) {
                  Navigator.pop(context);
                  showSuccessSnackbar(context, "Отправлен запрос на исследование");
                } else {
                  showErrSnackbar(context, "Не удалось отправить запрос");
                }
              },
            ),
        ],
      ),
    );
  }

  void _handleDownload(String uuid) {
    // TODO: Реализовать логику скачивания документа
  }


  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и кнопка меню
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data.material.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _openMaterialMenu(context),
                  icon: SvgPicture.asset(
                    'assets/icons/menu-kebab.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Объем
            _buildInfoRow(
              icon: Icons.scale,
              label: "Объем:",
              value: "${data.material.volume.toString()} ${measurements[data.material.measurement] ?? "у.е."}",
            ),
            const SizedBox(height: 8),

            // Дата поставки
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: "Дата поставки:",
              value: "${data.material.deliveryDate.day}."
                  "${data.material.deliveryDate.month}."
                  "${data.material.deliveryDate.year}",
            ),
            const SizedBox(height: 8),

            // Статус
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: (data.material.onResearch)? Colors.orange : Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  (data.material.onResearch)? "Требуется проверка" : "В норме",
                  style: TextStyle(
                    fontSize: 14,
                    color: (data.material.onResearch)? Colors.orange : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}