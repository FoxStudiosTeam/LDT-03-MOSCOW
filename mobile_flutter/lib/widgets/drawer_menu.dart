import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/about_screen.dart';
import 'package:mobile_flutter/screens/auth_screen.dart';
import 'package:mobile_flutter/screens/map_screen.dart';
import 'package:mobile_flutter/screens/objects_screen.dart';
import 'package:mobile_flutter/screens/offline_history.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key, required this.di});

  final IDependencyContainer di;

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  void changeScreen(WidgetBuilder screen) {
    final newScreenType = screen(context).runtimeType;

    final currentRoute = ModalRoute.of(context);
    final currentName = currentRoute?.settings.name;

    if (currentName == newScreenType.toString()) {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context);
    Future.microtask(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: screen,
          settings: RouteSettings(name: newScreenType.toString()),
        ),
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Хедер
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            color: Colors.white,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 24,
                  height: 24,
                  color: Colors.black,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ЭСЖ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Электронный строительный журнал',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Основное меню
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Объекты'),
                  onTap: () {
                    changeScreen((context) => ObjectsScreen(di: widget.di));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('О нас'),
                  onTap: () {
                    changeScreen((context) => AboutScreen(di: widget.di));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: SvgPicture.asset("assets/icons/map.svg"),
                  title: const Text("Карта объектов"),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MapScreen(di: widget.di)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Iconify(
                    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><rect width="24" height="24" fill="none"/><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"><path d="M21.5 12a9.5 9.5 0 0 1-9.5 9.5c-1.628 0-3.16-.41-4.5-1.131c-1.868-1.007-3.125-.071-4.234.097a.53.53 0 0 1-.456-.156a.64.64 0 0 1-.117-.703c.436-1.025.835-2.969.29-4.607a9.5 9.5 0 0 1-.483-3a9.5 9.5 0 1 1 19 0"/><path d="M12 7v5l3 2"/></g></svg>'
                  ),
                  title: const Text("Отложенная синхронизация"),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => QueueHistoryScreen(di: widget.di)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: SvgPicture.asset("assets/icons/logout.svg"),
                  title: const Text("Выход"),
                  onTap: (){
                    widget.di.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken).clear();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => AuthScreen(di: widget.di)),
                    );
                  },
                ),
                
              ],
            ),
          ),

          const Divider(height: 1),

          // Текст внизу
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Электронный строительный журнал",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

}
