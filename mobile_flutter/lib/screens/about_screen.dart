import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/objects_screen.dart';

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
      backgroundColor: const Color(0xFFD0D0D0),
      appBar: AppBar(
        title: const Text(
          "FoxStudios",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Основной контент
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      "О нас",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Основной текст
                  const _AboutParagraph(
                    text: "Мы создаём современные цифровые решения для строительной отрасли, где особенно важны "
                        "прозрачность, точность и оперативность. Наше приложение помогает объединить участников "
                        "проекта в едином рабочем пространстве и сделать все процессы управляемыми: от первых "
                        "планов до итоговой сдачи объекта.",
                  ),

                  const _AboutParagraph(
                    text: "Наша миссия — упростить взаимодействие между всеми сторонами, сократить издержки и повысить "
                        "качество строительства. Мы уверены, что цифровизация позволяет по-новому взглянуть на привычные "
                        "процессы и открывает возможности для более эффективного сотрудничества.",
                  ),

                  const SizedBox(height: 24),

                  // Ключевые роли
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      "Ключевые роли в системе",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const _AboutParagraph(
                    text: "Для удобства и чёткой организации работы мы предусмотрели три типа пользователей. "
                        "Каждая роль отражает реальные задачи участников строительного процесса и помогает "
                        "сделать их взаимодействие максимально эффективным.",
                  ),

                  const SizedBox(height: 16),

                  // Карточки ролей
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        // Десктопная версия - 3 колонки
                        return const _RolesGridDesktop();
                      } else {
                        // Мобильная версия - одна колонка
                        return const _RolesListMobile();
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Призыв к действию
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD0D0D0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            "Готовы начать работу?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            "Для начала перейдите в список объектов, чтобы выбрать или создать проект.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ObjectsScreen(di: widget.di)));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              "Перейти в список объектов",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Виджет для параграфов текста
class _AboutParagraph extends StatelessWidget {
  final String text;

  const _AboutParagraph({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
          height: 1.6,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

// Десктопная версия карточек ролей (3 колонки)
class _RolesGridDesktop extends StatelessWidget {
  const _RolesGridDesktop();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _RoleCard(
            title: "Заказчик",
            description: "Получает полный контроль над проектом: видит сроки, прогресс выполнения, "
                "фото- и текстовые отчёты, а также может оперативно принимать управленческие решения.",
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _RoleCard(
            title: "Инспектор",
            description: "Контролирует качество и соблюдение стандартов. Все замечания и проверки фиксируются "
                "в системе, что снижает риски и упрощает процесс взаимодействия с другими участниками.",
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _RoleCard(
            title: "Подрядчик",
            description: "Управляет задачами своей команды, отмечает выполненные этапы и поддерживает "
                "постоянную связь с заказчиком и инспектором, ускоряя согласования и улучшая результат.",
          ),
        ),
      ],
    );
  }
}

// Мобильная версия карточек ролей (одна колонка)
class _RolesListMobile extends StatelessWidget {
  const _RolesListMobile();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _RoleCard(
          title: "Заказчик",
          description: "Получает полный контроль над проектом: видит сроки, прогресс выполнения, "
              "фото- и текстовые отчёты, а также может оперативно принимать управленческие решения.",
        ),
        SizedBox(height: 16),
        _RoleCard(
          title: "Инспектор",
          description: "Контролирует качество и соблюдение стандартов. Все замечания и проверки фиксируются "
              "в системе, что снижает риски и упрощает процесс взаимодействия с другими участниками.",
        ),
        SizedBox(height: 16),
        _RoleCard(
          title: "Подрядчик",
          description: "Управляет задачами своей команды, отмечает выполненные этапы и поддерживает "
              "постоянную связь с заказчиком и инспектором, ускоряя согласования и улучшая результат.",
        ),
      ],
    );
  }
}

// Карточка роли
class _RoleCard extends StatelessWidget {
  final String title;
  final String description;

  const _RoleCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD0D0D0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}