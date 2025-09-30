import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/about_screen.dart';
import 'package:mobile_flutter/screens/auth_screen.dart';
import 'package:mobile_flutter/screens/objects_screen.dart';

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
                  leading: SvgPicture.asset("assets/icons/logout.svg"),
                  title: const Text("Выход"),
                  onTap: (){
                    widget.di.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken).clear();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => AuthScreen(di: widget.di)),
                    );
                  },
                )
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
